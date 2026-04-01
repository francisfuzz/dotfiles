---
name: engineering-brief
description: Define constraints, risks, and success metrics before building. Use this to establish project boundaries and feasibility upfront.
---

# Engineering Project Brief

Use this skill to establish clear constraints, goals, and risk assessment before starting development. Fill this out cold, then share with Claude or your team to validate feasibility and uncover hidden assumptions.

## When to Use

- **Starting a new project** – Lock in constraints and success metrics
- **Major refactoring** – Define scope and risk tolerance upfront
- **Scaling work** – Document what scaling constraints exist
- **Team alignment** – Get shared understanding of what you're building

## The Brief

### Constraints
- **Timeline**: [days/weeks/months]
- **Team size**: [number of engineers]
- **Technical debt tolerance**: [high/medium/low]
- **Maintenance burden**: [acceptable/minimal]

### Goal
- **Success metric**: [specific, measurable outcome] (e.g., "deploy and serve 1k users" vs "reduce latency by 30%")
- **Business impact**: [What does this enable? Who benefits?]

### Technical Unknowns
- [Uncertainty 1]
- [Uncertainty 2]
- [Any experimental or novel parts of the design]

### Risk Assessment
- **Single point of failure**: [What breaks this completely?]
- **Scaling constraint**: [What stops it from growing beyond X?]
- **Dependency risk**: [What if X library/service fails?]

## How to Use

1. **Fill it out alone** – Write answers without team input first
2. **Review with Claude** – Paste into Claude and ask: "Does this brief make sense? What am I missing?"
3. **Align with team** – Share outcomes and get feedback
4. **Refine** – Update based on feedback, especially around risks
5. **Use as reference** – Keep this brief updated as project evolves

## Example: Web Application

```
Constraints:
- Timeline: 4 weeks
- Team size: 2 engineers
- Technical debt tolerance: low (shipping MVP)
- Maintenance burden: minimal (will hand off)

Goal:
- Success metric: MVP deployed with 100 users signed up, <2s page load
- Business impact: Validate market demand before Series A

Technical Unknowns:
- Can we batch process payments efficiently?
- Will our current hosting handle spike traffic?

Risk Assessment:
- Single point of failure: Payment processor downtime (0.1% SLA)
- Scaling constraint: Database connections at 1k concurrent users
- Dependency risk: If email service fails, no password resets
```

## Next Steps

After completing the brief:
- If you want deep discovery: Use the **interview** skill for Socratic questioning
- If you're ready to build: Create a detailed specification using your brief as context
- If it's business-focused: Use **venture-feasibility** instead to validate ROI

---

**Pro tip**: The more specific your metrics, the clearer your trade-offs. "We need it fast" is hard to optimize for; "< 2s load time at 1k concurrent users" is crystal clear.
