import {
  appendFileSync,
  existsSync,
  unlinkSync,
  writeFileSync,
  readFileSync,
} from "fs";
import type { PluginInput, Hooks } from "@opencode-ai/plugin";

const config = {
  delayMs: parseInt(process.env.THROTTLE_DELAY_MS || "100", 10),
  lockFile: process.env.THROTTLE_LOCK_FILE || "/tmp/opencode-throttle.lock",
  logFile: process.env.THROTTLE_LOG_FILE || "",
  maxWaitMs: parseInt(process.env.THROTTLE_MAX_WAIT_MS || "30000", 10),
  pollMs: parseInt(process.env.THROTTLE_POLL_MS || "50", 10),
};

function log(event: string, extra: Record<string, any> = {}) {
  if (!config.logFile) return;
  const line =
    JSON.stringify({
      ts: new Date().toISOString(),
      pid: process.pid,
      event,
      ...extra,
    }) + "\n";
  try {
    appendFileSync(config.logFile, line);
  } catch {}
}

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
  if (age > config.maxWaitMs) {
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
    if (existsSync(config.lockFile)) {
      if (isLockStale()) {
        try {
          unlinkSync(config.lockFile);
        } catch {}
      } else {
        return false;
      }
    }
    writeFileSync(config.lockFile, `${Date.now()}:${process.pid}`, {
      flag: "wx",
    });
    return true;
  } catch {
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

  // Timeout - force acquire
  log("lock-timeout-force", { attempts, waitMs: Date.now() - startTime });
  try {
    unlinkSync(config.lockFile);
  } catch {}
  writeFileSync(config.lockFile, `${Date.now()}:${process.pid}`);
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

process.on("exit", cleanup);
process.on("SIGINT", () => {
  cleanup();
  process.exit(0);
});
process.on("SIGTERM", () => {
  cleanup();
  process.exit(0);
});
process.on("uncaughtException", (err) => {
  log("uncaught-exception", { error: err.message });
  cleanup();
  process.exit(1);
});

export default async function throttlePlugin(
  _input: PluginInput,
): Promise<Hooks> {
  log("plugin-init", { config });

  return {
    "chat.params": async (
      input: { sessionID: string; agent: string },
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
