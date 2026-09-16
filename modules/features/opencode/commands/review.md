---
description: Review the current working-tree diff with the read-only reviewer
agent: reviewer
---

Review the current uncommitted changes$ARGUMENTS.

Use `git diff` and `git diff --staged` to get the diff, then read the full context of every modified file. Only flag issues introduced by these changes.

End with:

- **Verdict** - correct or incorrect, with confidence.
- **Findings** - `[P0-P3][confidence] path:line` - title, then bug, trigger, and impact.
