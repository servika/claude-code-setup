---
description: Analyse YouTube videos via transcripts with timestamped summaries and key takeaways
model: sonnet
---

# /youtube-analyze

Analyse a YouTube video by fetching and processing its transcript, producing a structured summary with timestamps, key concepts, and actionable takeaways.

## When to Use This Skill

- Learning from conference talks and technical presentations
- Extracting key points from tutorial videos
- Creating notes from recorded meetings or webinars
- Building a knowledge base from video content

## Usage

```
/youtube-analyze <url> [--focus technical|summary|action-items]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| url | YouTube video URL | Yes | — |
| focus | Analysis lens | No | summary |

## Instructions

### Phase 1: Fetch Transcript

1. Use WebFetch to access the video page and extract available transcript
2. If WebFetch cannot get the transcript, suggest offline alternatives:
   ```bash
   yt-dlp --write-sub --write-auto-sub --sub-lang en --skip-download -o "transcript" "<url>"
   ```
3. Extract video metadata: title, channel, duration, publish date

### Phase 2: Analyse Content

Based on focus:

**technical**: Extract technical concepts
- Technologies, frameworks, and tools mentioned
- Architecture patterns and design decisions
- Code examples or implementation details
- Performance metrics and benchmarks
- Timestamp each technical topic

**summary**: Comprehensive overview
- Main thesis and key arguments
- Section-by-section summary with timestamps
- Key quotes and notable statements
- Speaker's conclusions and recommendations

**action-items**: Actionable extraction
- Things to try or implement
- Tools to evaluate
- Patterns to adopt or avoid
- Follow-up research topics
- Resources and links mentioned

### Phase 3: Generate Analysis

Compile into structured document.

## Output Format

```markdown
# Video Analysis: [Title]

**Channel**: [Name] | **Duration**: [Length] | **Published**: [Date]
**URL**: [Link]

## Summary
[2-3 sentence overview]

## Key Takeaways
1. [Takeaway with timestamp] (MM:SS)
2. [Takeaway with timestamp] (MM:SS)

## Detailed Notes

### [Topic 1] (MM:SS - MM:SS)
[Notes on this section]

### [Topic 2] (MM:SS - MM:SS)
[Notes on this section]

## Action Items
- [ ] [Thing to try or research]

## Related Resources
- [Links mentioned in the video]
```

## Examples

### Example 1: Conference Talk
```
/youtube-analyze https://youtube.com/watch?v=... --focus technical
```

### Example 2: Tutorial
```
/youtube-analyze https://youtube.com/watch?v=... --focus action-items
```
