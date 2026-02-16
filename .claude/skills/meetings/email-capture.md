---
description: Capture email content into structured notes with action item extraction
model: haiku
---

# /email-capture

Convert email content into structured project notes, extracting decisions, action items, and key information. Uses Haiku for fast processing.

## When to Use This Skill

- Capturing important project emails for documentation
- Extracting action items from email threads
- Creating a searchable record of email decisions
- Processing stakeholder communications

## Usage

```
/email-capture <email-content> [--thread true|false]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| email-content | Email text (paste or file path) | Yes | — |
| thread | Is this an email thread (multiple replies) | No | Auto-detect |

## Instructions

### Phase 1: Parse Email

1. Extract metadata: From, To, CC, Date, Subject
2. If thread: separate individual messages, order chronologically
3. Identify the primary topic and purpose

### Phase 2: Extract Information

1. **Key Information**: Core message, requests, updates
2. **Decisions**: Any decisions communicated or agreed upon
3. **Action Items**: Requests, commitments, deadlines
4. **References**: Links, attachments mentioned, related documents
5. **Stakeholders**: Who needs to be informed or involved

### Phase 3: Generate Structured Note

Compile into a project-friendly format.

## Output Format

```markdown
# Email: [Subject]

**From**: [Sender] | **Date**: [Date]
**To**: [Recipients] | **CC**: [CC list]

## Summary
[One paragraph summarising the email purpose and key content]

## Key Information
- [Important point 1]
- [Important point 2]

## Decisions
- [Decision communicated in the email]

## Action Items

| # | Action | Owner | Deadline |
|---|--------|-------|----------|
| 1 | [Task] | [Name] | [Date] |

## Thread Summary (if applicable)
| # | From | Date | Key Point |
|---|------|------|-----------|
| 1 | [Name] | [Date] | [Summary] |
| 2 | [Name] | [Date] | [Summary] |

## Follow-Up Needed
- [ ] [Items requiring response or action]
```

## Examples

### Example 1: Single Email
```
/email-capture "From: john@example.com\nSubject: API migration timeline\n\nHi team, after discussing with the client, we need to complete the v2 API migration by March 15. Sarah, can you prioritise the auth endpoints? Mike, please update the documentation..."
```

### Example 2: Email Thread
```
/email-capture emails/vendor-negotiation-thread.txt --thread true
```
