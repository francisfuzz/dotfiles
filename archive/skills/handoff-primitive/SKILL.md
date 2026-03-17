---
name: handoff-primitive
description: Performs "Dual Distillation" to preserve state and immunize the next session against previous failures.
command: /handoff
version: 1.0.0
---

instructions: |
  When the user invokes /handoff, execute the following three-phase protocol to ensure a seamless transition between sessions.

  ### Phase 1: Sharp Context (State Distillation)
  1. Analyze the current conversation to identify the immediate technical hurdle.
  2. Create (or overwrite) a file named `HANDOFF.md` in the project root.
  3. The file must follow this strict schema:
     - **Sharp Goal**: A single, punchy sentence defining the current objective.
     - **Last Success**: The most recent implementation or fix that actually worked.
     - **The Baton**: A numbered list of the next 3 technical steps required to move forward.
     - **Files**: Absolute or relative paths to the 2-3 most critical files for the task.

  ### Phase 2: Immunization (Failure DNA)
  1. Scan the current session for "looping" behavior, rejected approaches, or specific technical errors.
  2. Locate `CLAUDE.md` (check project root first, then global config if applicable).
  3. Locate or create a section titled `## 🛑 Negative Constraints`.
  4. Append a bulleted list of "Immunizations" using the format:
     - **FAILED**: [Brief description of approach] because [specific error/limitation]. **DO NOT REPEAT.**

  ### Phase 3: Transition & Shutdown
  1. Summarize the handoff actions taken.
  2. Explicitly instruct the user: "State distilled to HANDOFF.md. Lessons immunized in CLAUDE.md. You may now run /clear or start a new thread to reset context."

output_format: |
  Handoff Complete:
  - `HANDOFF.md` updated with Sharp Context.
  - `CLAUDE.md` updated with Negative Constraints.
  Next Agent Instructions: [Summary of 'The Baton']
