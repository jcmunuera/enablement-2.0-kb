# Tier 3: Module Validators

**Version:** 2.0  
**Last Updated:** 2025-11-28

---

## Overview

Tier 3 validators are **content-specific** validations that are tightly coupled with their corresponding modules. Unlike Tier 1 and Tier 2 validators which are standalone, Tier 3 validators are **embedded within each module**.

**Important:** Every SKILL has at least one MODULE. Therefore, Tier 3 validation applies to ALL skills across ALL domains (CODE, DESIGN, QA, GOV).

## Location

Tier 3 validators are NOT stored in this directory. They are located in:

```
knowledge/skills/modules/{module-name}/validation/
```

## Why Embedded?

Module validators are embedded because:

1. **Tight Coupling:** The validation logic is intimately tied to the module's content templates
2. **Co-evolution:** When the module changes, its validator must change together
3. **Self-contained:** Each module is a complete unit including its validation
4. **Discoverability:** Validation is always found with its module
5. **Domain-agnostic:** Same pattern works for CODE, DESIGN, QA, GOV

## Module Validator Structure

Each module contains its own validation:

```
skills/modules/mod-{domain}-XXX-{name}/
├── OVERVIEW.md
├── MODULE.md
├── templates/
│   └── ...
└── validation/                    # ⬅️ Tier 3 validators here
    ├── README.md
    └── {feature}-check.sh
```

## Examples by Domain

### CODE Domain

| Module | Validator | Description |
|--------|-----------|-------------|
| `mod-001-circuit-breaker-java-resilience4j` | `circuit-breaker-check.sh` | Validates circuit breaker implementation |
| `mod-015-hexagonal-base-java-spring` | `hexagonal-check.sh` | Validates hexagonal architecture |

### DESIGN Domain (future)

| Module | Validator | Description |
|--------|-----------|-------------|
| `mod-design-001-c4-plantuml` | `c4-structure-check.sh` | Validates C4 diagram structure |
| `mod-design-002-hld-template` | `hld-sections-check.sh` | Validates HLD document sections |

### QA Domain (future)

| Module | Validator | Description |
|--------|-----------|-------------|
| `mod-qa-001-coverage-report` | `report-format-check.sh` | Validates coverage report format |
| `mod-qa-002-security-scan` | `findings-check.sh` | Validates security findings format |

### GOV Domain (future)

| Module | Validator | Description |
|--------|-----------|-------------|
| `mod-gov-001-compliance-report` | `compliance-check.sh` | Validates compliance report |
| `mod-gov-002-audit-trail` | `audit-completeness-check.sh` | Validates audit trail |

## How Skills Use Tier 3 Validators

Skills orchestrate Tier 3 validators from their associated modules:

```bash
# In skill's validate.sh

OUTPUT_DIR="${1:-.}"
MODULES="../../../modules"

TOTAL_ERRORS=0

# Tier-1 Universal (always)
bash "$VALIDATORS/tier-1-universal/traceability/traceability-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-3 Module (always - every skill has at least one module)
bash "$MODULES/mod-XXX-{name}/validation/{feature}-check.sh" "$OUTPUT_DIR"
TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Tier-3 Module (conditional - additional features)
if feature_enabled "circuit_breaker"; then
    bash "$MODULES/mod-001-circuit-breaker.../validation/circuit-breaker-check.sh" "$OUTPUT_DIR"
    TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
fi

exit $TOTAL_ERRORS
```

## Creating New Module Validators

When creating a new module (any domain), include validation in the module directory:

1. Create `validation/` directory in the module
2. Create `README.md` documenting the checks
3. Create `{feature}-check.sh` with validation logic
4. Reference ADR/ERI compliance in the validator

See `model/standards/authoring/MODULE.md` for complete module creation guide.

## Validation Execution Order

```
Tier 1 Universal      → ALWAYS first (traceability)
    ↓
Tier 1 Domain         → If domain has shared validators (e.g., code-projects)
    ↓
Tier 2 Technology     → Based on technology stack (if applicable)
    ↓
Tier 3 Module         → ALWAYS (every skill has modules)
```

## Related

- `knowledge/skills/modules/` - Actual module locations
- `model/standards/authoring/MODULE.md` - Module creation guide
- `validators/tier-1-universal/` - Universal validators
- `validators/tier-2-technology/` - Technology-specific validators

---

**Note:** This directory is a reference/index only. Actual Tier 3 validators live within their respective modules.
