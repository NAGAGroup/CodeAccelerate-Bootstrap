import {
  appendFileSync,
  unlinkSync,
  writeFileSync,
  readFileSync,
} from "fs";
import { createHash } from "crypto";
import type { PluginInput, Hooks } from "@opencode-ai/plugin";

const logFile = process.env.THROTTLE_LOG_FILE || "";

function log(event: string, extra: Record<string, any> = {}) {
  if (!logFile) return;
  const line =
    JSON.stringify({
      ts: new Date().toISOString(),
      pid: process.pid,
      event,
      ...extra,
    }) + "\n";
  try {
    appendFileSync(logFile, line);
  } catch {}
}

/**
 * Parse and validate an integer environment variable with bounds checking.
 */
function parseIntEnv(
  name: string,
  defaultValue: number,
  options: { min?: number; max?: number } = {},
): number {
  const envValue = process.env[name];
  if (!envValue) {
    return defaultValue;
  }

  const parsed = parseInt(envValue, 10);
  if (isNaN(parsed) || envValue.trim() === "") {
    log("invalid-config", {
      name,
      value: envValue,
      default: defaultValue,
      reason: "not-a-number",
    });
    return defaultValue;
  }

  let result = parsed;
  if (options.min !== undefined && result < options.min) {
    log("invalid-config", {
      name,
      value: parsed,
      default: defaultValue,
      reason: "below-minimum",
      min: options.min,
    });
    result = options.min;
  }
  if (options.max !== undefined && result > options.max) {
    log("invalid-config", {
      name,
      value: parsed,
      default: defaultValue,
      reason: "above-maximum",
      max: options.max,
    });
    result = options.max;
  }
  return result;
}

const config = {
  delayMs: parseIntEnv("THROTTLE_DELAY_MS", 100, { min: 0 }),
  lockFile: process.env.THROTTLE_LOCK_FILE || (() => {
    const uidPart = typeof process.getuid === "function" ? String(process.getuid()) : "nouid";
    const cwdHash = createHash("sha256").update(process.cwd()).digest("hex").slice(0, 10);
    return `/tmp/opencode-throttle-${uidPart}-${cwdHash}.lock`;
  })(),
  logFile: process.env.THROTTLE_LOG_FILE || "",
  maxWaitMs: parseIntEnv("THROTTLE_MAX_WAIT_MS", 30000, { min: 0 }),
  pollMs: parseIntEnv("THROTTLE_POLL_MS", 50, { min: 1 }),
  staleAfterMs: parseIntEnv("THROTTLE_STALE_AFTER_MS", 5 * 60 * 1000, {
    min: 1000,
  }),
};

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isProcessAlive(pid: number): boolean {
  try {
    process.kill(pid, 0); // Signal 0 = existence check, doesn't actually kill
    return true;
  } catch {
    return false;
  }
}

function parseLockFile(): { time: number; pid: number } | null {
  try {
    const content = readFileSync(config.lockFile, "utf-8");
    const [timeStr, pidStr] = content.split(":");
    const time = parseInt(timeStr, 10);
    const pid = parseInt(pidStr, 10);
    if (!isNaN(time) && !isNaN(pid)) {
      return { time, pid };
    }
  } catch {}
  return null;
}

function isLockStale(): boolean {
  const lock = parseLockFile();
  if (!lock) return true; // Can't read = treat as stale

  const age = Date.now() - lock.time;

  // Stale if: too old OR holding process is dead
  if (age > config.staleAfterMs) {
    log("stale-lock-timeout", { age, pid: lock.pid });
    return true;
  }

  if (!isProcessAlive(lock.pid)) {
    log("stale-lock-dead-process", { age, pid: lock.pid });
    return true;
  }

  return false;
}

function tryAcquireLock(): boolean {
  try {
    if (isLockStale()) {
      try {
        unlinkSync(config.lockFile);
      } catch {}
    }
  } catch {
    // isLockStale() threw (file may not exist); treat as not stale, do not unlink
  }

  try {
    writeFileSync(config.lockFile, `${Date.now()}:${process.pid}`, {
      flag: "wx",
    });
    return true;
  } catch (error: any) {
    // Lock already exists or other error
    return false;
  }
}

function releaseLock(): void {
  try {
    // Only release if we own it
    const lock = parseLockFile();
    if (lock && lock.pid === process.pid) {
      unlinkSync(config.lockFile);
    }
  } catch {}
}

async function acquireLock(): Promise<void> {
  const startTime = Date.now();
  let attempts = 0;

  while (Date.now() - startTime < config.maxWaitMs) {
    if (tryAcquireLock()) {
      log("lock-acquired", { attempts, waitMs: Date.now() - startTime });
      return;
    }
    attempts++;
    await sleep(config.pollMs + Math.random() * 20); // Jitter to reduce contention
  }

  // Timeout - fail with detailed error to preserve mutual exclusion
  const lockInfo = parseLockFile();
  const waitMs = Date.now() - startTime;
  log("lock-timeout", {
    attempts,
    waitMs,
    lock: lockInfo,
  });

  const lockDetails = lockInfo
    ? `pid=${lockInfo.pid}, age=${Date.now() - lockInfo.time}ms`
    : "unknown";
  throw new Error(
    `Throttle lock timeout after ${waitMs}ms (${attempts} attempts); lock held by ${lockDetails}`,
  );
}

async function throttledRequest(context: string): Promise<void> {
  log("request-start", { context });
  await acquireLock();
  try {
    await sleep(config.delayMs);
  } finally {
    releaseLock();
    log("request-done", { context });
  }
}

// Cleanup handlers
function cleanup() {
  releaseLock();
}

const fatalOnUnhandled = process.env.THROTTLE_FATAL_ON_UNHANDLED === "1";

process.on("exit", cleanup);
process.on("SIGINT", () => {
  cleanup();
  process.exit(0);
});
process.on("SIGTERM", () => {
  cleanup();
  process.exit(0);
});
if (fatalOnUnhandled) {
  process.on("uncaughtException", (err) => {
    log("uncaught-exception", { error: err.message });
    cleanup();
    process.exit(1);
  });
  process.on("unhandledRejection", (reason) => {
    log("unhandled-rejection", {
      error: reason instanceof Error ? reason.message : String(reason),
    });
    cleanup();
    process.exit(1);
  });
}

export default async function throttlePlugin(
  _input: PluginInput,
): Promise<Hooks> {
  log("plugin-init", { config });

  return {
    "chat.params": async (
      input: {
        sessionID: string;
        agent: string | { name?: string } | null | undefined;
      },
      _output: {
        temperature: number;
        topP: number;
        topK: number;
        options: Record<string, any>;
      },
    ) => {
      const agent =
        typeof input.agent === "string"
          ? input.agent
          : (input.agent as any)?.name || "unknown";
      await throttledRequest(`chat:${agent}:${input.sessionID.slice(0, 8)}`);
    },
    "tool.execute.before": async (
      input: { tool: string; sessionID: string; callID: string },
      _output: { args: any },
    ) => {
      await throttledRequest(
        `tool:${input.tool}:${input.sessionID.slice(0, 8)}`,
      );
    },
  };
}
