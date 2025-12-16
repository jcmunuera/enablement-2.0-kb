# Authoring Guide: ADR (Architecture Decision Record)

**Version:** 1.0  
**Last Updated:** 2025-11-28  
**Asset Type:** ADR

---

## Overview

ADRs document **strategic architectural decisions** that are framework-agnostic. They define "what" and "why", not "how". ADRs serve as reference for humans and as constraints for automation.

## When to Create an ADR

Create an ADR when:

- A new architectural pattern or approach is being standardized
- A strategic technology choice needs documentation
- A cross-cutting concern requires consistent handling
- Multiple ERIs will implement variations of the same decision

Do NOT create an ADR for:

- Technology-specific implementation details (use ERI instead)
- One-off decisions that won't be reused
- Operational procedures (use runbooks instead)

---

## Directory Structure

```
knowledge/ADRs/
└── adr-XXX-{topic}/
    ├── ADR.md           # Main document (required)
    └── diagrams/        # Optional diagrams
        └── *.png|*.svg
```

## Naming Convention

```
adr-XXX-{topic}
```

- `XXX`: 3-digit sequential number (001-999)
- `{topic}`: kebab-case description of the decision

**Examples:**
- `adr-001-api-design-standards`
- `adr-004-resilience-patterns`
- `adr-009-service-architecture-patterns`

---

## Required YAML Front Matter

```yaml
---
id: adr-XXX-{topic}
title: "ADR-XXX: {Title}"
status: Draft|Proposed|Accepted|Deprecated|Superseded
date: YYYY-MM-DD
updated: YYYY-MM-DD
author: {Author/Team}
reviewers:
  - {reviewer1}
  - {reviewer2}
decision_type: {pattern|technology|process|constraint}
scope: {organization|team|project}
tags:
  - {tag1}
  - {tag2}
supersedes: adr-XXX (if applicable)
superseded_by: adr-XXX (if applicable)
implemented_by:
  - eri-{domain}-XXX-...
  - eri-{domain}-XXX-...
---
```

---

## Required Sections

### Template

```markdown
# ADR-XXX: {Title}

## Status

{Draft|Proposed|Accepted|Deprecated|Superseded}

**Date:** {YYYY-MM-DD}  
**Author:** {Author/Team}

---

## Context

[Describe the situation and forces at play. What problem needs solving?
What constraints exist? Why is a decision needed now?]

## Decision

[State the decision clearly and concisely. Use active voice.
"We will..." or "The system shall..."]

## Rationale

[Explain why this decision was made. What alternatives were considered?
Why were they rejected? What trade-offs are being accepted?]

## Consequences

### Positive

- [Benefit 1]
- [Benefit 2]

### Negative

- [Drawback 1]
- [Drawback 2]

### Neutral

- [Side effect that is neither positive nor negative]

## Implementation

[How will this decision be implemented? Reference ERIs that provide
concrete implementations for specific technologies.]

### Reference Implementations

| Technology | ERI | Status |
|------------|-----|--------|
| {tech1} | eri-{domain}-XXX-... | ✅ Active |
| {tech2} | eri-{domain}-XXX-... | ⏳ Planned |

## Validation

[How do we verify compliance with this decision?]

- [ ] Validation criteria 1
- [ ] Validation criteria 2

## References

- [External resource 1]
- [External resource 2]

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| {date} | 1.0 | Initial version | {author} |
```

---

## Section Guidelines

### Context

- Be specific about the problem
- Include relevant constraints (regulatory, technical, organizational)
- Explain why a decision is needed now
- Keep framework-agnostic

### Decision

- Use clear, unambiguous language
- State what WILL be done, not what MIGHT be done
- Keep technology-neutral where possible
- Be prescriptive enough to guide implementation

### Rationale

- Document alternatives considered
- Explain why alternatives were rejected
- Be honest about trade-offs
- Include team/stakeholder input if relevant

### Consequences

- Be thorough - both positive and negative
- Consider short-term and long-term effects
- Think about maintenance, training, migration

---

## Validation Checklist

Before marking an ADR as "Accepted":

- [ ] **Context** clearly explains the problem
- [ ] **Decision** is clear and actionable
- [ ] **Rationale** documents alternatives and trade-offs
- [ ] **Consequences** are realistic and complete
- [ ] At least one ERI is referenced or planned
- [ ] Validation criteria are defined
- [ ] Tags are appropriate
- [ ] Reviewers have approved

---

## Relationships

```
ADR
 │
 │ implemented_by (1:N)
 │ One ADR can have multiple ERIs for different technologies
 │
 ▼
ERI (per technology stack)
```

### Required Relationships

| Relationship | Requirement |
|--------------|-------------|
| `implemented_by` | At least one ERI must implement this ADR |

### Optional Relationships

| Relationship | When to Use |
|--------------|-------------|
| `supersedes` | When replacing an older ADR |
| `superseded_by` | When this ADR is replaced |
| `related` | For related but independent ADRs |

---

## Examples

### Good ADR Title

- ✅ "ADR-004: Resilience Patterns" (strategic, framework-agnostic)
- ✅ "ADR-009: Service Architecture Patterns" (broad, reusable)
- ❌ "ADR-010: How to Use Resilience4j" (too specific, should be ERI)

### Good Decision Statement

- ✅ "All external service calls MUST implement circuit breaker pattern"
- ✅ "Services SHOULD follow hexagonal architecture"
- ❌ "Consider using Resilience4j for circuit breakers" (too vague, specific library)

---

## Related

- `model/standards/ASSET-STANDARDS-v1.3.md` - ADR structure specification
- `authoring/ERI.md` - How to create ERIs that implement ADRs
- `knowledge/ADRs/` - Existing ADRs

---

**Last Updated:** 2025-11-28
