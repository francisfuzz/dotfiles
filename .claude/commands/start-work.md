---
name: start-work
description: Begin work on a GitHub issue with full workflow
arguments:
  - name: issueNumber
    description: The GitHub issue number
    required: true
---

# Start Work on Issue

Use the **start-work** skill to begin work on issue #$ISSUE_NUMBER.

Follow the complete workflow:
- Discovery & research
- Worktree/branch setup
- TDD implementation with linting
- Draft PR creation

Issue: #$ISSUE_NUMBER
