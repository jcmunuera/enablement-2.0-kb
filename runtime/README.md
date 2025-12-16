# Runtime

> Orchestration, execution flows, and validation

## Purpose

This folder contains everything needed to **execute skills at runtime**:
- **Discovery**: Rules to map user prompts to skills
- **Flows**: Step-by-step execution processes by skill type
- **Validators**: Tier-1 and Tier-2 validation scripts

## Structure

```
runtime/
├── discovery/              # Prompt → Skill mapping
│   ├── README.md
│   ├── discovery-rules.md  # How to identify skills
│   ├── execution-framework.md
│   └── prompt-template.md
│
├── flows/                  # Execution flows by domain
│   └── code/              # CODE domain flows
│       ├── GENERATE.md    # Full project generation
│       ├── ADD.md         # Add feature to existing code
│       ├── REMOVE.md      # Remove feature (stub)
│       ├── REFACTOR.md    # Transform code (stub)
│       └── MIGRATE.md     # Version migration (stub)
│
└── validators/             # Validation scripts
    ├── README.md
    ├── tier-1-universal/   # Universal validators (all domains)
    └── tier-2-technology/  # Technology-specific validators
```

## Execution Flow Overview

```
1. INPUT
   └── User prompt

2. DISCOVERY (runtime/discovery/)
   ├── Identify DOMAIN (CODE, DESIGN, QA, GOV)
   ├── Read OVERVIEW.md of candidate skills
   └── Select appropriate SKILL

3. LOAD SKILL (skills/{skill}/)
   ├── Load SKILL.md (specification)
   └── Load prompts/ (agent instructions)

4. GET FLOW (runtime/flows/{domain}/{TYPE}.md)
   └── Obtain step-by-step execution process

5. EXECUTE
   ├── Follow flow steps
   ├── For CODE: resolve modules, process templates
   └── Generate output

6. VALIDATE
   ├── Tier-1: runtime/validators/tier-1-universal/
   ├── Tier-2: runtime/validators/tier-2-technology/
   └── Tier-3: modules/{mod}/validation/

7. OUTPUT
   └── Generated code + manifest
```

## Flow Types (CODE Domain)

| Type | Purpose | Modules |
|------|---------|---------|
| **GENERATE** | Create new project from scratch | Multiple modules |
| **ADD** | Add capability to existing project | Usually single module |
| **REMOVE** | Remove capability | Inverse of ADD |
| **REFACTOR** | Transform code structure | Analysis + transformation |
| **MIGRATE** | Migrate between versions/frameworks | Assessment + migration |

## Validation Tiers

| Tier | Scope | Location |
|------|-------|----------|
| **Tier-1** | Universal (all outputs) | runtime/validators/tier-1-universal/ |
| **Tier-2** | Technology-specific | runtime/validators/tier-2-technology/ |
| **Tier-3** | Module-specific | modules/{mod}/validation/ |
| **Tier-4** | Runtime/CI (future) | External CI/CD |

## Related

- Skills: `/skills/`
- Modules (Tier-3 validators): `/modules/`
- Model (standards): `/model/`
