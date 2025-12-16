# Skills

> Executable units that agents orchestrate

## Purpose

Skills are the **primary executable units** in Enablement 2.0. Each skill:
- Has a clear input/output specification
- References modules for template processing
- Follows a domain-specific execution flow
- Includes prompts for agent orchestration

## Structure

```
skills/
├── README.md
│
├── skill-code-001-add-circuit-breaker-java-resilience4j/
│   ├── SKILL.md           # Complete specification
│   ├── OVERVIEW.md        # Discovery summary (lightweight)
│   ├── prompts/           # Agent instructions
│   │   ├── SPEC.md
│   │   └── ...
│   └── validation/        # Validation orchestrator
│       └── README.md
│
└── skill-code-020-generate-microservice-java-spring/
    ├── SKILL.md
    ├── OVERVIEW.md
    ├── prompts/
    └── validation/
```

## Skill Files

| File | Purpose | Consumer |
|------|---------|----------|
| **SKILL.md** | Complete specification | Agent execution |
| **OVERVIEW.md** | Lightweight summary | Agent discovery |
| **prompts/** | Execution instructions | Agent orchestrator |
| **validation/** | Validation orchestrator | Post-execution |

## Naming Convention

```
skill-{domain}-{NNN}-{action}-{target}-{framework}-{library}
```

| Component | Example |
|-----------|---------|
| `domain` | code, design, qa, governance |
| `NNN` | 001, 020 (3-digit unique ID) |
| `action` | add, generate, remove, refactor |
| `target` | circuit-breaker, microservice |
| `framework` | java, spring |
| `library` | resilience4j (optional) |

## Current Skills

| Skill | Type | Purpose |
|-------|------|---------|
| skill-code-001-add-circuit-breaker-java-resilience4j | ADD | Add circuit breaker to existing code |
| skill-code-020-generate-microservice-java-spring | GENERATE | Generate new microservice project |

## Execution Flow

Each skill follows a flow defined in `/runtime/flows/{domain}/{TYPE}.md`:

1. **Discovery**: OVERVIEW.md helps select the right skill
2. **Load**: SKILL.md provides full specification
3. **Prompts**: prompts/ provides agent instructions
4. **Flow**: runtime/flows/ provides execution steps
5. **Modules**: /modules/ provides templates
6. **Validation**: validators verify output

## Related

- Modules (templates): `/modules/`
- Flows (execution): `/runtime/flows/`
- Model (authoring guide): `/model/standards/authoring/SKILL.md`
