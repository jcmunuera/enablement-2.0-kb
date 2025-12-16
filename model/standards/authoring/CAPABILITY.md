# Authoring Guide: CAPABILITY

**Version:** 1.0  
**Last Updated:** 2025-11-28  
**Asset Type:** Capability

---

## Overview

Capabilities are **high-level groupings** of related features that represent business or technical objectives. They organize the knowledge base from a user-centric perspective, making it easier to discover what the platform can do.

## When to Create a Capability

Create a Capability when:

- A new business/technical domain needs organization
- Multiple related features should be grouped together
- Users need a discovery entry point for related functionality
- Cross-cutting concerns span multiple skills

Do NOT create a Capability for:

- Individual features (use Feature component instead)
- Implementation details (use Module instead)
- Single skills (capabilities group multiple skills)

---

## Directory Structure

```
knowledge/capabilities/
├── README.md                    # Capability catalog
└── {capability-name}.md         # Individual capability
```

## Naming Convention

```
{capability-name}.md
```

- Use kebab-case for filenames
- Use descriptive, user-friendly names
- Avoid technical jargon where possible

**Examples:**
- `service-resilience.md`
- `api-management.md`
- `observability.md`
- `security-compliance.md`

---

## Required YAML Front Matter

```yaml
---
id: cap-{name}
title: "{Capability Name}"
version: X.Y
date: YYYY-MM-DD
updated: YYYY-MM-DD
status: Draft|Active|Deprecated
category: resilience|security|observability|integration|...
description: "{One-line description}"
features:
  - feature-1
  - feature-2
modules:
  - mod-XXX-...
skills:
  - skill-{domain}-XXX-...
tags:
  - {tag1}
  - {tag2}
---
```

---

## Required Sections

### Template

```markdown
# Capability: {Name}

**Capability ID:** cap-{name}  
**Category:** {category}  
**Version:** X.Y  
**Status:** Active

---

## Overview

[What this capability provides from a user/business perspective.
Focus on outcomes, not implementation details.]

## Features

| Feature | Description | Status |
|---------|-------------|--------|
| {feature-1} | {what it provides} | ✅ Active |
| {feature-2} | {what it provides} | ⏳ Planned |

### {Feature 1}

[Detailed description of this feature]

**Components:**
- {component-1}: {description}
- {component-2}: {description}

**Enabled by:**
- Module: mod-XXX-...
- Skill: skill-{domain}-XXX-...

### {Feature 2}

[Detailed description]

---

## Dependencies

| Dependency | Type | Required |
|------------|------|----------|
| {capability} | Capability | ✅ Required |
| {module} | Module | ⚠️ Optional |

---

## Modules

| Module | Purpose | Feature |
|--------|---------|---------|
| mod-XXX-... | {purpose} | {feature} |

---

## Skills Using This Capability

| Skill | Domain | Type |
|-------|--------|------|
| skill-{domain}-XXX-... | {domain} | {type} |

---

## Recommended Combinations

| Combination | Use Case |
|-------------|----------|
| {cap-1} + {cap-2} | {when to use together} |

---

## Configuration Reference

[Common configuration patterns for this capability]

```yaml
# Example configuration
{configuration}
```

---

## Validation Rules

| Rule | Severity | Description |
|------|----------|-------------|
| {rule} | ERROR | {description} |

---

## Related

- **Capabilities:** {related capabilities}
- **Patterns:** {related patterns}
- **ADRs:** {governing ADRs}

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| {date} | 1.0 | Initial version | {author} |
```

---

## Capability Hierarchy

Capabilities follow a hierarchy:

```
Capability (High-Level)
  │
  ├── Feature (Mid-Level)
  │     │
  │     └── Component (Low-Level)
  │           │
  │           └── Module (Implementation)
  │
  └── Feature
        └── Component
              └── Module
```

### Example

```
Capability: Service Resilience
  │
  ├── Feature: Circuit Breaker
  │     ├── Component: Circuit Breaker Core
  │     │     └── Module: mod-code-001-circuit-breaker-java-resilience4j
  │     └── Component: Circuit Breaker Monitoring
  │           └── Module: mod-code-002-circuit-breaker-metrics
  │
  ├── Feature: Retry
  │     └── Component: Retry Core
  │           └── Module: mod-code-003-retry-java-resilience4j
  │
  └── Feature: Bulkhead
        └── Component: Bulkhead Core
              └── Module: mod-code-004-bulkhead-java-resilience4j
```

---

## Validation Checklist

Before marking a Capability as "Active":

- [ ] Overview explains user/business value
- [ ] All features are documented
- [ ] Each feature has at least one module
- [ ] Skills using this capability are listed
- [ ] Dependencies are documented
- [ ] Configuration examples are provided
- [ ] Related capabilities are linked

---

## Best Practices

### User-Centric Language

- ✅ "Prevent cascading failures when external services are down"
- ❌ "Implement circuit breaker pattern with Resilience4j"

### Complete Coverage

- Document ALL features, even planned ones
- Show feature status clearly (Active/Planned/Deprecated)
- Include recommended combinations

### Discovery-Friendly

- Use clear, searchable names
- Add relevant tags
- Cross-reference related capabilities

---

## Related

- `model/standards/ASSET-STANDARDS-v1.3.md` - Capability structure
- `knowledge/capabilities/README.md` - Capability catalog
- `authoring/PATTERN.md` - Related patterns documentation

---

**Last Updated:** 2025-11-28
