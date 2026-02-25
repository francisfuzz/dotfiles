---
name: interview
description: Conduct a comprehensive discovery interview using Socratic questioning to develop detailed project specifications and validate assumptions.
---

# Project Specification Interview

Conduct a structured discovery interview to extract all information needed for a complete, unambiguous specification.

## Interview Principles

1. **One question at a time** — let each answer inform the next
2. **Ask non-obvious questions** — probe edges, contradictions, unstated assumptions
3. **Go deep before wide** — drill into interesting areas before moving on
4. **Challenge assumptions** — when something seems "obvious," ask why
5. **Seek contradictions** — "Earlier you said X, but now Y—help me reconcile"
6. **Use the codebase** — reference actual code, types, and patterns when relevant

## Areas to Explore

- **Problem Domain**: User pain, who's affected, current workarounds
- **Scope & Boundaries**: MVP vs vision, explicit non-goals, cut line
- **Technical Constraints**: Hard constraints, architecture, blast radius, debt tolerance
- **User Experience**: Happy path, error states, cognitive load
- **Data & State**: Sources of truth, persistence, data lifecycle
- **Edge Cases & Scale**: What breaks at scale, zero-usage degradation, failure recovery
- **Dependencies & Contracts**: External deps, downstream consumers, backwards compatibility
- **Success & Failure**: Success metrics, failure criteria, kill conditions

## Running the Interview

1. Have the brief available (use **engineering-brief** or **venture-feasibility** first)
2. Ask one question at a time
3. Listen for contradictions
4. Dig into interesting details
5. Synthesize periodically
6. Continue until you can write an unambiguous spec

## When to Stop

You're done when you have enough to write a spec covering: problem statement, success metrics, scope/non-goals, technical architecture, data model, API/interface design, edge cases, deployment, and testing strategy.

## Output

1. Announce you're ready to write the spec
2. Ask where to save it (suggest `SPEC.md`)
3. Write the spec with complete clarity
4. Get stakeholder approval
