---
name: transcript-to-artifact
description: Transform meeting transcripts into structured artifact (TL;DR, decisions, action items, follow-ups). Use when processing meeting recordings, transcripts, or when user mentions "transcript", "meeting notes", or "extract from meeting".
---

# Transcript to Artifact

Extracts structured, reusable artifacts from raw meeting transcripts.

## Prerequisites

- Raw transcript text (from Zoom, Teams, Otter, Whisper, etc.)
- Target date folder in `Daily Projects/YYYY-MM-DD/`

## Steps

### 1. Receive Transcript

Accept transcript as:
- Pasted text in conversation
- File path to `Transcripts/*.txt` or `Transcripts/*.md`

### 2. Extract Structured Content

Parse the transcript and extract:

| Artifact | Description |
|----------|-------------|
| TL;DR | 2-3 sentence summary |
| Key Discussion Points | Major topics with context |
| Decisions | Conclusions reached, agreements made |
| Action Items | Tasks with owners and deadlines |
| Follow-ups | Next steps, future meetings |
| References | Links, resources, tools mentioned |

See [extraction-template.md](references/extraction-template.md) for the full prompt template.

### 3. Generate Meeting Note

Create file: `Daily Projects/YYYY-MM-DD/NN-meeting-<topic>.md`

Structure:
```markdown
# Meeting Transcript - <Topic>

## TL;DR
[2-3 sentences]

## Key Discussion Points
### [Topic 1]
- Point...

## Action Items
- [ ] **@owner** - Task description

## Follow-up Items
- Item...

## References, Resources, and Links Mentioned
- [Resource](url)

---
**Attendees**: @handle1, @handle2
**Meeting Type**: [sync/planning/retro/etc.]
```

### 4. Identify Propagation Targets

Flag content for downstream destinations:

| Content Type | Destination |
|--------------|-------------|
| Wins/ships | `Snippets/` |
| Risks/blockers | `Executive Summaries/` |
| Project decisions | `Projects/<slug>/` |
| Weekly priorities | `Weekly Notes/` |

### 5. Link and Archive

- Add `[[wikilinks]]` connecting to related notes
- If transcript file exists, note: "Archive to `Archive/` after review"

## Output

Produces:
- Structured meeting note in `Daily Projects/YYYY-MM-DD/`
- List of propagation suggestions
- Archive recommendation for raw transcript

## Verification

- [ ] TL;DR is 2-3 sentences max
- [ ] All action items have owners (@handle format)
- [ ] Attendees listed at bottom
- [ ] File saved with correct naming: `NN-meeting-<topic>.md`

## Example Usage

"Process this meeting transcript and extract action items"
"Turn this Zoom/Teams/Meet transcript into meeting notes"
"Extract artifacts from my 1:1 with @monalisa"
