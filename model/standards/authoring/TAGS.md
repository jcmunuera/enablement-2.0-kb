# Authoring Guide: Skill Tags

**Version:** 1.1  
**Date:** 2025-12-24

---

## Purpose

Tags enable efficient skill discovery by providing structured metadata that can be parsed and matched against user requests. This system allows:

1. **Fast filtering** without reading full OVERVIEW.md files
2. **Precise discrimination** between similar skills
3. **Scalable discovery** as the number of skills grows

---

## Format: YAML Frontmatter

Tags are defined as YAML frontmatter at the beginning of each skill's `OVERVIEW.md`:

```markdown
---
id: skill-021-api-rest-java-spring
version: 2.2.0
extends: skill-020-microservice-java-spring
tags:
  dimension-1: value-1
  dimension-2: value-2
  ...
---

# skill-021-api-rest-java-spring

## Overview
...
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Skill identifier (must match folder name) |
| `version` | string | Semantic version (MAJOR.MINOR.PATCH) |
| `tags` | object | Tag dimensions (see domain-specific taxonomies) |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `extends` | string | Parent skill ID (for inheritance) |

---

## Tag Inheritance

When a skill extends another, the child skill **must declare all tags explicitly**, including those that would be inherited from the parent.

### Rationale

- **Determinism**: The discovery process reads tags directly without resolving inheritance chains
- **Clarity**: All tags are visible in one place
- **Simplicity**: No runtime resolution needed

### Example

```yaml
# Parent: skill-020
---
id: skill-020-microservice-java-spring
tags:
  artifact-type: service
  runtime-model: request-response
  stack: java-spring
---

# Child: skill-021 (extends skill-020)
# ALL tags explicit, even those matching parent
---
id: skill-021-api-rest-java-spring
extends: skill-020-microservice-java-spring
tags:
  artifact-type: api           # Changed from parent
  runtime-model: request-response  # Same as parent (explicit)
  stack: java-spring              # Same as parent (explicit)
  protocol: rest                  # Added
  api-model: fusion               # Added
---
```

### Coherence Rules

When extending a skill, certain tags **must remain consistent** with the parent. These rules are **domain-specific** and defined in each domain's `TAG-TAXONOMY.md`.

---

## Discovery Process

The discovery process uses tags in Phase 2:

```
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 1: skill-index.yaml                                       │
│ - Filter by domain (CODE, DESIGN, QA, GOVERNANCE)               │
│ - Filter by layer (if applicable, e.g., SOE/SOI/SOR for CODE)   │
│ - Output: List of candidate skill paths                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 2: Parse Frontmatter Tags                                 │
│ - Read ONLY the YAML frontmatter from each candidate            │
│ - Extract tags from user request (domain-specific rules)        │
│ - Match extracted tags against skill tags                       │
│ - Score each candidate based on tag matches                     │
│ - Output: Ranked candidates                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 3: Read Full OVERVIEW.md                                  │
│ - Read complete OVERVIEW.md of top candidate(s)                 │
│ - Apply Activation Rules from "When to Use" section             │
│ - If ambiguous, ask user for clarification                      │
│ - Output: Selected skill                                        │
└─────────────────────────────────────────────────────────────────┘
```

### Tag Extraction

The process of extracting tags from user requests is **domain-specific**. Each domain defines:

1. **Tag dimensions**: What tags exist (e.g., `artifact-type`, `stack`)
2. **Extraction keywords**: How to detect each tag value from prompts
3. **Default values**: What to assume when not specified
4. **Weights**: How important each dimension is for scoring

See domain-specific `TAG-TAXONOMY.md` for details.

### Tag Matching Algorithm (Generic)

```
For each candidate skill:
  score = 0
  
  For each dimension in extracted_tags:
    if skill.tags[dimension] == extracted_tags[dimension]:
      score += weight(dimension)  # Domain-specific weights
  
  Return score
```

---

## Taxonomies by Domain

Each domain defines its own tag taxonomy in `model/domains/{domain}/TAG-TAXONOMY.md`:

| Domain | Taxonomy Location | Status |
|--------|-------------------|--------|
| **CODE** | `model/domains/code/TAG-TAXONOMY.md` | ✅ Defined |
| **DESIGN** | `model/domains/design/TAG-TAXONOMY.md` | 📋 Planned |
| **QA** | `model/domains/qa/TAG-TAXONOMY.md` | 📋 Planned |
| **GOVERNANCE** | `model/domains/governance/TAG-TAXONOMY.md` | 📋 Planned |

Each taxonomy defines:
- Tag dimensions and valid values
- Keywords for extraction from user prompts
- Default values when not specified
- Dimension weights for scoring
- Coherence rules for skill extension

---

## Validation Checklist (Generic)

Before publishing a skill, verify:

- [ ] OVERVIEW.md has valid YAML frontmatter
- [ ] `id` matches the skill folder name
- [ ] `version` follows semantic versioning
- [ ] All required tags for the domain are present (see domain taxonomy)
- [ ] If `extends` is specified, parent skill exists
- [ ] All tags are explicit (no reliance on inheritance)
- [ ] Tag values are from the defined taxonomy (no free-form values)
- [ ] Coherence rules are satisfied (see domain taxonomy)

---

## Anti-patterns

### ❌ Free-form tag values

```yaml
# BAD: Custom values not in taxonomy
tags:
  artifact-type: my-custom-service
```

### ❌ Missing required tags

```yaml
# BAD: Missing tags required by domain taxonomy
tags:
  artifact-type: api
  # Missing: stack, runtime-model, protocol, api-model
```

### ❌ Relying on implicit inheritance

```yaml
# BAD: Assuming tags are inherited from parent
extends: skill-020-microservice-java-spring
tags:
  artifact-type: api
  # Missing: stack, runtime-model (should be explicit)
```

---

## Related Documents

- `model/domains/{domain}/TAG-TAXONOMY.md` - Domain-specific taxonomies
- `model/standards/authoring/SKILL.md` - Skill authoring guide
- `runtime/discovery/skill-index.yaml` - Discovery index
- `runtime/discovery/discovery-guidance.md` - Discovery process details

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.1 | 2025-12-24 | Moved domain taxonomies to TAG-TAXONOMY.md; explicit tags required |
| 1.0 | 2025-12-24 | Initial version |
