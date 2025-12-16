---
id: design
name: "DESIGN"
version: 1.0
status: Planned
created: 2025-12-12
updated: 2025-12-12
swarm_alignment: "DESIGN Swarm"
---

# Domain: DESIGN

## Purpose

Architecture design, system transformation, and design documentation. This domain produces architectural artifacts including designs, diagrams, transformation plans, and ADR drafts.

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **ARCHITECTURE** | Design new architecture (greenfield) | Requirements, constraints | Architecture design, diagrams |
| **TRANSFORM** | Transform existing architecture (brownfield) | Existing code + target architecture | Transformation plan, work items |
| **DOCUMENTATION** | Generate design documentation | Code/requirements | ADR drafts, diagrams, specs |

See `skill-types/` for detailed execution flows.

---

## Module Structure

Modules in the DESIGN domain contain:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Document templates (.md.tpl, .mermaid.tpl) |
| `patterns/` | ⚠️ Optional | Architectural pattern definitions |
| `validation/` | ✅ | Document structure validators |

### Template Types

| Type | Extension | Purpose |
|------|-----------|---------|
| Markdown | `.md.tpl` | Design documents, ADRs |
| Mermaid | `.mermaid.tpl` | Architecture diagrams |
| PlantUML | `.puml.tpl` | Sequence, class diagrams |
| OpenAPI | `.openapi.tpl` | API specifications |

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `design-document` | Architecture document | HLD, LLD, Technical Design |
| `diagram` | Visual architecture representation | Component, sequence, class |
| `transformation-plan` | Migration roadmap | Monolith to microservices plan |
| `adr-draft` | Architecture Decision Record draft | ADR-XXX draft |

---

## Capabilities

Planned capabilities for DESIGN domain:

| Capability | Description | Status |
|------------|-------------|--------|
| `architecture_patterns` | Microservices, event-driven, etc. | 🔜 Planned |
| `diagramming` | Component, sequence, class diagrams | 🔜 Planned |
| `documentation` | HLD, LLD, Technical Design | 🔜 Planned |

---

## Applicable Concerns

| Concern | How it applies to DESIGN |
|---------|--------------------------|
| Security | Security architecture, threat modeling |
| Performance | Capacity planning, bottleneck identification |
| Observability | Observability design, metrics definition |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-design-{NNN}-{pattern}` | `eri-design-001-hexagonal-architecture` |
| Module | `mod-design-{NNN}-{pattern}` | `mod-design-001-hld-template` |
| Skill | `skill-design-{NNN}-{type}-{target}` | `skill-design-001-architecture-microservice` |

---

## Status

This domain is **planned** but not yet implemented. Priority focus is on CODE domain.

### Planned Skills

```
DESIGN/ARCHITECTURE:
├── skill-design-001-architecture-microservice
├── skill-design-002-architecture-api-contract
└── skill-design-003-architecture-data-model

DESIGN/TRANSFORM:
├── skill-design-040-transform-monolith-to-microservices
├── skill-design-041-transform-layered-to-hexagonal
└── skill-design-042-transform-sync-to-event-driven

DESIGN/DOCUMENTATION:
├── skill-design-080-documentation-adr-draft
├── skill-design-081-documentation-architecture-diagram
└── skill-design-082-documentation-sequence-diagram
```
