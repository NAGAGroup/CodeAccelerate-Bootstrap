# Superpowers Terminology Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove “superpowers” terminology from the skills directory by renaming the “using-superpowers” skill, updating the internal skill `name:` field, and migrating all cross-references from `superpowers:<skill>` to `skill:<skill>`.

**Architecture:** This is a documentation-only migration with one directory rename, one metadata rename, and a set of deterministic string replacements across a known set of files. Verification is primarily grepping for remaining `superpowers` references plus a quick smoke test that skill loading still works.

**Tech Stack:** Markdown (`SKILL.md` and supporting `.md` docs), filesystem operations, ripgrep (`rg`) for verification.

---

## Preconditions / Notes

- **Scope**: Skills live under `/home/jack/.config/opencode/skill/`.
- **Decisions already made**:
  1. Cross-reference syntax changes: `superpowers:skill-name` → `skill:skill-name`
  2. Directory rename: `using-superpowers/` → `skill-invocation-policy/`
  3. Update skill name field: in the renamed skill’s `SKILL.md`, update `name: using-superpowers` → `name: skill-invocation-policy`

- **Files with known occurrences** (from exploration):
  - `writing-skills/testing-skills-with-subagents.md` (1)
  - `writing-skills/SKILL.md` (4)
  - `writing-plans/SKILL.md` (3)
  - `using-superpowers/SKILL.md` (1 — name field; directory will be renamed)
  - `systematic-debugging/SKILL.md` (3)
  - `subagent-driven-development/code-quality-reviewer-prompt.md` (1)
  - `subagent-driven-development/SKILL.md` (7, including one path `~/.config/superpowers/hooks/`)
  - `requesting-code-review/SKILL.md` (3)
  - `executing-plans/SKILL.md` (1)
  - `brainstorming/SKILL.md` (2)

- **Replacements to make** (exact mapping):

| Old | New |
|-----|-----|
| `superpowers:test-driven-development` | `skill:test-driven-development` |
| `superpowers:systematic-debugging` | `skill:systematic-debugging` |
| `superpowers:executing-plans` | `skill:executing-plans` |
| `superpowers:subagent-driven-development` | `skill:subagent-driven-development` |
| `superpowers:finishing-a-development-branch` | `skill:finishing-a-development-branch` |
| `superpowers:writing-plans` | `skill:writing-plans` |
| `superpowers:requesting-code-review` | `skill:requesting-code-review` |
| `superpowers:code-reviewer` | `skill:code-reviewer` |
| `superpowers:using-git-worktrees` | `skill:using-git-worktrees` |
| `superpowers:verification-before-completion` | `skill:verification-before-completion` |

- **Open decision to take in-task**: reference `~/.config/superpowers/hooks/` found in `subagent-driven-development/SKILL.md`.
  - **Recommendation**: change to `~/.config/opencode/hooks/` *if and only if* hooks are now managed under opencode. If hooks remain under `~/.config/superpowers/hooks/` for backward compatibility, keep it but add a note.

---

### Task 1: Rename the skill directory

**Files:**
- Rename directory: `/home/jack/.config/opencode/skill/using-superpowers/` → `/home/jack/.config/opencode/skill/skill-invocation-policy/`

**Step 1: Ensure source directory exists**

Run:
```bash
ls -la "/home/jack/.config/opencode/skill/using-superpowers"
```
Expected: directory listing succeeds.

**Step 2: Ensure destination directory does not exist**

Run:
```bash
ls -la "/home/jack/.config/opencode/skill/skill-invocation-policy" || true
```
Expected: “No such file or directory”.

**Step 3: Rename directory**

Run:
```bash
mv "/home/jack/.config/opencode/skill/using-superpowers" \
   "/home/jack/.config/opencode/skill/skill-invocation-policy"
```
Expected: command succeeds with no output.

**Step 4: Sanity-check new directory**

Run:
```bash
ls -la "/home/jack/.config/opencode/skill/skill-invocation-policy"
```
Expected: directory listing succeeds and includes `SKILL.md`.

**Step 5: Commit**

If this directory is tracked by git in your environment, commit just the rename:
```bash
git add -A
git commit -m "refactor(skills): rename using-superpowers skill directory"
```

---

### Task 2: Update the renamed skill’s `name:` metadata field

**Files:**
- Modify: `/home/jack/.config/opencode/skill/skill-invocation-policy/SKILL.md`

**Step 1: Open the file and locate the skill header**

Verify it contains:
- `name: using-superpowers`

**Step 2: Update the field**

Change:
```yaml
name: using-superpowers
```
To:
```yaml
name: skill-invocation-policy
```

**Step 3: Verify no other references remain in this file**

Run:
```bash
rg -n "superpowers" "/home/jack/.config/opencode/skill/skill-invocation-policy/SKILL.md" || true
```
Expected: no matches.

**Step 4: Commit**

```bash
git add "/home/jack/.config/opencode/skill/skill-invocation-policy/SKILL.md"
git commit -m "refactor(skills): rename using-superpowers skill name"
```

---

### Task 3: Update cross-reference syntax in known files (batch replaces)

**Files:**
- Modify: `/home/jack/.config/opencode/skill/writing-skills/testing-skills-with-subagents.md`
- Modify: `/home/jack/.config/opencode/skill/writing-skills/SKILL.md`
- Modify: `/home/jack/.config/opencode/skill/writing-plans/SKILL.md`
- Modify: `/home/jack/.config/opencode/skill/systematic-debugging/SKILL.md`
- Modify: `/home/jack/.config/opencode/skill/subagent-driven-development/code-quality-reviewer-prompt.md`
- Modify: `/home/jack/.config/opencode/skill/subagent-driven-development/SKILL.md`
- Modify: `/home/jack/.config/opencode/skill/requesting-code-review/SKILL.md`
- Modify: `/home/jack/.config/opencode/skill/executing-plans/SKILL.md`
- Modify: `/home/jack/.config/opencode/skill/brainstorming/SKILL.md`

**Step 1: For each file, replace according to the mapping table**

Apply only exact replacements from the mapping table:
- `superpowers:<known-skill>` → `skill:<known-skill>`

Notes:
- Prefer an explicit, deterministic replace list rather than replacing every `superpowers:` blindly, to avoid accidental changes to unrelated text.

**Step 2: Handle the hooks path reference**

In: `/home/jack/.config/opencode/skill/subagent-driven-development/SKILL.md`

Locate string:
- `~/.config/superpowers/hooks/`

Choose ONE option:
- **Option A (preferred if hooks are under opencode now):** change to `~/.config/opencode/hooks/`
- **Option B (compat):** keep the path but add a sentence explaining legacy location / compatibility and where the new location is (if applicable).

**Step 3: Verify replacements landed**

Run:
```bash
rg -n "superpowers:" "/home/jack/.config/opencode/skill" || true
```
Expected: no matches.

**Step 4: Commit**

```bash
git add "/home/jack/.config/opencode/skill/writing-skills/testing-skills-with-subagents.md" \
        "/home/jack/.config/opencode/skill/writing-skills/SKILL.md" \
        "/home/jack/.config/opencode/skill/writing-plans/SKILL.md" \
        "/home/jack/.config/opencode/skill/systematic-debugging/SKILL.md" \
        "/home/jack/.config/opencode/skill/subagent-driven-development/code-quality-reviewer-prompt.md" \
        "/home/jack/.config/opencode/skill/subagent-driven-development/SKILL.md" \
        "/home/jack/.config/opencode/skill/requesting-code-review/SKILL.md" \
        "/home/jack/.config/opencode/skill/executing-plans/SKILL.md" \
        "/home/jack/.config/opencode/skill/brainstorming/SKILL.md"
git commit -m "refactor(skills): migrate superpowers cross-references to skill:"
```

---

### Task 4: Verify there are no remaining “superpowers” references

**Files:**
- Scan: `/home/jack/.config/opencode/skill/**`

**Step 1: Search for any remaining occurrences**

Run:
```bash
rg -n "superpowers" "/home/jack/.config/opencode/skill" || true
```
Expected: no matches.

**Step 2: Search for old directory name references**

Run:
```bash
rg -n "using-superpowers" "/home/jack/.config/opencode/skill" || true
```
Expected: no matches.

**Step 3: If matches exist**

- Fix remaining refs by updating them to the new terms.
- Re-run the searches until clean.
- Commit:
```bash
git add -A
git commit -m "chore(skills): remove remaining superpowers references"
```

---

### Task 5: Smoke test skill loading still works

**Files:**
- No code changes expected; test only.

**Step 1: Identify how skills are loaded in this environment**

If there is a CLI or runner (examples):
- `opencode` CLI
- a nushell script
- a local loader script

Run whichever applies; examples:
```bash
# Example: list skills (replace with real command if different)
opencode skill list

# Example: load a specific skill (replace with real command if different)
opencode skill show writing-plans
```
Expected: commands succeed and reflect:
- the renamed skill is now discoverable as `skill-invocation-policy`
- cross-references use `skill:<name>`

**Step 2: Minimal end-to-end check**

- Trigger any codepath that reads the plan header reference (in `writing-plans/SKILL.md`) and ensure it still resolves.

**Step 3: If it fails**

- Capture the exact error output.
- Verify the loader logic for:
  - reading directories as skill IDs
  - reading `name:` field
  - cross-reference parsing for `skill:`

Then create a focused follow-up plan (or patch) for loader updates.

---

## Acceptance Criteria

- `/home/jack/.config/opencode/skill/skill-invocation-policy/` exists and `/home/jack/.config/opencode/skill/using-superpowers/` no longer exists.
- The renamed skill’s `SKILL.md` contains `name: skill-invocation-policy`.
- All occurrences of `superpowers:<skill>` listed in the mapping table are replaced with `skill:<skill>` in the specified files.
- `rg -n "superpowers" /home/jack/.config/opencode/skill` returns no matches.
- Skill loading smoke test succeeds and the renamed skill is discoverable.
