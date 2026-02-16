---
description: Capture and structure non-functional requirements across ISO 25010 quality categories
model: sonnet
---

# /nfr-capture

Systematically capture non-functional requirements for a system using the ISO 25010 quality model, producing measurable acceptance criteria for each requirement.

## When to Use This Skill

- Starting a new project or major feature
- Preparing for architecture review
- Documenting quality requirements for stakeholders
- Before writing performance/security/reliability tests

## Usage

```
/nfr-capture <system-name> [--stakeholders <list>] [--focus <quality-attributes>]
```

### Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| system-name | System or feature being specified | Yes | — |
| stakeholders | Who cares about these NFRs | No | Dev team, users, ops |
| focus | Specific quality attributes to prioritise | No | All applicable |

## Instructions

### Phase 1: Identify Applicable Quality Attributes

Review the ISO 25010 quality model categories and determine which apply:

| Category | Sub-characteristics | Typical Concerns |
|----------|-------------------|------------------|
| **Performance** | Time behaviour, resource utilisation, capacity | Response times, throughput, concurrent users |
| **Security** | Confidentiality, integrity, authenticity | Auth, encryption, audit logging |
| **Reliability** | Maturity, availability, fault tolerance, recoverability | Uptime SLA, MTTR, data durability |
| **Usability** | Learnability, operability, accessibility | WCAG compliance, mobile support |
| **Maintainability** | Modularity, reusability, analysability, testability | Code coverage, deployment frequency |
| **Portability** | Adaptability, installability, replaceability | Browser support, containerisation |
| **Compatibility** | Co-existence, interoperability | API versioning, data formats |
| **Functional Suitability** | Completeness, correctness, appropriateness | Feature coverage, accuracy |

### Phase 2: Capture Requirements

For each applicable attribute, capture:

1. **Description**: What quality characteristic is needed
2. **Measurable criterion**: Specific, testable threshold
3. **Priority**: Must / Should / Could (MoSCoW)
4. **Verification method**: How to test (automated/manual)
5. **Stakeholder**: Who requires this

### Phase 3: Generate NFR Document

Compile into structured document with traceability matrix.

## Output Format

```markdown
# Non-Functional Requirements: [System Name]

## Overview
[Brief system description and NFR scope]

## Requirements

### Performance

| ID | Requirement | Criterion | Priority | Verification |
|----|-------------|-----------|----------|-------------|
| NFR-P01 | API response time | p95 < 300ms for GET, p95 < 500ms for POST | Must | Load test (k6) |
| NFR-P02 | Concurrent users | Support 500 concurrent users | Must | Load test |
| NFR-P03 | Page load time | LCP < 2.5s on 4G connection | Should | Lighthouse CI |

### Security

| ID | Requirement | Criterion | Priority | Verification |
|----|-------------|-----------|----------|-------------|
| NFR-S01 | Authentication | JWT with 15min access token expiry | Must | Integration test |
| NFR-S02 | Input validation | All API inputs validated with Zod | Must | Unit test + audit |

[...additional categories...]

## Traceability Matrix

| NFR ID | Stakeholder | Test Type | Automated | Status |
|--------|-------------|-----------|-----------|--------|
| NFR-P01 | Ops, Users | Load test | Yes | Pending |
```

## Examples

### Example 1: New API Service
```
/nfr-capture "Payment Processing Service" --stakeholders "security team, product, ops" --focus "security, performance, reliability"
```

### Example 2: Frontend Application
```
/nfr-capture "Customer Dashboard" --focus "usability, performance, compatibility"
```
