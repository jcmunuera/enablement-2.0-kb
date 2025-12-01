# Authoring Guide: PATTERN

**Version:** 1.0  
**Last Updated:** 2025-11-28  
**Asset Type:** Pattern

---

## Overview

Patterns document **reusable architectural solutions** to common problems. They capture design wisdom independent of specific technologies, serving as conceptual references that ADRs can mandate and ERIs can implement.

## When to Create a Pattern

Create a Pattern when:

- A recurring design problem has a proven solution
- Multiple ADRs might reference the same solution approach
- Knowledge needs to be captured technology-agnostically
- Teams need conceptual understanding before implementation

Do NOT create a Pattern for:

- Technology-specific implementations (use ERI instead)
- One-off solutions
- Operational procedures (use runbooks instead)

---

## Directory Structure

```
knowledge/patterns/
├── README.md                        # Pattern catalog
└── ptr-XXX-{pattern}/
    ├── DOCUMENTATION.md             # Main documentation
    └── diagrams/                    # Optional diagrams
        └── *.png|*.svg|*.mermaid
```

## Naming Convention

```
ptr-XXX-{pattern-name}
```

- `ptr`: Pattern prefix
- `XXX`: 3-digit sequential number
- `{pattern-name}`: kebab-case pattern name

**Examples:**
- `ptr-001-circuit-breaker`
- `ptr-002-retry-with-backoff`
- `ptr-003-bulkhead`
- `ptr-010-hexagonal-architecture`

---

## Required YAML Front Matter

```yaml
---
id: ptr-XXX-{pattern-name}
title: "Pattern: {Pattern Name}"
version: X.Y
date: YYYY-MM-DD
updated: YYYY-MM-DD
status: Draft|Active|Deprecated
category: resilience|structural|behavioral|integration|data|security
problem_domain: {what problem domain}
tags:
  - {tag1}
  - {tag2}
related_patterns:
  - ptr-XXX-...
implemented_by:
  - eri-{domain}-XXX-...
mandated_by:
  - adr-XXX-...
---
```

---

## Required Sections

### Template

```markdown
# Pattern: {Pattern Name}

**Pattern ID:** ptr-XXX-{pattern-name}  
**Category:** {category}  
**Version:** X.Y  
**Status:** Active

---

## Overview

[Brief description of what this pattern is and what it achieves.
Keep technology-agnostic.]

---

## Problem

[Describe the problem this pattern solves.
Include context, forces, and constraints that make this problem challenging.]

### Context

- {Context point 1}
- {Context point 2}

### Forces

- {Force 1}: {description}
- {Force 2}: {description}

---

## Solution

[Describe the solution approach at a conceptual level.
Avoid technology-specific details.]

### Key Principles

1. **{Principle 1}:** {explanation}
2. **{Principle 2}:** {explanation}

### Mechanism

[Explain how the pattern works conceptually]

---

## Structure

[Visual representation of the pattern]

```
┌─────────────────────────────────────────────────────────┐
│                    {Diagram}                             │
│                                                          │
│    [Component A] ──► [Component B] ──► [Component C]    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Components

| Component | Responsibility |
|-----------|----------------|
| {Component A} | {what it does} |
| {Component B} | {what it does} |

---

## Behavior

[Describe how the pattern behaves in different scenarios]

### Normal Flow

1. {Step 1}
2. {Step 2}
3. {Step 3}

### Failure Scenarios

| Scenario | Behavior |
|----------|----------|
| {Scenario 1} | {how pattern responds} |
| {Scenario 2} | {how pattern responds} |

---

## Implementation

[Links to concrete implementations]

### Reference Implementations

| Technology | ERI | Status |
|------------|-----|--------|
| Java/Spring | eri-code-XXX-... | ✅ Active |
| NodeJS | eri-code-XXX-... | ⏳ Planned |

### Key Implementation Considerations

- {Consideration 1}
- {Consideration 2}

---

## When to Use

✅ **Use this pattern when:**

- {Condition 1}
- {Condition 2}
- {Condition 3}

---

## When NOT to Use

❌ **Avoid this pattern when:**

- {Anti-condition 1}
- {Anti-condition 2}
- {Anti-condition 3}

---

## Consequences

### Benefits

- {Benefit 1}
- {Benefit 2}

### Drawbacks

- {Drawback 1}
- {Drawback 2}

### Trade-offs

| Trade-off | Impact |
|-----------|--------|
| {Trade-off 1} | {impact description} |

---

## Related Patterns

| Pattern | Relationship |
|---------|--------------|
| ptr-XXX-{pattern} | {how they relate} |

### Pattern Combinations

| Combination | Use Case |
|-------------|----------|
| {pattern-1} + {pattern-2} | {when to use together} |

---

## References

- [{Reference 1}]({url})
- [{Reference 2}]({url})

### Books

- "{Book Title}" by {Author} - Chapter {X}

### Articles

- [{Article Title}]({url})

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| {date} | 1.0 | Initial version | {author} |
```

---

## Pattern Categories

| Category | Description | Examples |
|----------|-------------|----------|
| **Resilience** | Handle failures gracefully | Circuit Breaker, Retry, Bulkhead |
| **Structural** | Organize code/components | Hexagonal, Layered, Microservices |
| **Behavioral** | Define interactions | Saga, Event Sourcing, CQRS |
| **Integration** | Connect systems | API Gateway, Message Broker, BFF |
| **Data** | Manage data | Repository, Unit of Work, DAO |
| **Security** | Protect systems | OAuth, Zero Trust, Secrets Management |

---

## Pattern Relationships

```
Pattern (Conceptual)
  │
  │ mandated_by (N:1)
  │ ADR mandates use of pattern
  │
  ▼
ADR (Strategic Decision)
  │
  │ implements (1:N)
  │ ERI implements pattern for technology
  │
  ▼
ERI (Reference Implementation)
```

---

## Validation Checklist

Before marking a Pattern as "Active":

- [ ] Problem is clearly described
- [ ] Solution is technology-agnostic
- [ ] Structure diagram is included
- [ ] When to use / When NOT to use is clear
- [ ] Consequences (benefits/drawbacks) documented
- [ ] At least one ERI implements this pattern
- [ ] Related patterns are linked
- [ ] References to external sources included

---

## Best Practices

### Technology Agnostic

- ✅ "The circuit breaker maintains three states: Closed, Open, Half-Open"
- ❌ "Use @CircuitBreaker annotation from Resilience4j"

### Problem-Focused

- Start with the problem, not the solution
- Explain WHY before HOW
- Include failure scenarios

### Visual Communication

- Include diagrams where possible
- Use ASCII art for simple structures
- Link to detailed diagrams in `diagrams/`

### Complete Coverage

- Document both success and failure paths
- Include trade-offs honestly
- Reference authoritative sources

---

## Example: Circuit Breaker Pattern

```markdown
# Pattern: Circuit Breaker

**Pattern ID:** ptr-001-circuit-breaker
**Category:** Resilience

## Problem

When a service depends on external services, failures in those services
can cascade, overwhelming the dependent service with failed requests
and preventing recovery.

## Solution

Wrap external calls in a "circuit breaker" that monitors failures.
When failures exceed a threshold, the circuit "opens" and fails fast
without attempting the call, allowing the external service to recover.

## Structure

```
┌──────────┐     ┌─────────────────┐     ┌──────────────┐
│  Client  │────►│ Circuit Breaker │────►│ External Svc │
└──────────┘     └─────────────────┘     └──────────────┘
                        │
                        ▼
                 ┌─────────────┐
                 │  Fallback   │
                 └─────────────┘
```

## When to Use

- External service calls over network
- Services with unpredictable availability
- Need to fail fast during outages
```

---

## Related

- `model/standards/ASSET-STANDARDS-v1.3.md` - Pattern structure
- `authoring/ADR.md` - ADRs that mandate patterns
- `authoring/ERI.md` - ERIs that implement patterns
- `knowledge/patterns/` - Existing patterns

---

**Last Updated:** 2025-11-28
