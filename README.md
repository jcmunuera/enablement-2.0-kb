# Enablement 2.0

> AI-powered SDLC platform for automated code generation with governance

## Overview

Enablement 2.0 is a platform that combines a structured Knowledge Base with AI capabilities to automate code generation following organizational standards.

### Problem Statement

- Low adoption of development frameworks (~30-40%)
- Inconsistent implementations across teams
- Productivity cost from pattern reinvention
- Difficulty maintaining governance in generated code

### Solution

A machine-readable Knowledge Base that feeds specialized AI agents to:
- Generate code compliant with standards (ADRs)
- Apply reference patterns (ERIs)
- Automatically validate generated code
- Scale knowledge to 400+ developers

---

## Repository Structure

```
enablement-2.0/
├── knowledge/              # Knowledge Base (project core)
│   ├── model/              # Conceptual model and standards
│   ├── ADRs/               # Architecture Decision Records
│   ├── ERIs/               # Enterprise Reference Implementations
│   ├── capabilities/       # Capability definitions
│   ├── skills/             # Skills and Modules for automation
│   ├── validators/         # Validation system (4 tiers)
│   └── patterns/           # Architectural patterns
│
├── docs/                   # Project documentation
│   ├── METHODOLOGY.md      # How we work
│   └── sessions/           # Work session summaries
│
└── poc/                    # Proofs of concept
    └── code-generation/    # Code generation PoC
```

---

## Knowledge Base

The Knowledge Base follows an asset hierarchy:

```
ADR (Strategic Decision)
  ↓ implements
ERI (Reference Implementation)
  ↓ abstracts to
MODULE (Reusable Template)
  ↓ used by
SKILL (Automated Generation)
```

### Current Inventory (v1.0.0)

| Asset Type | Count | Examples |
|------------|-------|----------|
| **ADRs** | 4 | API Design, Resilience, Architecture, Persistence |
| **ERIs** | 6 | Hexagonal Light, Circuit Breaker, Retry, Timeout, Rate Limiter, Persistence |
| **MODULEs** | 7 | Templates for each ERI |
| **SKILLs** | 2 | Add Circuit Breaker, Generate Microservice |
| **CAPABILITIEs** | 3 | Resilience, Persistence, API Architecture |

---

## Quick Start

### Explore the Knowledge Base

```bash
# View structure
ls -la knowledge/

# View available ERIs
ls knowledge/ERIs/

# View capabilities
cat knowledge/capabilities/README.md
```

### Understand the Model

1. Start with: `knowledge/model/ENABLEMENT-MODEL-v1.2.md`
2. Then: `knowledge/model/standards/ASSET-STANDARDS-v1.3.md`
3. To create assets: `knowledge/model/standards/authoring/`

---

## Versioning

We use [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

MAJOR - Structural changes, complete new capability
MINOR - New ERIs, MODULEs, SKILLs
PATCH - Fixes, documentation improvements
```

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## Methodology

See [docs/METHODOLOGY.md](docs/METHODOLOGY.md) for details on:
- Branching strategy
- Commit conventions
- AI workflow
- Session documentation

---

## Roadmap

### Current Phase: Foundation (v1.x)
- [x] Structured Knowledge Base
- [x] Resilience patterns (Circuit Breaker, Retry, Timeout, Rate Limiter)
- [x] Persistence patterns (JPA, System API)
- [ ] Code Generation PoC

### Next Phases
- [ ] Observability patterns
- [ ] Event-driven patterns
- [ ] Testing patterns
- [ ] MCP Server integration

---

## Contributing

This is an internal project of the Center for Enablement (C4E).

To contribute:
1. Review `docs/METHODOLOGY.md`
2. Follow standards in `knowledge/model/standards/authoring/`
3. Validate changes before committing

---

## License

Internal project - All rights reserved.

---

**Version:** 1.0.0  
**Last Updated:** 2025-12-01
