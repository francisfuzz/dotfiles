# Full Flow Reflection Loop

Given the following flow, explore the different prompts, skills, and commands that can be delicated per phase.

```
Articulation → Discovery → Explain → Plan → Edit → Review → Refactor → Agent → Monitor → Learn
     ↑                                                                                      |
     └────────────────────── reflection loop ───────────────────────────────────────────────┘
```

## Compacted Context

**Pre-code phases:**

1. **Articulation** - Help user name vague problems/feelings about code
2. **Discovery** - Map codebase, surface patterns, gather context
3. **Explain/Debug** - Understand existing code behavior

**Planning phase:**

4. **Plan** - Design approach with user input

**Execution phases:**

5. **Edit** - Make targeted code changes
6. **Review** - Audit changes (security, performance, tests)
7. **Refactor** - Systematic improvements maintaining behavior

**Autonomous phase:**

8. **Agent** - Multi-step autonomous execution
9. **Monitor** - Track agent progress, enable intervention

**Meta phase:**

10. **Learn** - Explain what was done and why

**Cross-cutting:**

11. **Collaborate** - Adaptive pairing mode adjusting assistance level
12. **Search/Reference** - Find relevant code/docs across codebase

Each should be implementable as distinct command/prompt with clear inputs/outputs. Phases can loop back (Learn → Articulation, Monitor → Review).


