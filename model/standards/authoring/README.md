# Authoring Standards

**Version:** 2.0  
**Last Updated:** 2025-11-28

---

## Purpose

This directory contains **authoring guides** for creating assets in the Enablement 2.0 knowledge base. Each guide provides:

- Complete templates with all required sections
- Field specifications and valid values
- Checklists for completeness validation
- Examples of well-formed assets
- Relationship requirements (what other assets must exist/be referenced)

---

## Authoring Guides Index

### Core Asset Types

| Asset Type | Guide | Status | Description |
|------------|-------|--------|-------------|
| ADR | [ADR.md](./ADR.md) | ✅ Active | Architecture Decision Records |
| ERI | [ERI.md](./ERI.md) | ✅ Active | Enterprise Reference Implementations |
| Module | [MODULE.md](./MODULE.md) | ✅ Active | Reusable code templates |
| Skill | [SKILL.md](./SKILL.md) | ✅ Active | Automation skills (**CRITICAL**) |
| Validator | [VALIDATOR.md](./VALIDATOR.md) | ✅ Active | Artifact validation components |

### Complementary Asset Types

| Asset Type | Guide | Status | Description |
|------------|-------|--------|-------------|
| Capability | [CAPABILITY.md](./CAPABILITY.md) | ✅ Active | Feature groupings |
| Pattern | [PATTERN.md](./PATTERN.md) | ✅ Active | Architecture patterns |

---

## Asset Creation Order

Assets should be created in this order to ensure dependencies exist:

```
1. ADR (Strategic Decision)
   ↓
2. ERI (Reference Implementation)
   ↓
3. Module (Reusable Template)
   ↓
4. Validator (Quality Checks)      ← Can be created alongside Module
   ↓
5. Skill (Automation)
```

---

## Common Principles

### 1. Self-Contained Documentation

Each asset MUST be understandable without external context. An AI agent reading only the asset should understand:
- What it is
- Why it exists
- How to use it
- What it relates to

### 2. Explicit Relationships

All relationships to other assets MUST be explicitly documented:

| Relationship | From | To | Example |
|--------------|------|-----|---------|
| `implements` | ERI | ADR | ERI implements ADR decisions |
| `source_eri` | Module | ERI | Module derives from ERI |
| `uses` | Skill | Module | Skill uses Module templates |
| `validates` | Validator | Artifact | Validator checks artifact |
| `orchestrates` | Skill | Validator | Skill runs validators |

### 3. Machine-Readable Metadata

Assets MUST include YAML front matter for tooling:

```yaml
---
id: {type}-{id}
version: {semver}
status: draft|active|deprecated
created: {ISO date}
updated: {ISO date}
# Asset-specific fields...
---
```

### 4. Incremental Creation

Assets can be created incrementally across sessions. Each authoring guide specifies:
- **Minimum viable asset:** Required fields for a valid draft
- **Complete asset:** All fields for production use
- **Validation checklist:** How to verify completeness

---

## Quick Reference: What to Read

| I want to... | Read this |
|--------------|-----------|
| Document a strategic decision | [ADR.md](./ADR.md) |
| Create a reference implementation | [ERI.md](./ERI.md) |
| Build reusable templates | [MODULE.md](./MODULE.md) |
| Create automated capability | [SKILL.md](./SKILL.md) |
| Add validation for new technology | [VALIDATOR.md](./VALIDATOR.md) |

---

## Usage

### For AI Agents

When creating a new asset:

1. Read the appropriate authoring guide (e.g., `SKILL.md` for skills)
2. Identify required relationships (ADRs, ERIs, etc.)
3. Create minimum viable asset first
4. Complete remaining sections
5. Run validation checklist
6. Update related assets if needed

### For Humans

When reviewing or extending assets:

1. Use authoring guides as reference for expected structure
2. Use checklists to verify completeness
3. Follow templates for consistency

---

## Critical: Skills and Prompt Derivation

The **SKILL.md** guide is particularly important because it documents:

- How to derive prompts from the knowledge base
- How ADR constraints become prompt constraints
- How ERI patterns become prompt context
- How to orchestrate validators

**Read SKILL.md carefully before creating any skill.**

---

## Related Documents

- [../ASSET-STANDARDS-v1.3.md](../ASSET-STANDARDS-v1.3.md) - Naming conventions and directory structure
- [../validation/](../validation/) - Validation system architecture
- [../traceability/](../traceability/) - Traceability model and profiles

---

**Last Updated:** 2025-11-28
