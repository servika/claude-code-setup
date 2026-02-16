---
description: Extract structured content from any document format with auto-detection
model: sonnet
---

# /document-extract

Auto-detect document format and extract structured Markdown content using the appropriate extraction strategy for each file type.

## When to Use This Skill

- Processing documents of unknown or varied formats
- Batch-converting project documentation to Markdown
- Extracting content from legacy file formats
- When you're unsure which specific extraction skill to use

## Usage

```
/document-extract <file-path> [--format auto|pdf|pptx|docx|html|csv|json|yaml]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| file-path | Path to the document | Yes | — |
| format | Force a specific format | No | auto |

## Instructions

### Phase 1: Detect Format

Auto-detect from file extension:

| Extension | Format | Extraction Method |
|-----------|--------|-------------------|
| `.pdf` | PDF | Read tool (native PDF support) |
| `.pptx` | PowerPoint | python-pptx script |
| `.docx` | Word | python-docx script |
| `.html`, `.htm` | HTML | Read tool + strip tags |
| `.csv` | CSV | Read tool → Markdown table |
| `.json` | JSON | Read tool → formatted code block |
| `.yaml`, `.yml` | YAML | Read tool → formatted code block |
| `.md`, `.txt` | Text | Read tool (passthrough) |

### Phase 2: Extract Content

**PDF**: Use Read tool with page ranges for large files. Preserve structure.

**PowerPoint**: Run python-pptx extraction script (see `/pptx-extract`).

**Word (.docx)**: Run python-docx extraction:
```bash
pip install python-docx 2>/dev/null
python3 -c "
import docx, sys, json
doc = docx.Document(sys.argv[1])
result = []
for para in doc.paragraphs:
    if para.text.strip():
        result.append({'style': para.style.name, 'text': para.text})
for table in doc.tables:
    rows = [[cell.text for cell in row.cells] for row in table.rows]
    result.append({'type': 'table', 'rows': rows})
print(json.dumps(result, indent=2))
" "$1"
```

**HTML**: Read file, convert to Markdown (strip scripts/styles, convert tags to Markdown equivalents).

**CSV**: Read file, convert to Markdown table. For large CSVs (>100 rows), show first 20 rows with summary statistics.

**JSON/YAML**: Read file, wrap in appropriate fenced code block. For large files, show structure overview first.

### Phase 3: Output

Generate clean Markdown with format-specific metadata.

## Output Format

```markdown
# [Document Title or Filename]

**Format**: [Detected format] | **Size**: [File size] | **Extracted**: [Date]

---

[Extracted content in Markdown]
```

## Examples

### Example 1: Auto-Detect
```
/document-extract docs/requirements-spec.docx
```

### Example 2: Force Format
```
/document-extract data/export.csv --format csv
```
