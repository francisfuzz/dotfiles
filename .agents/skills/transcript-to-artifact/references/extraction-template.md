# Extraction Template

Use this prompt template when processing transcripts:

```
Given this meeting transcript, extract the following into GitHub-flavored Markdown:

1. **TL;DR** (2-3 sentences max)
2. **Key Discussion Points** (grouped by topic with bullet details)
3. **Decisions Made** (bullet list of conclusions/agreements)
4. **Action Items** (format: `- [ ] **@owner** - task description [deadline if mentioned]`)
5. **Follow-up Items** (next steps, future meetings, parking lot items)
6. **References** (links, tools, resources, documents mentioned)
7. **Non-obvious Analysis** (3 questions that probe edges, surface contradictions, challenge assumptions)

Additional extraction rules:
- Attribute quotes to speakers when important
- Flag risks with [RISK] prefix
- Flag decisions with [DECISION] prefix
- Note any unresolved debates or open questions
- Identify implicit commitments (things promised but not formally assigned)

Transcript:
[paste transcript here]
```

## Artifact Definitions

### TL;DR
- Maximum 3 sentences
- Lead with the primary outcome or decision
- Include the "so what" - why this meeting mattered

### Key Discussion Points
- Group related items under topic headings
- Use `###` for topic headers
- Include enough context for someone who wasn't there

### Decisions Made
- Only include firm decisions, not "we discussed..."
- Note who made or approved the decision if relevant
- Include any conditions or caveats

### Action Items
- Must have an owner (use @handle)
- Include deadline if mentioned
- Be specific enough to be actionable
- Format: `- [ ] **@owner** - Task description`

### Follow-up Items
- Future meeting topics
- Items explicitly deferred
- "Parking lot" items
- Dependencies on external events

### References
- Links mentioned (even partial URLs)
- Documents referenced
- Tools or products discussed
- External resources to review

## Quality Checks

Before finalizing:
- [ ] Can someone understand the meeting outcome without reading the full transcript?
- [ ] Are all action items specific and assigned?
- [ ] Are decisions clearly distinguished from discussions?
- [ ] Is the TL;DR actually brief?
