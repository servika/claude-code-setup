---
description: Convert PowerPoint presentations to structured Markdown
model: sonnet
---

# /pptx-extract

Extract content from PowerPoint files and convert to structured Markdown with slide-by-slide breakdown, speaker notes, and an overview index.

## When to Use This Skill

- Converting presentation decks to documentation
- Extracting architecture diagrams and decisions from slides
- Creating text-searchable versions of presentations
- Importing meeting presentations into project docs

## Usage

```
/pptx-extract <file-path> [--include-notes true|false]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| file-path | Path to the .pptx file | Yes | — |
| include-notes | Include speaker notes | No | true |

## Instructions

### Phase 1: Extract Content

Use python-pptx to extract slide content. Run this extraction script:

```bash
pip install python-pptx 2>/dev/null
python3 -c "
from pptx import Presentation
from pptx.util import Inches
import json, sys

prs = Presentation(sys.argv[1])
slides = []
for i, slide in enumerate(prs.slides):
    content = {'number': i+1, 'title': '', 'body': [], 'notes': ''}
    for shape in slide.shapes:
        if shape.has_text_frame:
            if shape.shape_id == slide.shapes.title.shape_id if slide.shapes.title else False:
                content['title'] = shape.text_frame.text
            else:
                for para in shape.text_frame.paragraphs:
                    if para.text.strip():
                        content['body'].append(para.text.strip())
    if slide.has_notes_slide:
        content['notes'] = slide.notes_slide.notes_text_frame.text
    slides.append(content)
print(json.dumps(slides, indent=2))
" "$1"
```

### Phase 2: Convert to Markdown

For each slide:
- Slide title becomes H2 heading (`## Slide N: Title`)
- Bullet points preserved as Markdown lists
- Speaker notes wrapped in blockquotes
- Tables converted to Markdown tables
- Diagrams described in text (suggest recreating in Mermaid)

### Phase 3: Generate Document

Compile slides with index.

## Output Format

```markdown
# [Presentation Title]

**Source**: [filename] | **Slides**: [count] | **Extracted**: [date]

## Slide Index
1. [Slide 1 title]
2. [Slide 2 title]

---

## Slide 1: [Title]

- Bullet point 1
- Bullet point 2

> **Speaker Notes**: [Notes content]

---

## Slide 2: [Title]
[Content...]
```

## Examples

### Example 1: Full Extraction
```
/pptx-extract presentations/architecture-review-q4.pptx
```

### Example 2: Content Only (No Notes)
```
/pptx-extract presentations/sprint-demo.pptx --include-notes false
```
