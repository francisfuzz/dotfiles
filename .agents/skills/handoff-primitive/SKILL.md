---
name: handoff-primitive
description: Performs "Dual Distillation" to preserve state and immunize the next session against previous failures.
command: /handoff
version: 1.0.0
---

instructions: |
  When the user invokes /handoff, execute this three-phase protocol for seamless session transition.

  ### Phase 1: Sharp Context (State Distillation)
  1. Analyze the current conversation to identify the immediate technical hurdle.
  2. Create or overwrite `HANDOFF.md` in the project root with this schema:
     - **Sharp Goal**: Single sentence defining the current objective.
     - **Last Success**: Most recent implementation or fix that worked.
     - **The Baton**: Numbered list of the next 3 technical steps.
     - **Files**: 2-3 most critical file paths for the task.

  ### Phase 2: Immunization (Failure DNA)
  1. Scan the session for looping behavior, rejected approaches, or specific errors.
  2. Locate `CLAUDE.md` (project root first, then global config).
  3. Find or create a `## 🛑 Negative Constraints` section.
  4. Append immunizations: `- **FAILED**: [approach] because [error/limitation]. **DO NOT REPEAT.**`

  ### Phase 3: Transition
  1. Summarize handoff actions taken.
  2. Tell user: "State distilled to HANDOFF.md. Lessons immunized in CLAUDE.md. Run /clear or start a new thread to reset context."

output_format: |
  Handoff Complete:
  - `HANDOFF.md` updated with Sharp Context.
  - `CLAUDE.md` updated with Negative Constraints.
  Next Agent Instructions: [Summary of 'The Baton']
