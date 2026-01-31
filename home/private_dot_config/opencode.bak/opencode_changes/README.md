# OpenCode Configuration Sandbox

## Purpose

This directory contains a working copy of the OpenCode configuration for making and testing changes safely before applying them to the live configuration.

**Created:** January 27, 2026

**Current Session:** Tool permission refactor + new tester agent implementation

## What's Included

This sandbox contains a complete copy of:
- `opencode.json` - Main configuration file
- `package.json` - Package dependencies
- `agent/*.md` - All agent definitions
- `skill/*/SKILL.md` - All skill definitions
- `commands/*.md` - All custom commands
- `plugin/*.ts` - All plugin implementations
- `.gitignore` - Git ignore rules

## What's Excluded

The following are intentionally NOT copied:
- `node_modules/` - Dependencies (reinstall if needed with `npm install`)
- `bun.lock` - Lock file (regenerate if needed)

## Workflow

1. **Modify:** Make configuration changes within this directory (`opencode_changes/`)
2. **Test:** Verify changes work as expected in this sandbox environment
3. **Validate:** Ensure no regressions in agent behavior or configuration
4. **Deploy:** Copy *only* the tested, working files back to the parent live directory (`../`)
5. **Commit:** Check the changes into version control

## Safety Notes

- **The live configuration in `/home/jack/.config/opencode/` remains untouched**
- Changes in this sandbox do NOT affect the running OpenCode system
- Always verify changes here before copying back to live config
- Test thoroughly before deployment

## Notes

- This is a working sandbox for iterative development
- After completing the current session's changes, update the "Current Session" field above
- Remove this directory when no longer needed, or keep it for future configuration work
