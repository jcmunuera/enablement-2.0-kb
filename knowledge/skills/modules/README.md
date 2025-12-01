# Skill Modules

**Version:** 3.0  
**Last Updated:** 2025-11-26

---

## What are Modules?

Reusable code templates extracted from ERIs, used by multiple skills.

Each module includes:
- **MODULE.md** - Template documentation with code patterns
- **validation/** - Tier 3 validation scripts (bash)

---

## Directory Structure

```
modules/
├── README.md                                      # This file
├── mod-001-circuit-breaker-java-resilience4j/
│   ├── MODULE.md                                 # Template documentation
│   └── validation/
│       ├── README.md                             # Validation rules
│       └── circuit-breaker-check.sh              # Tier 3 validation
└── mod-015-hexagonal-base-java-spring/
    ├── MODULE.md
    └── validation/
        ├── README.md
        └── hexagonal-structure-check.sh
```

---

## Naming Convention

```
mod-XXX-pattern-framework-library/
```

**Components:**
- `XXX`: Sequential ID (001, 002, 003...)
- `pattern`: Circuit breaker, retry, hexagonal, etc.
- `framework`: java, nodejs, etc.
- `library`: resilience4j, spring, etc.

**Examples:**
- `mod-001-circuit-breaker-java-resilience4j/`
- `mod-015-hexagonal-base-java-spring/`

---

## Module Inventory

| Module | Source ERI | Purpose | Used by |
|--------|------------|---------|---------|
| **mod-001-circuit-breaker-java-resilience4j/** | ERI-CODE-008 | Circuit breaker patterns | skill-code-001, skill-code-020 |
| **mod-002-retry-java-resilience4j/** | ERI-CODE-009 | Retry patterns | skill-code-002, skill-code-020 |
| **mod-003-timeout-java-resilience4j/** | ERI-CODE-010 | Timeout patterns | skill-code-003, skill-code-020 |
| **mod-004-rate-limiter-java-resilience4j/** | ERI-CODE-011 | Rate limiter patterns | skill-code-004, skill-code-020 |
| **mod-015-hexagonal-base-java-spring/** | ERI-CODE-001 | Hexagonal Light structure | skill-code-020 |
| **mod-016-persistence-jpa-spring/** | ERI-CODE-012 | JPA persistence patterns | skill-code-005, skill-code-020 |
| **mod-017-persistence-systemapi/** | ERI-CODE-012 | System API persistence (Feign/RestTemplate/RestClient) | skill-code-006, skill-code-020 |

**Current:** 7 modules

---

## Usage

Modules are referenced in skill prompts/SPEC.md:

```markdown
## Step 4: Generate Code

Use module: ../../modules/mod-001-circuit-breaker-java-resilience4j/MODULE.md

Select template based on pattern.type
```

---

## Validation

Modules provide Tier 3 validations that skills orchestrate:

```bash
# In skill's validate.sh
source "$KNOWLEDGE_BASE/skills/modules/mod-001-.../validation/circuit-breaker-check.sh" "$SERVICE_DIR"
```

See `model/standards/validation/README.md` for details.

---

**Last Updated:** 2025-12-01
