# Claude Commands

**For:** Engineers and founders who want better specs, not just more AI output. 

**Why:** AI tools default to giving you answers.  These commands force you to ask better questions first—clarifying constraints, challenging assumptions, and doing the math before building.

## What's Inside

- **`engineering-brief.md`** — Define constraints, risks, and success metrics before writing code
- **`interview.md`** — Turn vague ideas into complete project specs through Socratic questioning
- **`venture-feasability-brief.md`** — Reality-check business ideas with math before investing time

## Quick Start

### For Engineering Projects

1. **Fill out `engineering-brief.md`** with your constraints and goals
2. **Share it with Claude** and ask:  "Does this brief make sense?"
3. **Run interview mode**:  Copy `interview.md` into Claude with your brief as context
4. **Get a spec**: Claude will ask deep questions, then write a complete specification

### For Business Ideas

1. **Fill out `venture-feasability-brief.md`** with your constraints and math
2. **Share it with Claude** and ask: "Does the math check out?"
3. **Run interview mode**: Copy `interview.md` into Claude with your brief
4. **Get validation**: Claude will probe assumptions and suggest alternatives

## Example Usage

```bash
# Copy a brief template
cp .claude/commands/engineering-brief.md my-project-brief.md

# Fill it out, then paste both into Claude: 
# "Here's my brief [paste].  Now run /interview mode [paste interview.md]"
```

## Why This Works

These templates prevent:
- ❌ Building the wrong thing because you didn't define success upfront
- ❌ Getting stuck mid-project because you didn't identify risks early
- ❌ Wasting weeks on ideas that fail basic math checks

They produce:
- ✅ Complete specs with edge cases, risks, and metrics
- ✅ Clear go/no-go decisions based on constraints
- ✅ Documentation you can hand to teammates or yourself in 6 months

---

**Tip:** Start with the briefs.  They're templates for *your* thinking—Claude just helps validate it. 
