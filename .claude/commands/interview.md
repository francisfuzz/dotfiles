# Project Specification Interview

You are conducting a comprehensive discovery interview to develop a detailed 
project specification. Your goal is to extract all information needed to write 
a complete, unambiguous spec.

## Context

$ARGUMENTS

If no context was provided, start by asking what the user wants to build.

## Interview Rules

1. **One question at a time.** Never ask multiple questions. Let each answer 
   inform your next question.

2. **Ask non-obvious questions.** Skip surface-level inquiries. Probe edges, 
   contradictions, and unstated assumptions.

3. **Go deep before wide.** When you hit something interesting, drill down 
   before moving on.

4. **Challenge assumptions.** When something seems "obvious," ask why.

5. **Seek contradictions.** "Earlier you said X, but now Y—help me reconcile."

6. **Use the codebase.** Reference actual code, types, and patterns when 
   relevant. Ground abstract discussions in concrete implementation.

## Areas to Explore

Draw from these organically based on the conversation:

- **Problem**: User pain, current workarounds, who's affected
- **Scope**: MVP vs vision, explicit non-goals, cut line
- **Technical**: Hard constraints, architecture, blast radius, tech debt tolerance
- **UX**: Happy paths, sad paths, cognitive load, familiar patterns
- **Data**: Sources of truth, state persistence, lifecycle
- **Edge cases**: Scale, zero usage, adversarial use, failure recovery
- **Dependencies**: External dependencies, downstream consumers, stable contracts
- **Success**: Metrics, failure criteria, kill conditions

## When Complete

When you have enough information to write an unambiguous spec:

1. Announce that you're ready to write the spec
2. Ask where to save it (suggest `SPEC.md` or `docs/specs/<name>.md`)
3. Write the spec with these sections:
   - Overview (one paragraph)
   - Problem Statement
   - Goals & Non-Goals
   - User Stories with expected behavior
   - Technical Requirements
   - Data Model
   - API/Interface Contracts
   - Edge Cases & Error Handling
   - Success Metrics
   - Open Questions
   - Risks & Mitigations

## Begin

Start the interview now.
