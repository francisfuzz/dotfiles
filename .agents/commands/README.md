# Claude Commands

**For:** Engineers and founders who want better specs, not just more AI output.

**Why:** AI tools default to giving you answers. These commands force you to ask better questions first—clarifying constraints, challenging assumptions, and doing the math before building.

## What's Inside

These commands have been migrated to skills for better integration with AI agents:

- **`start-work.md`** — Reference to the start-work skill; begin work on GitHub issues with discovery and TDD

## Migrated to Skills

The following commands are now available as skills and can be invoked with `/skills`:

- **`engineering-brief`** — Define constraints, risks, and success metrics before writing code
- **`interview`** — Turn vague ideas into complete project specs through Socratic questioning  
- **`venture-feasibility`** — Reality-check business ideas with math before investing time

See `.agents/skills/` for the full skill definitions.

## Quick Start

### For Engineering Projects

1. **Run the engineering-brief skill** – Use `/skills info engineering-brief` to see the full template
2. **Fill out your brief** with your constraints and goals
3. **Share it with Claude** and ask: "Does this brief make sense?"
4. **Run the interview skill** – Use `/skills info interview` with your brief as context
5. **Get a spec** – Claude will ask deep questions, then write a complete specification

### For Business Ideas

1. **Run the venture-feasibility skill** – Use `/skills info venture-feasibility` to see the full template
2. **Fill out your brief** with your constraints and math
3. **Share it with Claude** and ask: "Does the math check out?"
4. **Run the interview skill** – Use `/skills info interview` with your brief
5. **Get validation** – Claude will probe assumptions and suggest alternatives

## Why This Works

These tools prevent:
- ❌ Building the wrong thing because you didn't define success upfront
- ❌ Getting stuck mid-project because you didn't identify risks early
- ❌ Wasting weeks on ideas that fail basic math checks

They produce:
- ✅ Complete specs with edge cases, risks, and metrics
- ✅ Clear go/no-go decisions based on constraints
- ✅ Documentation you can hand to teammates or yourself in 6 months

---

**Tip:** Start with the briefs. They're templates for *your* thinking—Claude just helps validate it.

