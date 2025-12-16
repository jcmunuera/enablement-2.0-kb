# Domains

**Version:** 1.0  
**Last Updated:** 2025-12-12  
**Status:** Active

---

## Overview

Domains represent distinct phases of the SDLC, each aligned with a specialized Swarm in the platform architecture. Every domain has its own:

- **ADRs** (strategic decisions applicable to that domain)
- **ERIs** (reference implementations)
- **Capabilities** (feature groups)
- **Modules** (reusable components)
- **Skills** (automated actions)
- **Skill Types** (categories of skills with specific execution flows)

---

## Current Domains

| Domain | Swarm | Purpose | Status |
|--------|-------|---------|--------|
| [CODE](code/DOMAIN.md) | CODE Swarm | Code generation, modification, migration | ✅ Active |
| [DESIGN](design/DOMAIN.md) | DESIGN Swarm | Architecture design, transformation | 🔜 Planned |
| [QA](qa/DOMAIN.md) | QA Swarm | Analysis, validation, audit | 🔜 Planned |
| [GOVERNANCE](governance/DOMAIN.md) | GOVERNANCE Swarm | Documentation, compliance, policy | 🔜 Planned |

---

## Domain Structure

Each domain follows this structure:

```
domains/{domain}/
├── DOMAIN.md              # Domain definition
├── capabilities/          # Feature groups for this domain
│   └── {capability}.md
├── skill-types/           # Execution flows by skill type
│   └── {TYPE}.md
└── module-structure.md    # Module structure specific to this domain
```

---

## Asset Ownership by Domain

| Asset | Domain Indicator | Location |
|-------|------------------|----------|
| ADR | `domains:` in metadata | `ADRs/` (centralized) |
| ERI | `eri-{domain}-XXX` in name | `ERIs/` (centralized) |
| Capability | Located in domain folder | `domains/{domain}/capabilities/` |
| Module | `mod-{domain}-XXX` in name | `skills/modules/` (centralized) |
| Skill | `skill-{domain}-XXX` in name | `skills/` (centralized) |

---

## Creating a New Domain

To add a new domain (e.g., SECURITY):

1. Create folder structure:
   ```bash
   mkdir -p domains/security/{capabilities,skill-types}
   ```

2. Create `DOMAIN.md` following the template below

3. Define skill types in `skill-types/`

4. Define module structure in `module-structure.md`

5. Update this README

### DOMAIN.md Template

```yaml
---
id: {domain-id}
name: "{DOMAIN NAME}"
version: 1.0
status: Draft | Active | Deprecated
created: YYYY-MM-DD
updated: YYYY-MM-DD
swarm_alignment: "{SWARM} Swarm"
---

# Domain: {NAME}

## Purpose
[What this domain does]

## Skill Types
[Table of skill types with purpose, input, output]

## Module Structure
[What modules in this domain contain]

## Output Types
[What artifacts this domain produces]

## Applicable Concerns
[Cross-cutting concerns that apply]

## Validators
[Validation tiers applicable]
```

---

## Cross-Domain Considerations

Some concepts span multiple domains:

- **Concerns** (security, performance, observability) → See `../concerns/`
- **Cross-domain Flows** → Orchestrated sequences using skills from multiple domains
- **Universal Validators** → Tier 1 validators apply to all domains

---

## Related

- [Concerns](../concerns/README.md) - Cross-cutting aspects
- [ENABLEMENT-MODEL](../model/ENABLEMENT-MODEL-v1.3.md) - Complete model
- [Orchestration](../orchestration/README.md) - Execution framework
