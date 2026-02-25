---
name: engineering-brief
description: Define constraints, risks, and success metrics before building. Use this to establish project boundaries and feasibility upfront.
---

# Engineering Project Brief

Establish clear constraints, goals, and risk assessment before starting development. Fill out cold, then validate feasibility and uncover hidden assumptions.

## The Brief

### Constraints
- **Timeline**: [days/weeks/months]
- **Team size**: [number of engineers]
- **Technical debt tolerance**: [high/medium/low]
- **Maintenance burden**: [acceptable/minimal]

### Goal
- **Success metric**: specific, measurable outcome (e.g., "deploy and serve 1k users" or "reduce latency by 30%")
- **Business impact**: what this enables and who benefits

### Technical Unknowns
- [Uncertainty 1]
- [Uncertainty 2]
- [Any experimental or novel design elements]

### Risk Assessment
- **Single point of failure**: what breaks this completely?
- **Scaling constraint**: what stops growth beyond X?
- **Dependency risk**: what if X library/service fails?

## Workflow

1. **Fill it out alone** — write answers without team input first
2. **Review with Claude** — "Does this brief make sense? What am I missing?"
3. **Align with team** — share outcomes and get feedback
4. **Refine** — update based on feedback, especially around risks
5. **Keep as reference** — update as the project evolves

## Output

```markdown
## Engineering Brief: <project>

### Constraints
[filled from brief]

### Goal & Success Metric
[specific measurable outcome]

### Risks
[top risks with mitigation approach]

### Unknowns
[key uncertainties and how to resolve them]
```

## Next Steps

- Deep discovery needed → use **interview** skill for Socratic questioning
- Ready to build → create a detailed specification using this brief as context
- Business-focused → use **venture-feasibility** to validate ROI instead
