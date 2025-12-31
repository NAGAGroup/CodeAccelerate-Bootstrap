---
name: using-git-worktrees
description: Use when starting feature work, setting up fork, or creating isolated workspaces in NEO project
---

# Using Git Worktrees (NEO Project)

## Overview

This project uses a **custom worktree system** with pixi commands and symlink switching. Do NOT use raw `git worktree` commands.

**Core principle:** Worktrees are managed via pixi commands that handle symlinks, build isolation, and install directories automatically.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace for NEO development."

## Fork Setup (One-Time)

Before creating worktrees, set up your fork:

```bash
pixi run -e dev setup-fork https://github.com/USER/compute-runtime.git
```

This:
- Renames `origin` → `upstream` (Intel canonical)
- Adds your fork as `origin`
- Stores fork URL in `scripts/activation/env.user.nu`

Run once after initial `pixi run sync-neo`.

## Key Differences from Standard Git Worktrees

| Standard Git | This Project |
|--------------|--------------|
| `git worktree add` | `pixi run -e dev create-worktree` |
| `cd src/neo-branch` | `pixi run -e dev switch-worktree branch` |
| `git worktree remove` | `pixi run -e dev remove-worktree` |
| Manual build dir management | Automatic isolation for all worktrees |

## Symlink Structure

After running `setup-fork`, the source structure becomes:

```
src/
  neo-main/        # Original NEO checkout (renamed from neo/)
  neo -> neo-main  # Symlink to active worktree
  neo-<branch>/    # Additional worktree checkouts
build/
  dev-main/        # Isolated build directories per worktree
  dev-<branch>/
install/
  dev-main/        # Isolated install directories per worktree  
  dev-<branch>/
.pixi/
  envs/
    dev -> ../../install/dev-main  # Symlink switches with worktree
```

The build system always builds from `src/neo`, and pixi environment points to the active worktree's install directory.

## Commands Reference

### Create Worktree

```bash
pixi run -e dev create-worktree <name> [--from <branch>]
```

All worktrees are isolated with separate build and install directories.

| Flag | Description |
|------|-------------|
| `--from <branch>` | Base branch (default: current branch) |

**Examples:**
```bash
# Create worktree from current branch
pixi run -e dev create-worktree fix-memory-leak

# Create worktree from specific branch
pixi run -e dev create-worktree hotfix --from main
```

### Switch Worktree

```bash
pixi run -e dev switch-worktree <name>
```

This swaps the `src/neo` symlink and `.pixi/envs/dev` symlink, then refreshes the pixi environment (fast from cache).

**Examples:**
```bash
# Switch to a feature worktree
pixi run -e dev switch-worktree fix-memory-leak

# Switch back to main checkout
pixi run -e dev switch-worktree main
```

### List Worktrees

```bash
pixi run -e dev list-worktrees
```

Shows all worktrees with branch, path, build mode, and active status (`*` = active).

### Current Worktree

```bash
pixi run -e dev current-worktree
```

Quick status showing active worktree name and build directory.

### Remove Worktree

```bash
pixi run -e dev remove-worktree <name> [--yes]
```

- Automatically switches to main if removing the active worktree
- Use `--yes` to skip confirmation

## Workflow: Starting Feature Work

### 1. Ensure Fork is Setup (One-Time)

```bash
pixi run -e dev setup-fork
```

This must be done before creating worktrees. It converts `src/neo/` to `src/neo-main/` with symlink.

### 2. Check Current State

```bash
pixi run -e dev current-worktree
pixi run -e dev list-worktrees
```

### 3. Create Worktree

```bash
pixi run -e dev create-worktree feature-name
```

### 4. Switch to Worktree

```bash
pixi run -e dev switch-worktree feature-name
```

This automatically refreshes the pixi environment (fast from cache).

### 5. Build and Test

```bash
pixi run -e dev configure
pixi run -e dev build
pixi run -e dev install
```

ULTs run automatically with build. The build uses whatever `src/neo` points to.

### 6. Report Ready

```
Worktree ready: feature-name
Build directory: build/dev-feature-name
Ready to implement <feature>
```

## Workflow: A/B Benchmarking

All worktrees are isolated, so any two worktrees can be used for A/B comparison:

```bash
# Create isolated worktrees for both versions
pixi run -e dev create-worktree baseline --from embargo
pixi run -e dev create-worktree optimized --from embargo

# Build baseline
pixi run -e dev switch-worktree baseline
pixi run -e dev configure && pixi run -e dev build && pixi run -e dev install

# Build optimized (make changes first)
pixi run -e dev switch-worktree optimized
# ... make optimization changes ...
pixi run -e dev configure && pixi run -e dev build && pixi run -e dev install

# Run benchmarks - switching automatically updates environment
pixi run -e dev switch-worktree baseline
./run_benchmark.sh

pixi run -e dev switch-worktree optimized  
./run_benchmark.sh
```

## Workflow: Finishing Work

When done with a worktree:

```bash
# Switch back to main
pixi run -e dev switch-worktree main

# Remove the worktree
pixi run -e dev remove-worktree feature-name --yes

# Clean isolated build directories if needed
pixi run -e dev clean-build --all-isolated --yes
```

## Common Mistakes

**Using raw git worktree commands**
- **Problem:** Bypasses symlink system, build system won't see the worktree
- **Fix:** Always use `pixi run -e dev create-worktree`

**Forgetting to run setup-fork first**
- **Problem:** Worktree commands fail because `src/neo` is not a symlink
- **Fix:** Run `pixi run -e dev setup-fork` once after initial clone

**Forgetting to switch worktree**
- **Problem:** Building in wrong worktree
- **Fix:** Run `current-worktree` before building to verify

**Manual switching by changing directories only**
- **Problem:** Build system follows `src/neo` symlink, pixi env doesn't update
- **Fix:** Use `switch-worktree` command to switch both symlinks

**Not running configure after switch**
- **Problem:** CMake cache points to wrong build directory
- **Fix:** Always run `pixi run -e dev configure` after switching

## Quick Reference

| Task | Command |
|------|---------|
| Setup fork (required first) | `pixi run -e dev setup-fork` |
| Create worktree | `pixi run -e dev create-worktree NAME` |
| Create from branch | `pixi run -e dev create-worktree NAME --from BRANCH` |
| Switch worktree | `pixi run -e dev switch-worktree NAME` |
| Switch to main | `pixi run -e dev switch-worktree main` |
| List all worktrees | `pixi run -e dev list-worktrees` |
| Show current | `pixi run -e dev current-worktree` |
| Remove worktree | `pixi run -e dev remove-worktree NAME` |
| Clean isolated builds | `pixi run -e dev clean-build --all-isolated` |

## Red Flags

**Never:**
- Use `git worktree add/remove` directly
- Manually create directories in `src/neo-*`
- Assume `cd src/neo-x` means that's what will build
- Skip `setup-fork` - it's required for worktree workflow


**Always:**
- Run `setup-fork` once after initial clone
- Use pixi commands for all worktree operations
- Run `switch-worktree` before building a different branch
- Run `configure` after switching to update CMake cache
- Check `current-worktree` if unsure what's active
