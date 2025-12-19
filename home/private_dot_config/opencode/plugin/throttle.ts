import { appendFileSync, existsSync, unlinkSync, writeFileSync, readFileSync } from "fs";
import type { PluginInput, Hooks } from "@opencode-ai/plugin";

const config = {
  delayMs: parseInt(process.env.THROTTLE_DELAY_MS || "500", 10),
  lockFile: process.env.THROTTLE_LOCK_FILE || "/tmp/opencode-throttle.lock",
  logFile: process.env.THROTTLE_LOG_FILE || "",
  maxWaitMs: parseInt(process.env.THROTTLE_MAX_WAIT_MS || "30000", 10),
  pollMs: parseInt(process.env.THROTTLE_POLL_MS || "50", 10),
};

function log(event: string, extra: Record<string, any> = {}) {
  if (!config.logFile) return;
  const line = JSON.stringify({ ts: new Date().toISOString(), pid: process.pid, event, ...extra }) + "\n";
  try { appendFileSync(config.logFile, line); } catch {}
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function tryAcquireLock(): boolean {
  try {
    if (existsSync(config.lockFile)) {
      const content = readFileSync(config.lockFile, "utf-8");
      const lockTime = parseInt(content, 10);
      if (!isNaN(lockTime) && Date.now() - lockTime > config.maxWaitMs) {
        log("stale-lock-removed", { lockAge: Date.now() - lockTime });
        unlinkSync(config.lockFile);
      } else {
        return false;
      }
    }
    writeFileSync(config.lockFile, String(Date.now()), { flag: "wx" });
    return true;
  } catch {
    return false;
  }
}

function releaseLock(): void {
  try { unlinkSync(config.lockFile); } catch {}
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
    await sleep(config.pollMs);
  }
  
  log("lock-timeout-force", { attempts, waitMs: Date.now() - startTime });
  try { unlinkSync(config.lockFile); } catch {}
  writeFileSync(config.lockFile, String(Date.now()));
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

export default async function throttlePlugin(_input: PluginInput): Promise<Hooks> {
  return {
    "chat.params": async (
      input: { sessionID: string; agent: string },
      _output: { temperature: number; topP: number; topK: number; options: Record<string, any> }
    ) => {
      const agent = typeof input.agent === 'string' ? input.agent : (input.agent as any)?.name || 'unknown';
      await throttledRequest(`chat:${agent}:${input.sessionID.slice(0, 8)}`);
    },
    
    "tool.execute.before": async (
      input: { tool: string; sessionID: string; callID: string },
      _output: { args: any }
    ) => {
      await throttledRequest(`tool:${input.tool}:${input.sessionID.slice(0, 8)}`);
    },
  };
}
