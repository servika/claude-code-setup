---
description: Create structured meeting notes with parallel extraction of decisions, actions, and topics
model: sonnet
---

# /meeting-notes

Create structured meeting notes from raw notes or transcripts, using three parallel agents to extract decisions, action items, and topic summaries.

## When to Use This Skill

- Processing raw meeting notes into structured format
- Extracting action items from lengthy discussions
- Creating shareable meeting summaries
- Building a decision log from meetings

## Usage

```
/meeting-notes <input> [--type standup|planning|retro|general] [--attendees <list>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| input | Raw notes text, file path, or transcript | Yes | — |
| type | Meeting type (affects extraction focus) | No | general |
| attendees | Comma-separated attendee list | No | Extract from notes |

## Instructions

### Phase 1: Parse Input

1. Read the raw meeting notes or transcript
2. Identify attendees (from notes or parameter)
3. Extract meeting metadata (date, time, duration, topic)
4. Prepare clean text for agent processing

### Phase 2: Parallel Extraction (Agent Team)

Launch 3 agents using the Task tool:

**Agent 1: Decision Extractor** (Sonnet)
Task: Find all decisions made during the meeting
- Identify explicit decisions ("we decided to...", "agreed that...")
- Identify implicit decisions (consensus reached without formal statement)
- For each decision: what was decided, who was involved, rationale if stated
- Flag decisions that need follow-up or formalisation (e.g., ADR needed)
Return: Numbered decision list with context

**Agent 2: Action Item Extractor** (Haiku)
Task: Find all action items and commitments
- Identify tasks assigned ("John will...", "need to...", "TODO:")
- For each: description, owner, deadline (if mentioned), priority
- Flag items without clear owners
- Identify blocked items and dependencies
Return: Action item list with owner and deadline

**Agent 3: Topic Summariser** (Haiku)
Task: Summarise discussion topics
- Break meeting into logical discussion topics
- Summarise each topic in 2-3 sentences
- Note any unresolved questions or parking lot items
- Identify topics that need follow-up meetings
Return: Topic summary list

### Phase 3: Compile Meeting Notes

1. Merge agent outputs into structured document
2. Add metadata header
3. Format for easy scanning (tables for actions, numbered lists for decisions)

## Output Format

```markdown
# Meeting Notes: [Topic/Title]

**Date**: [Date] | **Duration**: [Length] | **Type**: [Type]
**Attendees**: [Names]

## Summary
[2-3 sentence overview of the meeting]

## Decisions

| # | Decision | Rationale | Follow-up |
|---|----------|-----------|-----------|
| 1 | [What was decided] | [Why] | [ADR needed?] |

## Action Items

| # | Action | Owner | Deadline | Status |
|---|--------|-------|----------|--------|
| 1 | [Task] | @name | [Date] | Pending |

## Discussion Topics

### [Topic 1]
[Summary of discussion]

### [Topic 2]
[Summary of discussion]

## Parking Lot
- [Items deferred to future meetings]

## Next Meeting
**Date**: [Date] | **Agenda**: [Preliminary topics]
```

## Examples

### Example 1: General Meeting
```
/meeting-notes "We discussed the auth migration. John will update the JWT config by Friday. Decided to use refresh tokens with 7-day expiry. Sarah raised concerns about session management..."
```

### Example 2: Sprint Planning
```
/meeting-notes notes/sprint-15-planning.md --type planning --attendees "John, Sarah, Mike"
```
