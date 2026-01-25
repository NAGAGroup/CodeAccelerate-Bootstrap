---
name: creating-mermaid-diagrams
description: Use when creating architecture diagrams, sequence diagrams, flowcharts, or any visual documentation from code analysis
---

## Overview

Core principle: Only the tech_lead may run this skill. They analyze source first, then prepare precise diagram specs, and finally author Mermaid diagrams in Markdown.

## Workflow

- Step 1: Tech_lead explores/reads source code to get exact class names, methods, relationships
- Step 2: Tech_lead creates detailed spec with precise identifiers from source
- Step 3: Draft the mermaid diagram syntax following the spec
- Step 4: Validate syntax using `diagrams_generate_mermaid_diagram` tool with `outputType: "mermaid"`
- Step 5: If validation passes, embed the diagram in markdown; if it fails, fix syntax errors and retry

## Diagram Types Reference

- `flowchart TD/LR` - process flows, decision trees
- `sequenceDiagram` - interactions over time, API calls
- `classDiagram` - class relationships, inheritance
- `stateDiagram-v2` - state machines
- `erDiagram` - entity relationships, database schemas
- `gantt` - timelines, project schedules
- `pie` - proportions
- `gitgraph` - branch/merge visualization
- `mindmap` - hierarchical concepts
- `timeline` - chronological events

## Common Syntax Pitfalls

- Sequence diagram participant labels with spaces **must** be quoted or Mermaid treats the second word as a new identifier.
  - ❌ `participant Init as Device Init`
  - ✅ `participant Init as "Device Init"`
- HTML entities (`&lt;`, `&gt;`, `&amp;`, etc.) in sequence diagram messages break parsing because Mermaid expects the arrow token immediately after the message text.
  - ❌ `Factory-->>Device: optional&lt;UsmPoolContainer&gt;`
  - ✅ `Factory-->>Device: optional UsmPoolContainer`
- Avoid raw `<` or `>` in any message text―Mermaid often misinterprets them as syntax, even when not encoded.
  - ❌ `A->>B: Returns List<Item>`
  - ✅ `A->>B: Returns List of Items`
- Literal `\n` does not create newlines inside flowchart node labels; use `<br>` for line breaks.
  - ❌ `A["Line 1\nLine 2"]`
  - ✅ `A["Line 1<br>Line 2"]`
- Escape or avoid `<T>` generics in text (use `T` or HTML entities) when they are required in class/flow descriptions outside of sequence messages.
- Alt/else blocks need explicit structure with proper `end`
- Node IDs can't have special characters

## Color & Styling Best Practices

- Always specify text color with fill: `style Node fill:#color,color:#textcolor`
- Suggested palette with tested contrast (light backgrounds get `color:#000000`, dark get `color:#ffffff`)
- Example palette:
  - Light fills: `#e1f5fe`, `#f3e5f5`, `#fff3e0`, `#e8f5e9` → use `color:#000000`
  - Dark fills: `#1565c0`, `#6a1b9a`, `#e65100`, `#2e7d32` → use `color:#ffffff`

## Tool Usage for Syntax Validation

Before embedding any mermaid diagram in documentation:

1. **Draft the diagram syntax** based on source analysis
2. **Validate with the diagrams MCP tool:**

   ```
   diagrams_generate_mermaid_diagram(
     mermaid: "<your diagram syntax>",
     outputType: "mermaid"
   )
   ```

3. **If validation succeeds:** The tool returns the validated syntax - embed it in markdown
4. **If validation fails:** Fix the syntax errors reported by the tool and retry
5. **Never skip validation** - syntax errors will break rendering on GitHub

## Output Convention

- Primary output: Fenced ```mermaid block in Markdown (validated via MCP tool)
- GitHub renders mermaid natively - no need for external preview URLs or image exports
- Save to `./docs/`

## Confirm Save Location Before Writing Files

Before writing any diagram file to disk, **confirm the exact save location with the user** (directory + filename).

Rationale: Prevents diagrams being saved to unexpected locations or overwriting an existing file.

## Common Mistakes

- Skipping source analysis before diagramming
- Using generic placeholders instead of exact identifiers from code
- **Skipping MCP tool validation** - always validate syntax before embedding
- Forgetting text color on styled nodes
- Unquoted labels in sequence diagrams
- Raw angle brackets in diagram text
