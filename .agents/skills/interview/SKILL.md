---
name: interview
description: "Conduct a comprehensive discovery interview using Socratic questioning to develop detailed project specifications and validate assumptions. Use this skill whenever the user mentions needing a spec, brief, PRD, or plan; wants to turn vague requirements into something concrete; says things like \"help me think through this\", \"I have an idea but don't know where to start\", \"can you interview me\", or wants to surface hidden assumptions before building anything. Also trigger when a user shares a brief or idea and wants structured discovery before writing a specification document. Works for any domain: engineering, design, product, research, writing, and more."
argument-hint: [topic | context]
---

# Project Discovery Interview

Use this skill to conduct a deep, structured discovery interview that extracts all information needed to write a complete, unambiguous document of record — whether that's an engineering spec, a PRD, a design brief, a research plan, or something else entirely.

## When to Use

* **Vague requirements** – Turn "build a dashboard" or "write a report" into a complete, actionable plan
* **Uncovering unknowns** – Surface hidden assumptions and contradictions
* **Document creation** – Interview output becomes your spec, brief, or plan
* **Alignment** – Ensure shared understanding before starting

## Interview Principles

1. **One question at a time** – Never ask multiple questions. Let each answer inform your next question.
2. **Ask non-obvious questions** – Skip surface-level inquiries. Probe edges, contradictions, and unstated assumptions.
3. **Go deep before wide** – When you hit something interesting, drill down before moving on.
4. **Challenge assumptions** – When something seems "obvious," ask why.
5. **Seek contradictions** – "Earlier you said X, but now Y—help me reconcile."
6. **Use available context** – Reference actual artifacts (code, designs, docs, data) when relevant to the domain.

## Areas to Explore

Adapt these to the domain. Not all areas apply to every project — use judgment.

### Problem Domain

* What's the pain or current workaround?
* Who's affected, and how?
* How is this currently handled?

### Scope & Boundaries

* What's the minimum viable version vs. the full vision?
* What are explicit non-goals?
* Where's the cut line?

### Constraints & Tradeoffs

* What are the hard constraints (time, resources, technology, audience)?
* What tradeoffs are acceptable?
* What's the cost of getting this wrong?

### People & Experience

* Who are the end users or audience?
* What's the intended experience or journey?
* What are the failure states or pain points to avoid?

### Information & State

* What are the sources of truth?
* What needs to be tracked, stored, or remembered?
* What's the lifecycle of the core information?

### Edge Cases & Resilience

* What breaks under stress or at the extremes?
* What happens at zero usage or maximum load?
* How does recovery work when things go wrong?

### Relationships & Dependencies

* What does this depend on externally?
* Who or what depends on this downstream?
* What compatibility or continuity constraints exist?

### Success & Failure

* What does success look like, concretely?
* What would cause this to be abandoned or declared a failure?
* How will you know when you're done?

## Running the Interview

1. Read any existing context (brief, description, prior work)
2. Infer the domain — adjust vocabulary and emphasis accordingly
3. Ask one question at a time
4. Listen for contradictions and dig in
5. Synthesize periodically to confirm shared understanding
6. Continue until you can write an unambiguous document of record

## When to Stop

You're done when you have enough to write a clear document covering:

* Problem statement and success metrics
* Scope and explicit non-goals
* Constraints and key tradeoffs
* Audience or user experience
* Core information model and lifecycle
* Edge cases and failure handling
* Dependencies and relationships
* How progress and completion will be measured

## Output: The Document of Record

1. Announce you're ready to write
2. Ask what format fits best (e.g., SPEC.md, PRD, brief, research plan, outline)
3. Write with complete clarity
4. Get stakeholder sign-off

---

**Pro tip**: The best interviews feel like conversations. Listen more than you talk.
