import type { Plugin, PluginInput } from "@opencode-ai/plugin";
import { tool } from "@opencode-ai/plugin";

interface BackgroundTask {
  id: string;
  agent: string;
  instruction: string;
  status: "running" | "completed" | "failed" | "cancelled";
  result?: string;
  error?: string;
  parentSessionId: string;
  childSessionId?: string;
  createdAt: number;
  completedAt?: number;
}

// Extended tool context with session metadata
interface ToolContextWithMetadata {
  sessionID: string;
  messageID: string;
  agent: string;
  abort: AbortSignal;
  metadata?: (input: { title?: string; metadata?: Record<string, unknown> }) => void;
}

// Singleton background manager
class BackgroundManager {
  private static instance: BackgroundManager;
  private tasks: Map<string, BackgroundTask> = new Map();
  private sessionHierarchy: Map<string, string> = new Map();
  private abortControllers: Map<string, AbortController> = new Map();

  static getInstance(): BackgroundManager {
    if (!BackgroundManager.instance) {
      BackgroundManager.instance = new BackgroundManager();
    }
    return BackgroundManager.instance;
  }

  registerTask(task: BackgroundTask) {
    this.tasks.set(task.id, task);
  }

  getTask(taskId: string): BackgroundTask | undefined {
    return this.tasks.get(taskId);
  }

  registerAbortController(taskId: string, controller: AbortController) {
    this.abortControllers.set(taskId, controller);
  }

  getAbortController(taskId: string): AbortController | undefined {
    return this.abortControllers.get(taskId);
  }

  completeTask(taskId: string, result: string) {
    const task = this.tasks.get(taskId);
    if (task) {
      task.status = "completed";
      task.result = result;
      task.completedAt = Date.now();
      // Clean up abort controller
      this.abortControllers.delete(taskId);
    }
  }

  failTask(taskId: string, error: string) {
    const task = this.tasks.get(taskId);
    if (task) {
      task.status = "failed";
      task.error = error;
      task.completedAt = Date.now();
      // Clean up abort controller
      this.abortControllers.delete(taskId);
    }
  }

  cancelTask(taskId: string) {
    const task = this.tasks.get(taskId);
    if (task) {
      task.status = "cancelled";
      task.completedAt = Date.now();
      // Clean up abort controller
      this.abortControllers.delete(taskId);
    }
  }

  getAllTasks(): BackgroundTask[] {
    return Array.from(this.tasks.values());
  }
}

export const BackgroundTaskPlugin: Plugin = async (ctx) => {
  const manager = BackgroundManager.getInstance();

  console.log("[background-task] Plugin activated");

  return {
    tool: {
      background_task: tool({
        description: `Dispatch an agent to run asynchronously in the background.
        
Returns immediately with a task_id. The main session can continue working while the background task runs.

Use this for:
- Long-running operations (tests, analysis, compilation)
- Parallel execution of independent tasks
- Non-blocking research or data gathering

The background agent runs in its own session and can use all available tools.`,

        args: {
          agent: tool.schema
            .string()
            .describe(
              'Agent to dispatch (e.g., "build", "explore", "librarian")',
            ),
          instruction: tool.schema
            .string()
            .describe("Instructions for the agent"),
          wait: tool.schema
            .boolean()
            .optional()
            .describe("Wait for task completion (default: false)"),
        },

        async execute(args, toolCtx) {
          const taskId = `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

          // Extract parent session ID from tool context
          const ctxWithMeta = toolCtx as unknown as ToolContextWithMetadata;
          const parentSessionId = ctxWithMeta.sessionID;

          if (!parentSessionId) {
            return `Error: Could not determine parent session ID from context`;
          }

          const task: BackgroundTask = {
            id: taskId,
            agent: args.agent,
            instruction: args.instruction,
            status: "running",
            parentSessionId,
            createdAt: Date.now(),
          };

          manager.registerTask(task);

          // Execute task asynchronously
          executeBackgroundTask(
            taskId,
            args.agent,
            args.instruction,
            parentSessionId,
            ctx,
            manager,
          ).catch((err) => {
            manager.failTask(taskId, err.message);
          });

          if (args.wait) {
            // Wait for completion
            return await waitForTask(taskId, manager, 300 * 1000); // 5 min timeout (converted to ms)
          }

          return `Background task started: ${taskId}\n\nAgent: ${args.agent}\nInstruction: ${args.instruction}\n\nUse background_output with task_id="${taskId}" to check results.`;
        },
      }),

      background_output: tool({
        description: `Get results from a background task.
        
Returns the output of a completed task, or status if still running.`,

        args: {
          task_id: tool.schema
            .string()
            .describe("Task ID returned from background_task"),
          wait: tool.schema
            .boolean()
            .optional()
            .describe("Wait for completion if still running"),
          timeout: tool.schema
            .number()
            .optional()
            .describe("Max wait time in seconds (default: 300)"),
        },

        async execute(args, toolCtx) {
          const task = manager.getTask(args.task_id);

          if (!task) {
            return `Error: Task ${args.task_id} not found`;
          }

          if (task.status === "running" && args.wait) {
            return await waitForTask(
              args.task_id,
              manager,
              (args.timeout || 300) * 1000, // Convert seconds to milliseconds
            );
          }

          if (task.status === "running") {
            return `Task ${args.task_id} is still running...\n\nAgent: ${task.agent}\nStarted: ${new Date(task.createdAt).toISOString()}`;
          }

          if (task.status === "completed") {
            return `Task ${args.task_id} completed:\n\n${task.result}`;
          }

          if (task.status === "failed") {
            return `Task ${args.task_id} failed:\n\n${task.error}`;
          }

          if (task.status === "cancelled") {
            return `Task ${args.task_id} was cancelled`;
          }

          return `Unknown task status: ${task.status}`;
        },
      }),

      background_cancel: tool({
        description: `Cancel running background tasks.`,

        args: {
          task_id: tool.schema
            .string()
            .optional()
            .describe("Specific task to cancel"),
          all: tool.schema.boolean().optional().describe("Cancel all tasks"),
        },

        async execute(args, toolCtx) {
          if (args.all) {
            const tasks = manager.getAllTasks();
            const cancelled = tasks.filter((t) => t.status === "running");
            
            // Actually abort each running task
            for (const t of cancelled) {
              const controller = manager.getAbortController(t.id);
              if (controller) {
                controller.abort();
              }
              
              // Try to abort the child session if available
              if (t.childSessionId) {
                try {
                  // Check if session abort method exists
                  if (typeof ctx.client.session.abort === 'function') {
                    await ctx.client.session.abort({
                      path: { id: t.childSessionId },
                    });
                  }
                } catch (error) {
                  console.error(`[background-task] Failed to abort session ${t.childSessionId}:`, error);
                }
              }
              
              manager.cancelTask(t.id);
            }
            return `Cancelled ${cancelled.length} running tasks`;
          }

          if (args.task_id) {
            const task = manager.getTask(args.task_id);
            
            if (!task) {
              return `Error: Task ${args.task_id} not found`;
            }
            
            if (task.status !== "running") {
              return `Task ${args.task_id} is not running (status: ${task.status})`;
            }
            
            // Actually abort the task
            const controller = manager.getAbortController(args.task_id);
            if (controller) {
              controller.abort();
            }
            
            // Try to abort the child session if available
            if (task.childSessionId) {
              try {
                // Check if session abort method exists
                if (typeof ctx.client.session.abort === 'function') {
                  await ctx.client.session.abort({
                    path: { id: task.childSessionId },
                  });
                }
              } catch (error) {
                console.error(`[background-task] Failed to abort session ${task.childSessionId}:`, error);
              }
            }
            
            manager.cancelTask(args.task_id);
            return `Cancelled task: ${args.task_id}`;
          }

          return `Error: Must specify task_id or all=true`;
        },
      }),
    },
  };
};

// Helper functions
async function executeBackgroundTask(
  taskId: string,
  agentName: string,
  instruction: string,
  parentSessionId: string,
  ctx: PluginInput,
  manager: BackgroundManager,
) {
  // Create an AbortController for this task
  const abortController = new AbortController();
  manager.registerAbortController(taskId, abortController);
  
  try {
    // Create a child session for this background task, linking to parent for TUI navigation
    const sessionResult = await ctx.client.session.create({
      body: {
        parentID: parentSessionId,
        title: `Background: ${agentName} - ${instruction.slice(0, 50)}...`,
      },
    });

    if (sessionResult.error || !sessionResult.data) {
      throw new Error(`Failed to create session: ${sessionResult.error}`);
    }

    const childSession = sessionResult.data;
    const task = manager.getTask(taskId);
    if (task) {
      task.childSessionId = childSession.id;
    }

    // Use synchronous session.prompt() which blocks until completion
    // This is the key difference - prompt() waits, promptAsync() doesn't
    const promptResult = await ctx.client.session.prompt({
      path: { id: childSession.id },
      body: {
        agent: agentName,
        parts: [
          {
            type: "text",
            text: instruction,
          },
        ],
      },
    });

    // Check if task was cancelled
    if (abortController.signal.aborted) {
      manager.cancelTask(taskId);
      return;
    }

    if (promptResult.error) {
      throw new Error(`Failed to send prompt: ${promptResult.error}`);
    }

    // Fetch the messages from the completed session
    const messagesResult = await ctx.client.session.messages({
      path: { id: childSession.id },
    });

    if (messagesResult.error || !messagesResult.data) {
      throw new Error(`Failed to fetch messages: ${messagesResult.error}`);
    }

    // Extract the assistant's response (last assistant message)
    const messages = messagesResult.data;
    let resultText = "";

    for (const msg of messages) {
      if (msg.info.role === "assistant") {
        for (const part of msg.parts) {
          if (part.type === "text") {
            resultText += part.text;
          }
        }
      }
    }

    const result = `Background task ${taskId} completed by @${agentName}\n\nInstruction: ${instruction}\n\nResult: ${resultText || "(No text output)"}`;

    manager.completeTask(taskId, result);

    // Notify the parent session that the task completed
    await notifyParentSession(parentSessionId, taskId, agentName, "completed", ctx);
  } catch (error) {
    // Check if this was a cancellation
    if (abortController.signal.aborted) {
      manager.cancelTask(taskId);
      return;
    }
    
    const errorMessage = error instanceof Error ? error.message : String(error);
    manager.failTask(taskId, errorMessage);

    // Notify the parent session that the task failed
    await notifyParentSession(parentSessionId, taskId, agentName, "failed", ctx, errorMessage);
  }
}

async function notifyParentSession(
  parentSessionId: string,
  taskId: string,
  agentName: string,
  status: "completed" | "failed",
  ctx: PluginInput,
  errorMessage?: string,
) {
  try {
    const message =
      status === "completed"
        ? `[BACKGROUND TASK COMPLETED] Task "${taskId}" (@${agentName}) has finished successfully. Use background_output with task_id="${taskId}" to retrieve the results.`
        : `[BACKGROUND TASK FAILED] Task "${taskId}" (@${agentName}) has failed. Error: ${errorMessage}. Use background_output with task_id="${taskId}" for details.`;

    await ctx.client.session.prompt({
      path: { id: parentSessionId },
      body: {
        parts: [
          {
            type: "text",
            text: message,
          },
        ],
      },
    });
  } catch (error) {
    // Log but don't throw - notification failure shouldn't break the task
    console.error(`[background-task] Failed to notify parent session: ${error}`);
  }
}

async function waitForTask(
  taskId: string,
  manager: BackgroundManager,
  timeout: number,
): Promise<string> {
  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    const task = manager.getTask(taskId);

    if (!task) {
      return `Error: Task ${taskId} not found`;
    }

    if (task.status === "completed") {
      return `Task ${taskId} completed:\n\n${task.result}`;
    }

    if (task.status === "failed") {
      return `Task ${taskId} failed:\n\n${task.error}`;
    }

    if (task.status === "cancelled") {
      return `Task ${taskId} was cancelled`;
    }

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  return `Timeout waiting for task ${taskId}`;
}
