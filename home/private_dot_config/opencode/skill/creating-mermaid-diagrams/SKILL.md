---
name: creating-mermaid-diagrams
description: Use when creating architecture diagrams, sequence diagrams, flowcharts, or any visual documentation from code analysis
---

## Overview
Core principle: general agent analyzes source first, then dispatches document-writer with precise spec.

## Workflow
- Step 1: General agent explores/reads source code to get exact class names, methods, relationships
- Step 2: General agent creates detailed spec with precise identifiers from source
- Step 3: General agent dispatches document-writer with the spec
- Step 4: Review and fix any rendering issues

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

## Output Convention
- Save to `docs/diagrams/` directory
- Use markdown with fenced mermaid code blocks
- Follow existing file format (see neo-architecture.md as reference)

## Common Mistakes
- Dispatching document-writer without source analysis first
- Using generic placeholders instead of exact identifiers from code
- Forgetting text color on styled nodes
- Unquoted labels in sequence diagrams
- Raw angle brackets in diagram text
