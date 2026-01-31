import type { Plugin, PluginInput } from "@opencode-ai/plugin";
import { tool } from "@opencode-ai/plugin";

interface BackgroundTask {
  id: string;
  agent: string;
  instruction: string;
  status: "running" | "completed" | "failed" | "cancelled" | "cancelling";
  result?: string;
  error?: string;
  parentSessionId: string;
  parentAgent: string;  // Track the parent session's agent for notifications
  childSessionId?: string;
  sessionId?: string; // The child session ID for this task
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

// Lightweight context for memory efficiency
type TaskContext = { client: PluginInput["client"] };

// Constants for memory and stability
const TASK_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7 days
const MAX_TASKS = 50;
const MAX_RESULT_CHARS = 256 * 1024;

// Promise-based wait infrastructure
const taskResolvers: Map<string, { resolve: () => void }> = new Map();
const taskCompletionPromises: Map<string, Promise<void>> = new Map();

// Singleton background manager
class BackgroundManager {
  private static instance: BackgroundManager;
  private tasks: Map<string, BackgroundTask> = new Map();
  private abortControllers: Map<string, AbortController> = new Map();
  private taskContexts: Map<string, TaskContext> = new Map();
  private programmaticCancels: Set<string> = new Set(); // Track task IDs being cancelled programmatically

  static getInstance(): BackgroundManager {
    if (!BackgroundManager.instance) {
      BackgroundManager.instance = new BackgroundManager();
    }
    return BackgroundManager.instance;
  }

  private evictStaleTasks(): void {
    const now = Date.now();
    for (const [taskId, task] of this.tasks.entries()) {
      // Only evict non-running/non-pending tasks older than TTL
      if (task.status !== "running" && task.status !== "cancelling" && task.completedAt && (now - task.completedAt) > TASK_TTL_MS) {
        this.tasks.delete(taskId);
        this.taskContexts.delete(taskId);
        const controller = this.abortControllers.get(taskId);
        if (controller) {
          this.abortControllers.delete(taskId);
        }
      }
    }
  }

  private evictOldestTasks(): void {
    if (this.tasks.size <= MAX_TASKS) {
      return;
    }
    
    // Convert to array sorted by createdAt (oldest first)
    const taskEntries = Array.from(this.tasks.entries()).sort((a, b) => a[1].createdAt - b[1].createdAt);
    
    // First pass: delete oldest non-running/non-pending tasks
    for (const [taskId, task] of taskEntries) {
      if (this.tasks.size <= MAX_TASKS) {
        break;
      }
      if (task.status !== "running" && task.status !== "cancelling") {
        this.tasks.delete(taskId);
        this.taskContexts.delete(taskId);
        const controller = this.abortControllers.get(taskId);
        if (controller) {
          this.abortControllers.delete(taskId);
        }
      }
    }
    
    // Second pass: if still over limit, delete oldest regardless
    for (const [taskId] of taskEntries) {
      if (this.tasks.size <= MAX_TASKS) {
        break;
      }
      this.tasks.delete(taskId);
      this.taskContexts.delete(taskId);
      const controller = this.abortControllers.get(taskId);
      if (controller) {
        this.abortControllers.delete(taskId);
      }
    }
  }

  registerTask(task: BackgroundTask) {
    this.evictStaleTasks();
    this.tasks.set(task.id, task);
    this.evictOldestTasks();
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
      task.result = this.capText(result);
      task.completedAt = Date.now();
      // Clean up abort controller
      this.abortControllers.delete(taskId);
    }
    // Resolve deferred promise
    taskResolvers.get(taskId)?.resolve();
    taskResolvers.delete(taskId);
    taskCompletionPromises.delete(taskId);
    this.evictStaleTasks();
  }

  failTask(taskId: string, error: string) {
    const task = this.tasks.get(taskId);
    if (task) {
      task.status = "failed";
      task.error = this.capText(error);
      task.completedAt = Date.now();
      // Clean up abort controller
      this.abortControllers.delete(taskId);
    }
    // Resolve deferred promise
    taskResolvers.get(taskId)?.resolve();
    taskResolvers.delete(taskId);
    taskCompletionPromises.delete(taskId);
    this.evictStaleTasks();
  }

  cancelTask(taskId: string) {
    const task = this.tasks.get(taskId);
    if (task) {
      task.status = "cancelled";
      task.completedAt = Date.now();
      // Clean up abort controller
      this.abortControllers.delete(taskId);
    }
    // Resolve deferred promise
    taskResolvers.get(taskId)?.resolve();
    taskResolvers.delete(taskId);
    taskCompletionPromises.delete(taskId);
    this.evictStaleTasks();
  }

  getAllTasks(): BackgroundTask[] {
    return Array.from(this.tasks.values());
  }

  findTaskByChildSession(childSessionId: string): BackgroundTask | undefined {
    for (const task of this.tasks.values()) {
      if (task.childSessionId === childSessionId) {
        return task;
      }
    }
    return undefined;
  }

  getParentSession(taskId: string): string | undefined {
    const task = this.tasks.get(taskId);
    return task?.parentSessionId;
  }

  // Check if a session is the top-level (not a child of any task)
  isTopLevelSession(sessionId: string): boolean {
    for (const task of this.tasks.values()) {
      if (task.childSessionId === sessionId) {
        return false; // This session is a child of some task
      }
    }
    return true; // Not a child of any task = top-level
  }

  // Find all tasks spawned by a given parent session (direct children only)
  findTasksByParentSession(parentSessionId: string): BackgroundTask[] {
    const tasks: BackgroundTask[] = [];
    for (const task of this.tasks.values()) {
      if (task.parentSessionId === parentSessionId) {
        tasks.push(task);
      }
    }
    return tasks;
  }

  // Find all descendant tasks recursively (children, grandchildren, etc.)
  findAllDescendantTasks(sessionId: string): BackgroundTask[] {
    const descendants: BackgroundTask[] = [];
    const queue: string[] = [sessionId];
    
    while (queue.length > 0) {
      const currentSessionId = queue.shift()!;
      const childTasks = this.findTasksByParentSession(currentSessionId);
      
      for (const task of childTasks) {
        descendants.push(task);
        // If this task has a child session, its children might have spawned more tasks
        if (task.childSessionId) {
          queue.push(task.childSessionId);
        }
      }
    }
    
    return descendants;
  }

  // Find the root/top-level session by traversing up the hierarchy
  findTopLevelSession(sessionId: string): string {
    let currentSessionId = sessionId;
    
    // Keep going up until we find a session that's not a child of any task
    while (true) {
      const task = this.findTaskByChildSession(currentSessionId);
      if (!task) {
        // This session is not a child of any task, so it's top-level
        return currentSessionId;
      }
      // Move up to the parent
      currentSessionId = task.parentSessionId;
    }
  }

  registerTaskContext(taskId: string, ctx: PluginInput): void {
    this.taskContexts.set(taskId, { client: ctx.client });
  }

  getTaskContext(taskId: string): TaskContext | undefined {
    return this.taskContexts.get(taskId);
  }

  markProgrammaticCancel(taskId: string): void {
    this.programmaticCancels.add(taskId);
  }

  isProgrammaticCancel(taskId: string): boolean {
    return this.programmaticCancels.has(taskId);
  }

  clearProgrammaticCancel(taskId: string): void {
    this.programmaticCancels.delete(taskId);
  }

  private capText(s: string): string {
    return s.length > MAX_RESULT_CHARS ? s.slice(-MAX_RESULT_CHARS) : s;
  }
}

export const BackgroundTaskPlugin: Plugin = async (ctx) => {
  const manager = BackgroundManager.getInstance();

  return {
    tool: {
      background_task: tool({
        description: `Dispatch an agent to run asynchronously in the background.
        
Returns immediately with a task_id. The main session can continue working while the background task runs.

Use this for:
- Long-running operations (tests, analysis, compilation)
- Parallel execution of independent tasks
- Non-blocking research or data gathering

The background agent runs in its own session and can use all available tools.

**wait parameter:**
- \`wait: false\` (default): Returns immediately with task_id. You'll receive a notification when complete. **Recommended.**
- \`wait: true\`: Blocks until task completes. Use sparingly - only when you need the result immediately to proceed.`,

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
          session_id: tool.schema
            .string()
            .optional()
            .describe("Optional session ID to reuse an existing subagent session. If provided, continues conversation in that session instead of creating a new one."),
        },

        async execute(args, toolCtx) {
          const taskId = `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

          // Extract parent session ID and agent from tool context
          const ctxWithMeta = toolCtx as unknown as ToolContextWithMetadata;
          const parentSessionId = ctxWithMeta.sessionID;
          const parentAgent = ctxWithMeta.agent;

          if (!parentSessionId) {
            return `Error: Could not determine parent session ID from context`;
          }

          const task: BackgroundTask = {
            id: taskId,
            agent: args.agent,
            instruction: args.instruction,
            status: "running",
            parentSessionId,
            parentAgent: parentAgent || "coder",  // Default to "coder" if not available
            sessionId: args.session_id,
            createdAt: Date.now(),
          };

          manager.registerTask(task);
          manager.registerTaskContext(taskId, ctx);

          // Execute task asynchronously
          executeBackgroundTask(
            taskId,
            args.agent,
            args.instruction,
            parentSessionId,
            parentAgent,
            args.session_id,
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
            const sessionIdLine = task.sessionId ?? task.childSessionId;
            const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
            return `Task ${args.task_id} is still running...\n\nAgent: ${task.agent}\nStarted: ${new Date(task.createdAt).toISOString()}${sessionInfo}`;
          }

          if (task.status === "cancelling") {
            const sessionIdLine = task.sessionId ?? task.childSessionId;
            const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
            return `Task ${args.task_id} is being cancelled...\n\nAgent: ${task.agent}\nStarted: ${new Date(task.createdAt).toISOString()}${sessionInfo}`;
          }

          if (task.status === "completed") {
            const sessionIdLine = task.sessionId ?? task.childSessionId;
            const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
            return `Task ${args.task_id} completed:\n\n${task.result}${sessionInfo}`;
          }

          if (task.status === "failed") {
            const sessionIdLine = task.sessionId ?? task.childSessionId;
            const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
            return `Task ${args.task_id} failed:\n\n${task.error}${sessionInfo}`;
          }

          if (task.status === "cancelled") {
            const sessionIdLine = task.sessionId ?? task.childSessionId;
            const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
            return `Task ${args.task_id} was cancelled${sessionInfo}`;
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
            // Extract calling session ID to avoid cancelling ourselves
            const ctxWithMeta = toolCtx as unknown as ToolContextWithMetadata;
            const callingSessionId = ctxWithMeta.sessionID;
            
            const tasks = manager.getAllTasks();
            const cancelled = tasks.filter((t) => t.status === "running");
            
            // Actually abort each running task
            for (const t of cancelled) {
              // CRITICAL: Never abort the calling session itself
              if (t.childSessionId === callingSessionId) {
                continue;
              }
              
              // Set status to cancelling before abort
              const task = manager.getTask(t.id);
              if (task) {
                task.status = "cancelling";
              }
              
              // Mark as programmatic cancel before aborting
              manager.markProgrammaticCancel(t.id);
              
              const controller = manager.getAbortController(t.id);
              if (controller) {
                controller.abort();
              }
              
              // Abort the child session to immediately terminate it
              if (t.childSessionId) {
                const taskCtx = manager.getTaskContext(t.id);
                if (taskCtx) {
                  await taskCtx.client.session.abort({ path: { id: t.childSessionId } });
                }
              }
              
              manager.cancelTask(t.id);
            }
            return `Cancelled ${cancelled.length} running tasks`;
          }

          if (args.task_id) {
            // Extract calling session ID to avoid cancelling ourselves
            const ctxWithMeta = toolCtx as unknown as ToolContextWithMetadata;
            const callingSessionId = ctxWithMeta.sessionID;
            
            const task = manager.getTask(args.task_id);
            
            if (!task) {
              return `Error: Task ${args.task_id} not found`;
            }
            
            if (task.status !== "running") {
              return `Task ${args.task_id} is not running (status: ${task.status})`;
            }
            
            // CRITICAL: Never abort the calling session itself
            if (task.childSessionId === callingSessionId) {
              return `Error: Cannot cancel task ${args.task_id} - it would abort the calling session`;
            }
            
            // Set status to cancelling before abort
            task.status = "cancelling";
            
            // Mark as programmatic cancel before aborting
            manager.markProgrammaticCancel(args.task_id);
            
            // Actually abort the task
            const controller = manager.getAbortController(args.task_id);
            if (controller) {
              controller.abort();
            }
            
            // Abort the child session to immediately terminate it
            if (task.childSessionId) {
              const taskCtx = manager.getTaskContext(args.task_id);
              if (taskCtx) {
                await taskCtx.client.session.abort({ path: { id: task.childSessionId } });
              }
            }
            
            manager.cancelTask(args.task_id);
            return `Cancelled task: ${args.task_id}`;
          }

          return `Error: Must specify task_id or all=true`;
        },
      }),
    },

    event: async ({ event }) => {
      // Handle session interrupts (Esc+Esc or similar)
      if (event.type === "session.error") {
        const props = event.properties as {
          sessionID?: string;
          error?: { name?: string; data?: { message?: string } };
        };

        if (props.error?.name === "MessageAbortedError") {
          const abortedSessionId = props.sessionID;
          if (!abortedSessionId) return;

          const manager = BackgroundManager.getInstance();
          const isTopLevel = manager.isTopLevelSession(abortedSessionId);

          if (isTopLevel) {
            // TOP-LEVEL SESSION INTERRUPTED
            // Subagents should continue running and notify when done
            // Do nothing - let background tasks continue
          } else {
            // SUBAGENT SESSION INTERRUPTED
            // Cancel this subagent and ALL its children recursively, notify top-level

            // Find the task for this session
            const task = manager.findTaskByChildSession(abortedSessionId);
            if (task) {
              // Skip notification if this was a programmatic cancel (via background_cancel tool)
              if (manager.isProgrammaticCancel(task.id)) {
                manager.clearProgrammaticCancel(task.id);
                // Still cancel the task and its descendants, but don't notify
                manager.cancelTask(task.id);
                task.error = "Task was cancelled programmatically";
                
                // Find and cancel all descendant tasks
                const descendants = manager.findAllDescendantTasks(abortedSessionId);
                for (const descendant of descendants) {
                  manager.cancelTask(descendant.id);
                  descendant.error = "Parent task was cancelled - task was cancelled";
                }
                return;
              }
              
              // Cancel this task
              manager.cancelTask(task.id);
              task.error = "User interrupted subagent - task was cancelled";

              // Find and cancel all descendant tasks
              const descendants = manager.findAllDescendantTasks(abortedSessionId);
              for (const descendant of descendants) {
                manager.cancelTask(descendant.id);
                descendant.error = "Parent subagent was interrupted - task was cancelled";
              }

              // Notify the parent session about the interruption
              const taskCtx = manager.getTaskContext(task.id);
              if (taskCtx) {
                notifyParentSession(
                  task.parentSessionId,
                  task.parentAgent,
                  task.id,
                  task.agent,
                  "interrupted",
                  taskCtx
                ).catch((err) => {
                  // Failed to notify parent
                });
              }

              // Find top-level session and notify
              const topLevelSessionId = manager.findTopLevelSession(abortedSessionId);
              
              // Note: Direct notification to top-level would require ctx.client access
              // which we don't have in event handler. The task.error message will be
              // visible when parent checks background_output.
            }
          }
        }
      }
    },
  };
};

// Helper functions
async function executeBackgroundTask(
  taskId: string,
  agentName: string,
  instruction: string,
  parentSessionId: string,
  parentAgent: string,
  sessionId: string | undefined,
  ctx: PluginInput,
  manager: BackgroundManager,
) {
  // Create an AbortController for this task
  const abortController = new AbortController();
  manager.registerAbortController(taskId, abortController);
  
  // Create deferred promise for wait-based notifications
  let resolveCompletion!: () => void;
  const completionPromise = new Promise<void>((resolve) => { resolveCompletion = resolve; });
  taskResolvers.set(taskId, { resolve: resolveCompletion });
  taskCompletionPromises.set(taskId, completionPromise);
  
  try {
    let childSessionId: string;
    
    if (sessionId) {
      // Reuse existing session
      // NOTE: Reused sessions accumulate history/memory growth.
      const task = manager.getTask(taskId);
      if (task) {
        task.childSessionId = sessionId;
      }
      childSessionId = sessionId;
    } else {
      // Create a child session for this background task
      // NOTE: Client session API does not expose AbortSignal; rely on session.abort() for cancellation.
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
      childSessionId = childSession.id;
    }

    // Use synchronous session.prompt() which blocks until completion
    // This is the key difference - prompt() waits, promptAsync() doesn't
    // NOTE: Client session API does not expose AbortSignal; rely on session.abort() for cancellation.
    const promptResult = await ctx.client.session.prompt({
      path: { id: childSessionId },
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

    // Check if task was cancelled or cancelling (after prompt completes)
    const currentTask = manager.getTask(taskId);
    if (currentTask && (currentTask.status === "cancelled" || currentTask.status === "cancelling")) {
      // Resolve deferred promise if not already resolved
      taskResolvers.get(taskId)?.resolve();
      taskResolvers.delete(taskId);
      taskCompletionPromises.delete(taskId);
      return;
    }

    if (promptResult.error) {
      throw new Error(`Failed to send prompt: ${promptResult.error}`);
    }

    // Fetch the messages from the completed session
    const messagesResult = await ctx.client.session.messages({
      path: { id: childSessionId },
    });

    // Check if task was cancelled or cancelling (after messages fetch)
    if (currentTask && (currentTask.status === "cancelled" || currentTask.status === "cancelling")) {
      // Resolve deferred promise if not already resolved
      taskResolvers.get(taskId)?.resolve();
      taskResolvers.delete(taskId);
      taskCompletionPromises.delete(taskId);
      return;
    }

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

    // Check if task was already cancelled/interrupted before completing
    const finalTask = manager.getTask(taskId);
    if (finalTask && (finalTask.status === "cancelled" || finalTask.status === "cancelling")) {
      // Task was interrupted by user, don't send completion notification
      // (the interrupt handler already sent the interrupted notification)
      // Resolve deferred promise if not already resolved
      taskResolvers.get(taskId)?.resolve();
      taskResolvers.delete(taskId);
      taskCompletionPromises.delete(taskId);
      return;
    }

    manager.completeTask(taskId, result);

    // Notify the parent session that the task completed
    const taskCtx = manager.getTaskContext(taskId);
    if (taskCtx) {
      await notifyParentSession(parentSessionId, parentAgent, taskId, agentName, "completed", taskCtx);
    }
  } catch (error) {
    // Check if this was a cancellation
    if (abortController.signal.aborted) {
      // Resolve deferred promise if not already resolved
      taskResolvers.get(taskId)?.resolve();
      taskResolvers.delete(taskId);
      taskCompletionPromises.delete(taskId);
      manager.cancelTask(taskId);
      return;
    }
    
    const errorMessage = error instanceof Error ? error.message : String(error);
    manager.failTask(taskId, errorMessage);

    // Notify the parent session that the task failed
    const taskCtx = manager.getTaskContext(taskId);
    if (taskCtx) {
      await notifyParentSession(parentSessionId, parentAgent, taskId, agentName, "failed", taskCtx, errorMessage);
    }
  }
}

async function notifyParentSession(
  parentSessionId: string,
  parentAgent: string,
  taskId: string,
  agentName: string,
  status: "completed" | "failed" | "interrupted",
  taskCtx: TaskContext,
  errorMessage?: string,
) {
  let message: string;
  if (status === "completed") {
    message = `[BACKGROUND TASK COMPLETED] Task "${taskId}" (@${agentName}) has finished successfully. Use background_output with task_id="${taskId}" to retrieve the results.`;
  } else if (status === "interrupted") {
    message = `[BACKGROUND TASK INTERRUPTED] Task "${taskId}" (@${agentName}) was interrupted by user. The subagent and any of its children have been cancelled. How would you like to proceed?`;
  } else {
    message = `[BACKGROUND TASK FAILED] Task "${taskId}" (@${agentName}) has failed. Error: ${errorMessage}. Use background_output with task_id="${taskId}" for details.`;
  }

  try {
    // Try promptAsync first (fire-and-forget, doesn't wait for response)
    if (typeof taskCtx.client.session.promptAsync === 'function') {
      await taskCtx.client.session.promptAsync({
        path: { id: parentSessionId },
        body: {
          agent: parentAgent,  // Explicitly set parent agent to prevent agent switching
          parts: [
            {
              type: "text",
              text: message,
            },
          ],
        },
      });
    } else {
      // Fall back to prompt, but catch JSON parse errors since the notification
      // was still sent successfully even if the response parsing fails
      await taskCtx.client.session.prompt({
        path: { id: parentSessionId },
        body: {
          agent: parentAgent,  // Explicitly set parent agent to prevent agent switching
          parts: [
            {
              type: "text",
              text: message,
            },
          ],
        },
      });
    }
  } catch (error) {
    // JSON parse errors mean the request succeeded but response was empty/streaming
    // This is expected behavior - the notification was sent, agent will respond
    const errorMsg = (error as Error).message || String(error);
    if (!errorMsg.includes('JSON') && !errorMsg.includes('Unexpected EOF')) {
      console.error(`[background-task] notify failed:`, error);
    }
  }
}

async function waitForTask(
  taskId: string,
  manager: BackgroundManager,
  timeout: number,
): Promise<string> {
  const task = manager.getTask(taskId);

  if (!task) {
    return `Error: Task ${taskId} not found`;
  }

  // If already in terminal state, return immediately
  if (task.status === "completed") {
    const sessionIdLine = task.sessionId ?? task.childSessionId;
    const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
    return `Task ${taskId} completed:\n\n${task.result}${sessionInfo}`;
  }

  if (task.status === "failed") {
    const sessionIdLine = task.sessionId ?? task.childSessionId;
    const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
    return `Task ${taskId} failed:\n\n${task.error}${sessionInfo}`;
  }

  if (task.status === "cancelled") {
    const sessionIdLine = task.sessionId ?? task.childSessionId;
    const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
    return `Task ${taskId} was cancelled${sessionInfo}`;
  }

  // Task is running or cancelling, wait for completion promise
  const awaitPromise = taskCompletionPromises.get(taskId);
  
  if (!awaitPromise) {
    // Fallback: wait 0ms and re-check
    await new Promise((resolve) => setTimeout(resolve, 0));
    const recheckTask = manager.getTask(taskId);
    if (!recheckTask) {
      return `Error: Task ${taskId} not found or already cleaned up`;
    }
    // Re-check terminal states after fallback
    if (recheckTask.status === "completed") {
      const sessionIdLine = recheckTask.sessionId ?? recheckTask.childSessionId;
      const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
      return `Task ${taskId} completed:\n\n${recheckTask.result}${sessionInfo}`;
    }
    if (recheckTask.status === "failed") {
      const sessionIdLine = recheckTask.sessionId ?? recheckTask.childSessionId;
      const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
      return `Task ${taskId} failed:\n\n${recheckTask.error}${sessionInfo}`;
    }
    if (recheckTask.status === "cancelled") {
      const sessionIdLine = recheckTask.sessionId ?? recheckTask.childSessionId;
      const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
      return `Task ${taskId} was cancelled${sessionInfo}`;
    }
    return `Error: Task ${taskId} completion promise not found`;
  }

  // Race between completion and timeout
  const timeoutPromise = new Promise<void>((resolve) => setTimeout(resolve, timeout));
  
  await Promise.race([awaitPromise, timeoutPromise]);

  // After race, check final task status
  const finalTask = manager.getTask(taskId);
  
  if (!finalTask) {
    return `Error: Task ${taskId} not found`;
  }

  if (finalTask.status === "completed") {
    const sessionIdLine = finalTask.sessionId ?? finalTask.childSessionId;
    const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
    return `Task ${taskId} completed:\n\n${finalTask.result}${sessionInfo}`;
  }

  if (finalTask.status === "failed") {
    const sessionIdLine = finalTask.sessionId ?? finalTask.childSessionId;
    const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
    return `Task ${taskId} failed:\n\n${finalTask.error}${sessionInfo}`;
  }

  if (finalTask.status === "cancelled") {
    const sessionIdLine = finalTask.sessionId ?? finalTask.childSessionId;
    const sessionInfo = sessionIdLine ? `\n\nSession ID (for continuation): ${sessionIdLine}` : "";
    return `Task ${taskId} was cancelled${sessionInfo}`;
  }

  return `Timeout waiting for task ${taskId}`;
}
