# Getting Started with Enablement 2.0

**Version:** 1.0  
**Last Updated:** 2025-12-12  
**Purpose:** Onboarding guide for different roles

---

## What is Enablement 2.0?

Enablement 2.0 is an AI-powered SDLC automation platform that:

- **Generates code** that follows organizational standards automatically
- **Validates compliance** against Architecture Decision Records (ADRs)
- **Scales knowledge** from reference implementations to 400+ developers
- **Tracks every decision** from strategic architecture to generated code

---

## Choose Your Path

| Role | Time | Goal | Start Here |
|------|------|------|------------|
| [Executive / Manager](#executive-path) | 15 min | Understand value proposition | ↓ |
| [Architect](#architect-path) | 1-2 hours | Understand the model and governance | ↓ |
| [Engineer - Creating Assets](#engineer-creating-assets) | 2-4 hours | Learn to author ADRs, ERIs, Modules, Skills | ↓ |
| [Engineer - Using Skills](#engineer-using-skills) | 30 min | Generate code using existing Skills | ↓ |

---

## Executive Path

**Time:** 15 minutes  
**Goal:** Understand the business value and high-level architecture

### Reading Order

1. **[README.md](README.md)** (5 min)
   - Problem statement: 30-40% framework adoption
   - Solution overview
   - Current inventory

2. **[ENABLEMENT-EXECUTIVE-BRIEF.md](knowledge/model/ENABLEMENT-EXECUTIVE-BRIEF.md)** (10 min)
   - ROI and value proposition
   - Risk mitigation
   - Adoption strategy

### Key Takeaways

- Every generated artifact traces back to approved architecture decisions
- Skills automate repetitive development tasks with guaranteed compliance
- The platform reduces onboarding time and ensures consistency

---

## Architect Path

**Time:** 1-2 hours  
**Goal:** Understand the complete model, governance, and how pieces connect

### Reading Order

1. **[README.md](README.md)** (5 min)
   - Repository structure overview

2. **[knowledge/model/ENABLEMENT-MODEL-v1.3.md](knowledge/model/ENABLEMENT-MODEL-v1.3.md)** (30 min)
   - Complete conceptual model
   - Asset hierarchy: ADR → ERI → Module → Skill
   - Capability hierarchy
   - Validation system (4 tiers)

3. **[knowledge/model/ENABLEMENT-TECHNICAL-GUIDE.md](knowledge/model/ENABLEMENT-TECHNICAL-GUIDE.md)** (20 min)
   - Technical implementation details
   - How Skills execute
   - How validation works

4. **[knowledge/model/standards/ASSET-STANDARDS-v1.3.md](knowledge/model/standards/ASSET-STANDARDS-v1.3.md)** (20 min)
   - Naming conventions
   - Directory structures
   - Required metadata

5. **[knowledge/orchestration/README.md](knowledge/orchestration/README.md)** (15 min)
   - How prompts become skill executions
   - Discovery rules
   - Execution framework

### Key Takeaways

- The model separates concerns: Strategic (ADR) → Tactical (ERI) → Operational (Skill)
- Every Skill has an EXECUTION-FLOW.md ensuring deterministic behavior
- Validation happens at 4 levels: Universal, Technology, Module, Runtime

### Diagram: How It All Connects

```
┌──────────────────────────────────────────────────────────────────┐
│                     GOVERNANCE FLOW                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ADR-004                    ERI-008                  mod-001      │
│  "Use Circuit Breaker"  →   "Resilience4j impl"  →   "Templates" │
│  (Strategic Decision)       (Reference Code)         (Reusable)   │
│                                                                   │
│                                    ↓                              │
│                                                                   │
│                          skill-code-001                           │
│                   "Add Circuit Breaker to Service"                │
│                     (Automated Execution)                         │
│                                                                   │
│                                    ↓                              │
│                                                                   │
│                    ┌─────────────────────┐                        │
│                    │   EXECUTION-FLOW    │                        │
│                    │ (Deterministic Steps)│                        │
│                    └─────────────────────┘                        │
│                                    ↓                              │
│                                                                   │
│              Generated Code + manifest.json (traceability)        │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Engineer - Creating Assets

**Time:** 2-4 hours  
**Goal:** Learn to author ADRs, ERIs, Modules, and Skills

### Prerequisites

- Complete the [Architect Path](#architect-path) first
- Familiarity with the technology stack (Java/Spring for CODE domain)

### Reading Order

1. **[knowledge/model/standards/authoring/README.md](knowledge/model/standards/authoring/README.md)** (10 min)
   - Overview of authoring process
   - Which guide for which asset type

2. **[knowledge/model/standards/authoring/ADR.md](knowledge/model/standards/authoring/ADR.md)** (20 min)
   - How to document strategic decisions
   - ADR template and structure

3. **[knowledge/model/standards/authoring/ERI.md](knowledge/model/standards/authoring/ERI.md)** (30 min)
   - How to create reference implementations
   - Working code examples with documentation

4. **[knowledge/model/standards/authoring/MODULE.md](knowledge/model/standards/authoring/MODULE.md)** (30 min)
   - Abstracting ERI to reusable templates
   - Template Catalog structure
   - Variables and placeholders

5. **[knowledge/model/standards/authoring/SKILL.md](knowledge/model/standards/authoring/SKILL.md)** (45 min)
   - Skill specification structure
   - **EXECUTION-FLOW.md** (deterministic execution steps)
   - Module Resolution
   - Validation orchestration

6. **[knowledge/orchestration/execution-framework.md](knowledge/orchestration/execution-framework.md)** (15 min)
   - Generic execution flow all skills follow
   - How to customize for your skill

### Practice: Creating a New Skill

After completing the reading:

1. Start by examining existing skills:
   - `knowledge/skills/skill-code-001-add-circuit-breaker-java-resilience4j/`
   - `knowledge/skills/skill-code-020-generate-microservice-java-spring/`

2. Pay special attention to:
   - `SKILL.md` - Complete specification
   - `EXECUTION-FLOW.md` - Step-by-step execution

3. Use the validation checklist in `authoring/SKILL.md` before submitting

### Key Takeaways

- Always create assets in order: ADR → ERI → Module → Skill
- Every Skill MUST have an EXECUTION-FLOW.md
- Modules own their templates in a Template Catalog
- Skills reference modules via Module Resolution

---

## Engineer - Using Skills

**Time:** 30 minutes  
**Goal:** Generate code using existing Skills

### Reading Order

1. **[README.md](README.md)** (3 min)
   - Quick overview

2. **[knowledge/README.md](knowledge/README.md)** (5 min)
   - Current inventory of available skills

3. **Choose a Skill and read its documentation:**

   **To add Circuit Breaker to existing service:**
   - `knowledge/skills/skill-code-001-add-circuit-breaker-java-resilience4j/README.md`

   **To generate a new microservice:**
   - `knowledge/skills/skill-code-020-generate-microservice-java-spring/README.md`

4. **Understand the input format:**
   - `knowledge/orchestration/prompt-template.md` (5 min)

### Quick Start: Generate a Microservice

```bash
# 1. Navigate to the skill
cd knowledge/skills/skill-code-020-generate-microservice-java-spring

# 2. Read the README
cat README.md

# 3. Review input schema
cat input-schemas/generation-request-schema.json

# 4. Create your generation request
# (follow the schema structure)

# 5. Execute (via your AI integration)
```

### Key Takeaways

- Each Skill has a README with usage instructions
- Input schemas define what parameters you need
- Generated code includes manifest.json for traceability

---

## Document Map

```
enablement-2.0/
├── GETTING-STARTED.md          ← YOU ARE HERE
├── README.md                   ← Start here for overview
│
├── knowledge/
│   ├── README.md               ← Knowledge Base structure
│   │
│   ├── model/
│   │   ├── ENABLEMENT-MODEL-v1.3.md        ← Complete conceptual model
│   │   ├── ENABLEMENT-TECHNICAL-GUIDE.md   ← Technical details
│   │   ├── ENABLEMENT-EXECUTIVE-BRIEF.md   ← Executive summary
│   │   │
│   │   └── standards/
│   │       ├── ASSET-STANDARDS-v1.3.md     ← Naming & structure
│   │       │
│   │       └── authoring/                   ← How to create assets
│   │           ├── ADR.md
│   │           ├── ERI.md
│   │           ├── MODULE.md
│   │           └── SKILL.md                 ← Includes EXECUTION-FLOW
│   │
│   ├── orchestration/           ← Execution rules (NEW)
│   │   ├── README.md
│   │   ├── discovery-rules.md
│   │   ├── execution-framework.md
│   │   └── prompt-template.md
│   │
│   ├── ADRs/                    ← Strategic decisions
│   ├── ERIs/                    ← Reference implementations
│   ├── capabilities/            ← Capability definitions
│   └── skills/                  ← Automated skills
│       └── modules/             ← Reusable templates
│
└── docs/
    └── METHODOLOGY.md           ← How we work
```

---

## FAQ

### Q: Where do I start if I just want to generate code?

Go to [Engineer - Using Skills](#engineer-using-skills) path. You can be productive in 30 minutes.

### Q: I want to add a new pattern (e.g., Bulkhead). What do I need?

Follow the [Engineer - Creating Assets](#engineer-creating-assets) path. You'll need to create:
1. ADR (if new strategic decision)
2. ERI (reference implementation)
3. Module (templates)
4. Skill (automation)

### Q: What's the difference between ERI and Module?

- **ERI** = Working reference code with documentation. It's a complete, runnable example.
- **Module** = Templates abstracted from ERI. Variables replace specific values.

### Q: What is EXECUTION-FLOW.md?

It's a mandatory file in every Skill that defines the deterministic, step-by-step execution process. It ensures reproducibility and traceability.

### Q: How do I know which validators apply to my skill?

See `knowledge/model/standards/validation/README.md`. The validation tier depends on:
- Tier 1: Always (universal checks)
- Tier 2: Based on output type (code-projects, deployments, documents)
- Tier 3: Based on modules used
- Tier 4: Runtime (CI/CD)

---

## Need Help?

1. Check `knowledge/README.md` for structure
2. Review existing assets as examples
3. Use the authoring guides in `knowledge/model/standards/authoring/`
4. Contact the C4E team

---

**Last Updated:** 2025-12-12
