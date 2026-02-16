---
description: Batch-triage multiple videos by relevance then deeply analyse must-watch ones
model: sonnet
---

# /video-digest

Efficiently process a list of videos by first triaging all for relevance (using fast Haiku agents), then deeply analysing only the highest-scored ones with Sonnet.

## When to Use This Skill

- Processing a conference playlist for relevant talks
- Filtering a YouTube channel's content for your tech stack
- Building a curated learning list from many candidates
- Extracting value from a large video backlog

## Usage

```
/video-digest <urls> --topic <topic> [--max-deep <number>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| urls | List of video URLs (comma-separated or one per line) | Yes | — |
| topic | What you're researching or learning about | Yes | — |
| max-deep | Maximum videos for deep analysis | No | 3 |

## Instructions

### Phase 1: Triage (Parallel Haiku Agents)

For each video, spawn a Haiku agent using the Task tool:

**Triage Agent** (Haiku, one per video)
Task: Score this video's relevance to the topic
- Fetch the video page with WebFetch to get title, description, and any transcript
- Score relevance to the topic (1-5)
- Score likely quality/depth (1-5)
- Write a one-sentence summary
Return: `{ title, url, relevance: X, quality: X, summary: "..." }`

Process videos in batches of 5 agents for efficiency.

### Phase 2: Rank and Select

1. Collect all triage scores
2. Compute combined score: `(relevance * 0.6) + (quality * 0.4)`
3. Rank by combined score
4. Select top `max-deep` videos for deep analysis

### Phase 3: Deep Analysis (Parallel Sonnet Agents)

For each selected video, spawn a Sonnet agent:

**Deep Analysis Agent** (Sonnet)
Task: Thoroughly analyse this video
- Fetch full transcript via WebFetch
- Extract key concepts, patterns, and technical details
- Identify actionable takeaways
- Note timestamps for important sections
Return: Full analysis following `/youtube-analyze` output format

### Phase 4: Compile Results

Merge triage table with deep analyses.

## Output Format

```markdown
# Video Digest: [Topic]

## Triage Results

| # | Title | Relevance | Quality | Score | Action |
|---|-------|-----------|---------|-------|--------|
| 1 | [Title] | 5/5 | 4/5 | 4.6 | Deep analysis |
| 2 | [Title] | 4/5 | 4/5 | 4.0 | Deep analysis |
| 3 | [Title] | 3/5 | 5/5 | 3.8 | Deep analysis |
| 4 | [Title] | 3/5 | 3/5 | 3.0 | Skip |
| 5 | [Title] | 1/5 | 2/5 | 1.4 | Skip |

## Deep Analyses

### 1. [Top Video Title]
[Full analysis...]

### 2. [Second Video Title]
[Full analysis...]

## Summary
[What you should watch and why]
```

## Examples

### Example 1: Conference Playlist
```
/video-digest url1, url2, url3, url4, url5 --topic "React Server Components" --max-deep 2
```
