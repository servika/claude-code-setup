---
description: Process voice meeting recordings and transcripts with speech-to-text correction
model: sonnet
---

# /voice-meeting

Process voice meeting transcripts, correcting speech-to-text errors and extracting structured meeting notes with decisions and action items.

## When to Use This Skill

- Processing auto-generated meeting transcripts (Zoom, Teams, Otter.ai)
- Cleaning up voice-to-text output for documentation
- Creating meeting notes from recorded discussions
- Processing interview transcripts

## Usage

```
/voice-meeting <transcript> [--speakers <list>] [--context <meeting-topic>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| transcript | File path to transcript or raw text | Yes | — |
| speakers | Known speaker names for correction | No | Extract from transcript |
| context | Meeting topic for disambiguation | No | — |

## Instructions

### Phase 1: Clean Transcript

1. Read the raw transcript
2. Apply speech-to-text corrections:
   - Fix common misrecognitions of technical terms (e.g., "react" not "react to", "express" not "express that")
   - Correct project-specific terminology
   - Fix speaker attribution errors if speaker list provided
   - Remove filler words (um, uh, like, you know) for readability
   - Fix sentence boundaries and punctuation
3. If context is provided, use it to disambiguate technical terms

### Phase 2: Structure Content

1. Break transcript into logical segments by topic change
2. Identify speaker turns
3. Highlight key moments:
   - Decisions (explicit agreements)
   - Action items (commitments made)
   - Questions raised (answered and unanswered)
   - Concerns or risks mentioned

### Phase 3: Generate Meeting Notes

Apply the same extraction as `/meeting-notes`:
- Extract decisions, action items, and topic summaries
- Generate clean, structured output

## Output Format

```markdown
# Voice Meeting Notes: [Topic]

**Date**: [Date] | **Duration**: [Length]
**Speakers**: [Names]
**Source**: [Transcript file/service]

## Summary
[2-3 sentence overview]

## Cleaned Transcript Highlights

### [Topic 1] ([Timestamp range])
**[Speaker]**: [Cleaned quote or paraphrase]
**[Speaker]**: [Cleaned quote or paraphrase]

## Decisions
| # | Decision | Speaker | Timestamp |
|---|----------|---------|-----------|
| 1 | [Decision] | [Name] | [MM:SS] |

## Action Items
| # | Action | Owner | Deadline |
|---|--------|-------|----------|
| 1 | [Task] | [Name] | [Date] |

## Open Questions
- [Unanswered question from the meeting]
```

## Examples

### Example 1: Zoom Transcript
```
/voice-meeting transcripts/zoom-2025-01-15.txt --speakers "John,Sarah,Mike" --context "Sprint planning"
```

### Example 2: Raw Paste
```
/voice-meeting "john said we should probably move to the new API version sarah agreed but mentioned we need to update the tests first mike will handle the migration by next week"
```
