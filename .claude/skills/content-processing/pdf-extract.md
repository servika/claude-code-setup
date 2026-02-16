---
description: Extract structured content from PDF documents preserving headings, tables, and formatting
model: sonnet
---

# /pdf-extract

Extract and structure content from PDF documents into clean Markdown, preserving headings, tables, lists, and code blocks.

## When to Use This Skill

- Converting PDF specifications into editable documentation
- Extracting requirements from PDF documents
- Processing PDF reports for analysis
- Converting vendor documentation to project docs

## Usage

```
/pdf-extract <file-path> [--output markdown|summary|key-points]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| file-path | Path to the PDF file | Yes | — |
| output | Output format | No | markdown |

## Instructions

### Phase 1: Read PDF

1. Use the Read tool to open the PDF file (Claude natively supports PDF reading)
2. For large PDFs (>10 pages), process in page ranges using the `pages` parameter
3. If Read tool fails, suggest alternative extraction using docling:
   ```bash
   pip install docling
   docling <file-path> --output-dir ./extracted
   ```

### Phase 2: Structure Content

Based on output format:

**markdown**: Full structured conversion
- Convert headings to Markdown heading levels (H1-H6)
- Convert tables to Markdown tables
- Preserve bullet points and numbered lists
- Wrap code snippets in fenced code blocks
- Convert images to descriptive alt text
- Maintain document hierarchy and section numbering

**summary**: Condensed overview
- Extract document title and metadata
- Summarise each major section in 2-3 sentences
- List key figures, tables, and data points
- Total length: ~20% of original

**key-points**: Actionable extraction
- Extract decisions, requirements, and action items
- Pull out key metrics and thresholds
- List referenced standards or specifications
- Identify stakeholders and responsibilities

### Phase 3: Output

Generate clean Markdown with metadata header.

## Output Format

```markdown
# [Document Title]

**Source**: [filename] | **Pages**: [count] | **Extracted**: [date]

---

[Structured content based on output format]
```

## Examples

### Example 1: Full Extraction
```
/pdf-extract docs/api-specification-v2.pdf
```

### Example 2: Key Points Only
```
/pdf-extract docs/security-audit-report.pdf --output key-points
```
