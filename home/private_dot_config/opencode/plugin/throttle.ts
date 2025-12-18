/**
 * OpenCode Throttle Plugin v3 - Burst Detection
 *
 * Drop this file into ~/.config/opencode/plugin/throttle.ts
 *
 * Only throttles when burst patterns are detected (multiple requests in quick succession).
 * Sequential requests flow through without delay.
 *
 * Configuration via environment variables:
 *   THROTTLE_BURST_WINDOW_MS=1000  - Window to detect bursts (default 1000ms)
 *   THROTTLE_BURST_THRESHOLD=3     - Number of requests in window to trigger throttling
 *   THROTTLE_DELAY_MS=300          - Delay between requests when throttling
 *   THROTTLE_DEBUG=true            - Enable debug logging
 */

// Configuration
const config = {
  burstWindowMs: parseInt(process.env.THROTTLE_BURST_WINDOW_MS || "1000", 10),
  burstThreshold: parseInt(process.env.THROTTLE_BURST_THRESHOLD || "3", 10),
  delayMs: parseInt(process.env.THROTTLE_DELAY_MS || "300", 10),
  debug: process.env.THROTTLE_DEBUG === "true",
};

// State
const requestTimestamps: number[] = []; // Rolling window of request times
let consecutiveErrors = 0;
let inBurstMode = false;
let burstModeUntil = 0;

function log(...args) {
  if (config.debug) console.log("[throttle]", ...args);
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Detect provider from model string
function detectProvider(input) {
  const model = (
    (input && input.metadata && input.metadata.model) ||
    ""
  ).toLowerCase();
  if (model.includes("copilot")) return "copilot";
  if (model.includes("claude") || model.includes("anthropic"))
    return "anthropic";
  if (model.includes("gpt") || model.includes("openai")) return "openai";
  if (model.includes("ollama") || model.includes("local")) return "local";
  return "default";
}

function isLocalProvider(provider) {
  return provider === "ollama" || provider === "local";
}

// Check if we're in a burst pattern
function detectBurst(): boolean {
  const now = Date.now();

  // Clean old timestamps outside the window
  while (
    requestTimestamps.length > 0 &&
    requestTimestamps[0] < now - config.burstWindowMs
  ) {
    requestTimestamps.shift();
  }

  // Add current request
  requestTimestamps.push(now);

  // Check if we've exceeded threshold
  const isBurst = requestTimestamps.length >= config.burstThreshold;

  if (isBurst && !inBurstMode) {
    log(
      `Burst detected! ${requestTimestamps.length} requests in ${config.burstWindowMs}ms window`,
    );
    inBurstMode = true;
    // Stay in burst mode for a bit after detection
    burstModeUntil = now + config.burstWindowMs * 2;
  }

  // Exit burst mode if we've been quiet
  if (
    inBurstMode &&
    now > burstModeUntil &&
    requestTimestamps.length < config.burstThreshold
  ) {
    log(`Exiting burst mode`);
    inBurstMode = false;
  }

  return inBurstMode;
}

// Mutex for serializing during burst mode
let mutex = Promise.resolve();
let lastThrottledTime = 0;

async function maybeThrottle(provider) {
  // Skip throttling for local providers
  if (isLocalProvider(provider)) {
    log(`Skipping throttle for local provider: ${provider}`);
    return;
  }

  const isBurst = detectBurst();

  if (!isBurst && consecutiveErrors === 0) {
    log(`No burst detected, proceeding immediately (provider=${provider})`);
    return;
  }

  // We're in burst mode or have errors - apply throttling
  const previousMutex = mutex;
  let releaseMutex;
  mutex = new Promise((resolve) => {
    releaseMutex = resolve;
  });

  await previousMutex;

  const now = Date.now();
  const timeSinceLast = now - lastThrottledTime;

  // Calculate delay
  let delayMs = config.delayMs;

  // Apply backoff if we've had errors
  if (consecutiveErrors > 0) {
    const backoffMs = Math.min(
      1000 * Math.pow(2, consecutiveErrors - 1),
      30000,
    );
    delayMs = Math.max(delayMs, backoffMs);
    log(`Backoff active: ${backoffMs}ms (${consecutiveErrors} errors)`);
  }

  if (timeSinceLast < delayMs) {
    const waitFor = delayMs - timeSinceLast;
    log(`Throttling: waiting ${waitFor}ms (burst mode, provider=${provider})`);
    await sleep(waitFor);
  }

  lastThrottledTime = Date.now();
  log(`Proceeding after throttle (provider=${provider})`);

  releaseMutex();
}

// Track requests for error detection
const activeRequests = new Map();

// Plugin export
export const ThrottlePlugin = async (ctx) => {
  if (config.debug) {
    console.log("[throttle] Plugin initialized - burst detection mode");
    console.log(
      `[throttle] Config: burstWindow=${config.burstWindowMs}ms, threshold=${config.burstThreshold}, delay=${config.delayMs}ms`,
    );
  }

  return {
    "tool.execute.before": async (input, output) => {
      const provider = detectProvider(input);
      const requestId = `${input.tool}-${Date.now()}`;

      log(`Before: tool=${input.tool}, provider=${provider}`);

      await maybeThrottle(provider);

      activeRequests.set(requestId, provider);
      if (output && typeof output === "object") {
        output.__throttleRequestId = requestId;
      }
    },

    "tool.execute.after": async (input, output) => {
      const requestId = output && output.__throttleRequestId;

      // Check for rate limit errors
      const isRateLimitError =
        output?.error?.message?.toLowerCase().includes("rate limit") ||
        output?.error?.message?.toLowerCase().includes("429") ||
        output?.status === 429;

      if (isRateLimitError) {
        consecutiveErrors++;
        // Force burst mode on rate limit
        inBurstMode = true;
        burstModeUntil = Date.now() + 10000; // Stay in burst mode for 10s after rate limit
        log(
          `Rate limit detected! consecutiveErrors=${consecutiveErrors}, forcing burst mode`,
        );
      } else {
        consecutiveErrors = Math.max(0, consecutiveErrors - 1);
      }

      log(`After: tool=${input.tool}, rateLimitError=${isRateLimitError}`);

      if (requestId) activeRequests.delete(requestId);
    },

    event: async ({ event }) => {
      if (event.type === "session.error") {
        const msg = (event.data?.message || "").toLowerCase();
        if (msg.includes("rate limit") || msg.includes("429")) {
          consecutiveErrors++;
          inBurstMode = true;
          burstModeUntil = Date.now() + 10000;
          log(`Session rate limit error, forcing burst mode`);
        }
      }
    },
  };
};

export default ThrottlePlugin;
