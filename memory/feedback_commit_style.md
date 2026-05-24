---
name: feedback-commit-style
description: Commit message formatting rules for this repo
metadata:
  type: feedback
---

Keep commit titles ≤50 characters.

**Why:** User enforces this strictly — corrected every title over 50 chars.
**How to apply:** Always run `echo -n "title" | wc -c` mentally before finalizing. Scope prefix (e.g. `fix:`, `feat:`) counts toward the limit.
