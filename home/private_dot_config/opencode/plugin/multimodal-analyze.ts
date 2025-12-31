import * as fs from "fs";
import { promises as fsPromises } from "fs";
import path from "path";
import type { Plugin } from "@opencode-ai/plugin";
import { tool } from "@opencode-ai/plugin";

// Extended tool context with session metadata (copied from background-task.ts pattern)
interface ToolContextWithMetadata {
  sessionID: string;
  messageID: string;
  agent: string;
  abort: AbortSignal;
  metadata?: (input: { title?: string; metadata?: Record<string, unknown> }) => void;
}

function formatClientError(err: unknown): string {
  if (!err) return "unknown error";
  if (typeof err === "string") return err;
  if (err instanceof Error) return err.message;
  if (typeof err === "object" && err !== null && "message" in err) {
    return String((err as { message: unknown }).message);
  }
  try {
    return JSON.stringify(err);
  } catch {
    return String(err);
  }
}

const LOG_FILE = "/tmp/multimodal-analyze.log";

function debugLog(message: string, data?: unknown): void {
  const timestamp = new Date().toISOString();
  let logLine = `[${timestamp}] ${message}`;
  if (data !== undefined) {
    try {
      logLine += `: ${JSON.stringify(data, null, 2)}`;
    } catch {
      logLine += `: ${String(data)}`;
    }
  }
  logLine += "\n";
  fs.appendFileSync(LOG_FILE, logLine);
}

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const SUPPORTED_IMAGE_EXTENSIONS = [".png", ".jpg", ".jpeg", ".gif", ".webp"];

async function validateFile(filePath: string, allowedExtensions?: string[]): Promise<void> {
  try {
    const stats = await fsPromises.stat(filePath);
    if (!stats.isFile()) {
      throw new Error(`Path is not a file: ${filePath}`);
    }
    if (stats.size > MAX_FILE_SIZE) {
      throw new Error(`File size exceeds 10MB limit (${(stats.size / (1024 * 1024)).toFixed(2)} MB)`);
    }
    if (allowedExtensions) {
      const ext = path.extname(filePath).toLowerCase();
      if (!allowedExtensions.includes(ext)) {
        throw new Error(`Unsupported file extension: ${ext}. Supported extensions: ${allowedExtensions.join(", ")}`);
      }
    }
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      throw new Error(`File not found: ${filePath}`);
    }
    throw error;
  }
}

function inferMimeType(filePath: string): string {
  const ext = path.extname(filePath).toLowerCase();
  switch (ext) {
    case ".png":
      return "image/png";
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".gif":
      return "image/gif";
    case ".webp":
      return "image/webp";
    default:
      throw new Error(`Unsupported file extension: ${ext}`);
  }
}

async function sendToMultimodalAgent(options: {
  ctx: Parameters<Plugin>[0];
  parentSessionId: string;
  prompt: string;
  filePart: { type: "file"; url: string; mime: string; filename: string };
}): Promise<string> {
  const { ctx, parentSessionId, prompt, filePart } = options;

  const maxTitleLen = 50;
  const truncatedPrompt =
    prompt.length > maxTitleLen
      ? `${prompt.slice(0, maxTitleLen - 3)}...`
      : prompt;

  try {
    debugLog("Starting multimodal analysis", {
      prompt,
      mimeType: filePart.mime,
      fileUrl: filePart.url,
    });

    const sessionResult = await ctx.client.session.create({
      body: {
        parentID: parentSessionId,
        title: `Multimodal analysis: ${truncatedPrompt}`,
      },
    });

    if (sessionResult.error || !sessionResult.data) {
      throw new Error(`Failed to create session: ${formatClientError(sessionResult.error)}`);
    }

    const childSession = sessionResult.data;
    debugLog("Session created", { sessionId: childSession.id });

    debugLog("Sending prompt to multimodal agent");
    const promptResult = await ctx.client.session.prompt({
      path: { id: childSession.id },
      body: {
        agent: "multimodal",
        parts: [
          { type: "text", text: prompt },
          {
            type: "file",
            url: filePart.url,
            mime: filePart.mime,
            filename: filePart.filename,
          },
        ],
      },
    });

    debugLog("Prompt result", { error: promptResult.error, hasData: !!promptResult.data });

    if (promptResult.error) {
      throw new Error(`Failed to send prompt: ${formatClientError(promptResult.error)}`);
    }

    const messagesResult = await ctx.client.session.messages({
      path: { id: childSession.id },
    });

    if (messagesResult.error || !messagesResult.data) {
      throw new Error(`Failed to fetch messages: ${formatClientError(messagesResult.error)}`);
    }

    // Extract and concatenate ALL assistant text from ALL assistant messages
    const messages = messagesResult.data;
    let resultText = "";

    for (const msg of messages) {
      if (msg.info.role === "assistant") {
        for (const part of msg.parts) {
          if (part.type === "text") {
            if (resultText && part.text) {
              resultText += "\n";
            }
            resultText += part.text;
          }
        }
      }
    }

    return resultText.trim() || "(No analysis returned)";
  } catch (err) {
    debugLog("Error occurred", { error: formatClientError(err) });
    throw err;
  }
}

export const MultimodalAnalyzePlugin: Plugin = async (ctx) => {
  return {
    tool: {
      analyze_image: tool({
        description: "Analyze an image file using the multimodal agent.",
        args: {
          path: tool.schema
            .string()
            .describe("Path to the image file (PNG, JPG, GIF, WebP)"),
          prompt: tool.schema
            .string()
            .optional()
            .describe(
              'Optional instruction for the multimodal agent (default: "Describe this image in detail")',
            ),
        },
        async execute(args, toolCtx) {
          const ctxWithMeta = toolCtx as unknown as ToolContextWithMetadata;
          const parentSessionId = ctxWithMeta.sessionID;

          if (!parentSessionId) {
            return "Error: Could not determine parent session ID from context";
          }

          const filePath = path.resolve(args.path);
          const promptText = args.prompt || "Describe this image in detail";

          try {
            await validateFile(filePath, SUPPORTED_IMAGE_EXTENSIONS);
            const mimeType = inferMimeType(filePath);
            const absolutePath = path.resolve(filePath);
            const filePart = {
              type: "file" as const,
              url: `file://${absolutePath}`,
              mime: mimeType,
              filename: path.basename(absolutePath),
            };

            const analysis = await sendToMultimodalAgent({
              ctx,
              parentSessionId,
              prompt: promptText,
              filePart,
            });

            return analysis;
          } catch (error) {
            return `Error analyzing image: ${(error as Error).message}`;
          }
        },
      }),

      analyze_pdf: tool({
        description: "Analyze a PDF file using the multimodal agent.",
        args: {
          path: tool.schema
            .string()
            .describe("Path to the PDF file"),
          prompt: tool.schema
            .string()
            .optional()
            .describe(
              'Optional instruction for the multimodal agent (default: "Analyze this PDF and describe its contents")',
            ),
        },
        async execute(args, toolCtx) {
          const ctxWithMeta = toolCtx as unknown as ToolContextWithMetadata;
          const parentSessionId = ctxWithMeta.sessionID;

          if (!parentSessionId) {
            return "Error: Could not determine parent session ID from context";
          }

          const filePath = path.resolve(args.path);
          const promptText =
            args.prompt || "Analyze this PDF and describe its contents";

          try {
            await validateFile(filePath, [".pdf"]);
            const mimeType = "application/pdf";
            const absolutePath = path.resolve(filePath);
            const filePart = {
              type: "file" as const,
              url: `file://${absolutePath}`,
              mime: mimeType,
              filename: path.basename(absolutePath),
            };

            const analysis = await sendToMultimodalAgent({
              ctx,
              parentSessionId,
              prompt: promptText,
              filePart,
            });

            return analysis;
          } catch (error) {
            return `Error analyzing PDF: ${(error as Error).message}`;
          }
        },
      }),
    },
  };
};

export default MultimodalAnalyzePlugin;
