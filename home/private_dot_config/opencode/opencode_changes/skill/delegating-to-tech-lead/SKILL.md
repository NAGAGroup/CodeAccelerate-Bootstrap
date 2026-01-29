---
name: delegating-to-tech-lead
description: Use when dispatching work to tech_lead agent
---

# Delegating to Tech Lead

## When to Delegate

Tech_lead handles:

- Technical analysis and code investigation
- Design decisions requiring codebase context
- Orchestrating implementation work
- Test execution and verification
- Build/CI troubleshooting

> [!WARNING]
> **Anti-Patterns - Do NOT include:**
>
> - Shell commands or terminal steps
> - Specific file paths/line numbers (unless user mandated as constraint)
> - Step-by-step implementation instructions
> - Technical approach decisions
> - Which tools to use
> - NEVER EVER tell tech_lead how to do its job, meaning led IT lead the team. This is what it's good at!
> - DO NOT tell tech_lead which specific subagents to use. Let it decide.

## Example: Good Delegation

Goal: Add dark mode support to the settings page
Context: User reported that the app lacks dark mode. Current theme system uses CSS variables defined in styles/theme.css.
Constraints:

- Must not break existing light mode
- No new dependencies
- Should follow existing theme architecture

Non-goals:

- Dark mode for admin panel (separate feature)
- User preference persistence (will be added later)
  Acceptance Criteria:
- Settings page renders correctly in dark mode
- Existing tests pass
- Light mode remains unchanged
  Reminders for Tech Lead:
- Load your required skills before starting
- Prioritize delegation to specialized subagents
- Check if additional skills can help with this task

## Example: Poor Delegation (Too Prescriptive)

Run grep -r "theme" src/ to find theme files
Edit src/components/Settings.tsx lines 45-67
Add this CSS: .dark-mode { background: #000; }
Use the edit tool to modify the file

## Instruction Template

Include these elements when dispatching to tech_lead:

### Goal

[What outcome is needed - the "what", not the "how"]

### Context

[User-provided information, observed symptoms, relevant background]

### Constraints

[Hard requirements: API stability, no new dependencies, compatibility needs, specific files if user mandated]

### Non-goals

[What is explicitly out of scope]

### Acceptance Criteria

[How success is verified - high level outcomes, not implementation steps]

### Reminders for Tech Lead

> [!IMPORTANT]
> Tech_lead, before proceeding:
>
> 1. **Load your required skills** - Check your agent definition and load all required skills
> 2. **Prioritize delegation to specialized subagents** - You lead a team of specialized subagents. Delegate tasks to them as appropriate.
> 3. **Check for additional skills** - Ask yourself if there are skills that can help with this specific task before moving forward

> [!NOTE]
> Tech_lead will read the codebase and make these decisions.
