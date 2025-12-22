# Authoring Guide: MODULE

**Version:** 1.8  
**Last Updated:** 2025-12-22  
**Asset Type:** Module

---

## Overview

Modules are **reusable content generation templates** derived from ERIs. They encapsulate implementation patterns with variable placeholders, embedded validation (Tier 3), and can be composed by multiple Skills. While often associated with code generation, modules can also produce documents, reports, configurations, or any structured content.

### Module Role by Skill Type

> **NEW in v1.7:** Modules function differently depending on skill type.

| Skill Type | Module Role | How Used |
|------------|-------------|----------|
| **GENERATE** | Knowledge source | Agent CONSULTS module templates as GUIDANCE. Generates code holistically in one pass, considering all modules together. Templates are not executed sequentially. |
| **ADD** | Transformation guide | Module templates APPLIED directly to add feature to existing code. More deterministic transformation. |
| **REMOVE** | Identification guide | Used to identify what patterns to remove. |
| **REFACTOR** | Pattern reference | Guidance for code transformation. |

**For GENERATE skills:**
- The agent reads MODULE.md to understand the pattern
- The agent reads templates to understand code structure
- The agent generates ALL code in ONE pass considering ALL modules
- Templates are GUIDANCE, not scripts to execute
- Validation (Tier-3) runs AFTER generation to verify compliance

**For ADD skills:**
- Templates are more directly applied
- Execution is more deterministic
- Single module typically used

## When to Create a Module

Create a Module when:

- An ERI exists that should be reusable across multiple projects
- Content generation needs parameterized templates
- A feature/pattern needs its own validation rules
- Multiple Skills will use the same content pattern
- **A Skill needs to be created** (every Skill requires at least one Module)

Do NOT create a Module for:

- One-off implementations
- Patterns without an ERI reference
- Content that doesn't need parameterization

---

## Module Desglose Criteria (from Multi-Option ERIs)

When an ERI documents multiple implementation options, use these criteria to determine how many MODULEs to create:

### Decision Framework

```
ERI with multiple options
         │
         ├── Are options FUNCTIONALLY EQUIVALENT?
         │   (Same result, different syntax/style)
         │
         │   YES ────────────────────────────────────────────────────────────
         │   │                                                               │
         │   │  Create 1 MODULE with VARIANTS                                │
         │   │                                                               │
         │   │  Structure:                                                   │
         │   │  mod-{domain}-{NNN}-pattern-framework/                                   │
         │   │  ├── MODULE.md (documents all variants)                       │
         │   │  ├── templates/                                               │
         │   │  │   ├── {concern}/          # Organized by concern           │
         │   │  │   │   ├── variant-a.tpl   # Variants in same directory     │
         │   │  │   │   ├── variant-b.tpl                                    │
         │   │  │   │   └── variant-c.tpl                                    │
         │   │  │   └── {other-concern}/    # Shared templates               │
         │   │  └── validation/                                              │
         │   │                                                               │
         │   │  The SKILL selects the variant via parameter                  │
         │   └───────────────────────────────────────────────────────────────
         │
         └── Are options FUNCTIONALLY DISPARATE?
             (Different architecture, different adapters, different concerns)
         
             YES ────────────────────────────────────────────────────────────
             │                                                               │
             │  Create SEPARATE MODULEs                                      │
             │                                                               │
             │  Structure:                                                   │
             │  mod-{domain}-{NNN}-pattern-option-a-framework/                          │
             │  ├── MODULE.md                                                │
             │  ├── templates/                                               │
             │  └── validation/                                              │
             │                                                               │
             │  mod-{domain}-{NNN+1}-pattern-option-b-framework/                          │
             │  ├── MODULE.md                                                │
             │  ├── templates/                                               │
             │  └── validation/                                              │
             │                                                               │
             │  Each MODULE has distinct validation rules and templates      │
             └───────────────────────────────────────────────────────────────
```

### Functional Equivalence Test

Ask these questions to determine if options are functionally equivalent:

| Question | If YES → Equivalent | If NO → Disparate |
|----------|---------------------|-------------------|
| Do they produce the same **architectural result**? | Same adapter structure | Different adapter types |
| Do they use the same **domain abstractions**? | Same repository interface | Different interfaces |
| Are they **interchangeable** at runtime? | Could swap with config change | Requires code restructure |
| Do they have the same **validation rules**? | Same constraints apply | Different constraints |

### Examples

#### Functionally Equivalent → 1 MODULE with Variants

**ERI-012 System API Client Options:**
- Feign, RestTemplate, RestClient
- All produce: REST client that calls external API
- Same adapter structure, same resilience patterns
- Interchangeable (swap by changing config/dependency)

**Result:** `mod-code-017-persistence-systemapi` with `templates/feign/`, `templates/resttemplate/`, `templates/restclient/`

```yaml
# SKILL parameter selects variant
persistence:
  type: system_api
  system_api:
    client: feign  # or resttemplate, restclient
```

#### Functionally Disparate → Separate MODULEs

**ERI-012 Persistence Options:**
- JPA (local database, owns data)
- System API (mainframe delegation, consumer)
- Different adapter types (persistence/ vs systemapi/)
- Different validation rules (no resilience on JPA, mandatory on System API)
- Not interchangeable (architectural decision)

**Result:** `mod-code-016-persistence-jpa-spring` + `mod-code-017-persistence-systemapi`

### Summary Table

| ERI | Options | Equivalence | MODULEs |
|-----|---------|-------------|---------|
| Persistence | JPA, System API | Disparate | 2 (mod-code-016, mod-code-017) |
| System API Client | Feign, RestTemplate, RestClient | Equivalent | 1 with 3 variants |
| Messaging | Kafka, RabbitMQ | Disparate | 2 |
| Database | PostgreSQL, MySQL | Equivalent | 1 with variants |
| Caching | Redis, Caffeine | Disparate | 2 |

---

## Variant Implementation (v1.8)

> **NEW in v1.8:** Formal structure for variants with explicit defaults.

When a module has functionally equivalent implementation options, it MUST define them as **variants** with one **explicit default**.

### Source of Truth: ERI

> **CRITICAL:** Module variants MUST derive from ERI implementation options. A module CANNOT offer variants that are not defined as valid options in its source ERI.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ERI → MODULE DERIVATION RULE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ERI defines:                              MODULE inherits:                  │
│  ─────────────                             ────────────────                  │
│  implementation_options.options[].id   →   variants.default.id              │
│                                            variants.alternatives[].id       │
│  implementation_options.default        →   variants.default                 │
│  options[].recommended_when            →   alternatives[].recommend_when    │
│  options[].status = deprecated         →   alternatives[].deprecated: true  │
│  Reference code per option             →   Template content per variant     │
│                                                                              │
│  ❌ Module CANNOT add variants not in ERI                                   │
│  ❌ Module CANNOT change which option is default (without ERI update)       │
│  ✅ Module CAN refine recommend_when conditions for runtime context         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### When to Evaluate Variants (Authoring Process)

During module creation, the author MUST check the source ERI for options:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VARIANT EVALUATION PROCESS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. READ source ERI's Implementation Options section                         │
│     └─ Does the ERI define multiple valid options?                           │
│     └─ If NO options section → Module has no variants                        │
│                                                                              │
│  2. EVALUATE functional equivalence (if not already done in ERI)             │
│     └─ Do all options produce the same architectural result?                 │
│     └─ Are they interchangeable without code restructure?                    │
│                                                                              │
│  3. DECIDE:                                                                  │
│     ├─ If functionally EQUIVALENT → Single module with VARIANTS              │
│     └─ If functionally DISPARATE → Separate modules                          │
│                                                                              │
│  4. If VARIANTS (derive from ERI):                                           │
│     a. INHERIT default from ERI's implementation_options.default             │
│     b. INHERIT alternatives from ERI's options with status != default        │
│     c. OPERATIONALIZE recommend_when from ERI for runtime conditions         │
│     d. CREATE template files for each ERI option                             │
│     e. SET selection_mode (explicit vs auto-suggest)                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Variant Evaluation Checklist

Before finalizing a module, answer these questions:

| Question | Action |
|----------|--------|
| Does the source ERI have an `implementation_options` section? | If YES → Module will have variants |
| Does each module variant correspond to an ERI option? | MUST be YES → Validate mapping |
| Is the module's default the same as ERI's default? | MUST be YES → Inherit from ERI |
| Are recommend_when conditions derived from ERI's recommended_when? | SHOULD be YES → Refine for runtime |
| Are deprecated variants marked as such per ERI? | MUST be YES → Inherit status |

### Variant Validation Rule

> **Before publishing a module with variants, verify:**
> 1. Source ERI has `implementation_options` section
> 2. Every module variant.id matches an ERI option.id
> 3. Module default matches ERI default
> 4. No variants exist that aren't in ERI

### Why Variants Matter

Without explicit variant definition:
- AI agents interpret templates freely
- Multiple executions produce different code
- Code quality becomes unpredictable

With explicit variants (derived from ERI):
- Options are architecturally validated (in ERI)
- Default variant is used automatically
- Alternative variants require explicit selection
- Code generation is deterministic

### Variant Structure in MODULE.md

Add a `variants` section to the MODULE.md frontmatter:

```yaml
---
id: mod-code-018-api-integration-rest-java-spring
# ... other frontmatter ...

variants:
  enabled: true
  selection_mode: explicit | auto-suggest
  
  default:
    id: restclient
    name: "RestClient (Spring 6.1+)"
    description: "Modern REST client, recommended for Spring Boot 3.2+"
    templates:
      - client/restclient.java.tpl
      - config/restclient-config.java.tpl
    
  alternatives:
    - id: feign
      name: "OpenFeign"
      description: "Declarative REST client"
      templates:
        - client/feign.java.tpl
        - config/feign-config.java.tpl
      recommend_when:
        - condition: "Existing codebase uses Feign"
          reason: "Consistency with existing patterns"
        - condition: "Team prefers declarative style"
          reason: "Simpler interface definition"
      
    - id: resttemplate
      name: "RestTemplate (Legacy)"
      description: "Traditional REST client"
      templates:
        - client/resttemplate.java.tpl
        - config/resttemplate-config.java.tpl
      deprecated: true
      deprecation_reason: "RestClient is preferred for new projects"
---
```

### Selection Mode

| Mode | Behavior | Use When |
|------|----------|----------|
| `explicit` | Use default unless input specifies variant | Most modules - stable default |
| `auto-suggest` | Ask user if alternative conditions match | When context matters for choice |

### Template Organization for Variants

```
templates/
├── client/                    # Concern: REST client
│   ├── restclient.java.tpl    # Default variant
│   ├── feign.java.tpl         # Alternative
│   └── resttemplate.java.tpl  # Alternative (deprecated)
├── config/                    # Concern: Configuration
│   ├── restclient-config.java.tpl
│   ├── feign-config.java.tpl
│   └── resttemplate-config.java.tpl
└── common/                    # Shared across variants
    └── IntegrationException.java.tpl
```

### Variant Selection by Skills

Skills select variants via input parameters:

```json
{
  "features": {
    "integration": {
      "client": "feign"  // Explicit selection, overrides default
    }
  }
}
```

If not specified, the default variant is used automatically.

### Variant Documentation Requirements

Each variant MUST document:

| Field | Required | Description |
|-------|----------|-------------|
| `id` | ✅ | Unique identifier for the variant |
| `name` | ✅ | Human-readable name |
| `description` | ✅ | What it is and when to use |
| `templates` | ✅ | List of template files |
| `recommend_when` | ❌ | Conditions that suggest this variant |
| `deprecated` | ❌ | Whether this variant is deprecated |
| `deprecation_reason` | ❌ | Why deprecated and what to use instead |

### Variants in Non-CODE Domains

> **IMPORTANT:** If a skill in ANY domain (DESIGN, QA, GOVERNANCE) has implementation alternatives, it MUST have a module that defines them.

This rule simplifies the model:

| Domain | Example Skill | Variants Example | Requires Module? |
|--------|--------------|------------------|------------------|
| CODE | Generate microservice | RestClient vs Feign | ✅ Yes (mod-018) |
| DESIGN | Generate diagram | C4 vs Mermaid vs PlantUML | ✅ Yes (if variants exist) |
| QA | Generate test report | JUnit XML vs HTML vs JSON | ✅ Yes (if variants exist) |
| GOVERNANCE | Generate checklist | Markdown vs DOCX | ✅ Yes (if variants exist) |

**Rule:** "If a skill has implementation alternatives, it MUST have a module that defines variants with a default."

This ensures:
- Consistent variant handling across all domains
- Single mechanism for variant selection (in modules)
- Flows can use the same variant resolution logic

---

## Determinism Rules (v1.8)

> **NEW in v1.8:** Mandatory patterns for consistent code generation.

### Purpose

Ensure that multiple executions with the same input produce **identical** code output.

### Global Mandatory Patterns

These patterns MUST be followed by ALL code modules:

| Element | Required Pattern | Rationale |
|---------|-----------------|-----------|
| Value Objects (IDs) | `record` with `UUID` | Immutability, type safety |
| Request DTOs | `record` | Immutability |
| Response DTOs (no HATEOAS) | `record` | Immutability |
| Response DTOs (HATEOAS) | `class extends RepresentationModel` | Framework requirement |
| Domain Entities | `class` | Mutable by design |
| Domain Enums | Simple (no attributes) | Code mapping in mapper |
| Mappers | Dedicated `@Component` class | Single responsibility |

### Forbidden Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| Lombok `@Data` on DTOs | Records are cleaner | Java `record` |
| Code mapping in Enum | Couples domain to external | Mapper class |
| `String` for entity IDs | Loses type safety | `UUID` or typed wrapper |
| Inline validation in Entity constructor | Inconsistent | Dedicated validation methods |

### Required Annotations

All generated code MUST include these annotations:

```java
/**
 * [Class description]
 * 
 * @generated {skill-id} v{version}
 * @module {module-id}
 * @variant {variant-id}  // Only if non-default variant used
 */
```

### Module-Specific Determinism Section

Each MODULE.md MUST include a `## Determinism` section specifying:

```markdown
## Determinism

### Mandatory Patterns

| Element | Pattern | Enforced By |
|---------|---------|-------------|
| [element] | [required pattern] | [validation script] |

### Configurable Elements

| Element | Options | Default | Selection |
|---------|---------|---------|-----------|
| [element] | [options] | [default] | [how to select] |
```

---

## Directory Structure

```
modules/
└── mod-{domain}-{NNN}-{pattern}-{framework}-{library}/
    ├── MODULE.md           # Main documentation (required)
    ├── templates/          # Template files (required)
    │   └── {concern}/      # Organized by architectural concern
    │       └── *.tpl       # Template files
    └── validation/         # Tier 3 validation (required)
        ├── README.md
        └── *-check.sh      # Validation scripts
```

### Naming Convention

**Pattern:** `mod-{domain}-{NNN}-{pattern}-{framework}-{library}`

| Component | Description | Example |
|-----------|-------------|---------|
| `mod` | Asset type prefix | `mod` |
| `{domain}` | Domain ownership (code, design, qa, governance) | `code` |
| `{NNN}` | Unique identifier (3 digits) | `001`, `015` |
| `{pattern}` | Pattern name (kebab-case) | `circuit-breaker`, `hexagonal-base` |
| `{framework}` | Target framework | `java`, `spring` |
| `{library}` | Implementation library (optional) | `resilience4j`, `jpa` |

**Examples:**
- `mod-code-001-circuit-breaker-java-resilience4j`
- `mod-code-015-hexagonal-base-java-spring`
- `mod-code-016-persistence-jpa-spring`
- `mod-design-001-architecture-diagram-mermaid` (future)

> **IMPORTANT:** All code/config templates MUST be in separate `.tpl` files, NOT inline in MODULE.md. The MODULE.md should reference templates but not contain them.

---

## Template Format

All templates use **Mustache/Handlebars syntax** for placeholders and control structures.

### Placeholder Syntax

| Syntax | Purpose | Example |
|--------|---------|---------|
| `{{variable}}` | Simple variable substitution | `{{basePackage}}`, `{{Entity}}` |
| `{{#section}}...{{/section}}` | Conditional/Loop block | `{{#entityFields}}...{{/entityFields}}` |
| `{{^section}}...{{/section}}` | Inverted block (if not) | `{{^nullable}}NOT NULL{{/nullable}}` |
| `{{! comment }}` | Comment (not rendered) | `{{! This is ignored }}` |

### Template Header Convention

Each `.tpl` file should start with a comment header:

```java
// Template: EntityService.java.tpl
// Output: {{basePackage}}/domain/service/{{Entity}}Service.java
// Purpose: Domain service for business logic
```

For YAML/XML files:

```yaml
# Template: application.yml.tpl
# Output: src/main/resources/application.yml
# Purpose: Main application configuration
```

### Common Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `{{basePackage}}` | Base Java package | `com.company.customer` |
| `{{Entity}}` | Entity name (PascalCase) | `Customer` |
| `{{entity}}` | Entity name (camelCase) | `customer` |
| `{{entityPlural}}` | Pluralized entity (kebab) | `customers` |
| `{{serviceName}}` | Service identifier | `customer-service` |

### Rationale

Mustache/Handlebars was chosen because:
- **Logic-less** - Templates stay simple, logic lives in the generator
- **Language agnostic** - Same syntax for Java, YAML, XML, etc.
- **Wide support** - Libraries available in Java, Node.js, Python, Go
- **Readable** - `{{Entity}}` is clearer than `${entity}` or `<%= entity %>`

---

## Template Organization

Templates within a MODULE must be organized **by architectural concern**, not by implementation variant. This ensures consistency across modules and makes it easier for SKILLs to locate templates.

### Directory Naming Conventions

| Rule | Convention | Example |
|------|------------|---------|
| **Case** | lowercase only | `adapter/`, `client/` |
| **Compound names** | No separator (preferred) or kebab-case | `resttemplate/`, `rest-template/` |
| **Avoid** | camelCase, PascalCase, snake_case | ~~`restTemplate/`~~, ~~`rest_template/`~~ |

**Rationale:** Lowercase without separators avoids cross-platform issues (Windows is case-insensitive) and matches how Spring names its classes internally.

### Standard Template Directory Structure

For code generation modules, organize templates by **architectural layer/concern**:

```
templates/
├── dto/                    # Data Transfer Objects
│   └── Dto.java.tpl
├── mapper/                 # Mappers between layers
│   └── Mapper.java.tpl
├── adapter/                # Adapter implementations
│   └── Adapter.java.tpl
├── client/                 # External clients (with variants if applicable)
│   ├── feign.java.tpl
│   ├── resttemplate.java.tpl
│   └── restclient.java.tpl
├── config/                 # Configuration files
│   ├── application.yml.tpl
│   └── feign-config.java.tpl
├── exception/              # Exception classes
│   └── Exception.java.tpl
└── test/                   # Test templates
    └── AdapterTest.java.tpl
```

### Handling Variants

When a MODULE has **functionally equivalent variants** (e.g., different REST clients), place them in the **same directory** with descriptive filenames:

```
# CORRECT: Variants in same directory by concern
templates/
└── client/
    ├── feign.java.tpl
    ├── resttemplate.java.tpl
    └── restclient.java.tpl

# INCORRECT: Separate directories per variant
templates/
├── feign/
│   └── Client.java.tpl
├── resttemplate/
│   └── Client.java.tpl
└── restclient/
    └── Client.java.tpl
```

**Rationale:** 
- Grouping by concern makes it clear these are alternatives for the same purpose
- SKILLs can easily select the variant by filename pattern
- Reduces directory nesting

### Template File Naming

| Component | Pattern | Example |
|-----------|---------|---------|
| **Main template** | `{Component}.java.tpl` | `Adapter.java.tpl` |
| **Variant template** | `{variant}.java.tpl` | `feign.java.tpl` |
| **Config template** | `{config-name}.yml.tpl` | `application.yml.tpl` |
| **Test template** | `{Component}Test.java.tpl` | `AdapterTest.java.tpl` |

### Complete Example: mod-code-017-persistence-systemapi

```
mod-code-017-persistence-systemapi/
├── MODULE.md
├── templates/
│   ├── dto/
│   │   └── Dto.java.tpl
│   ├── mapper/
│   │   └── SystemApiMapper.java.tpl
│   ├── adapter/
│   │   └── SystemApiAdapter.java.tpl
│   ├── client/
│   │   ├── feign.java.tpl
│   │   ├── resttemplate.java.tpl
│   │   └── restclient.java.tpl
│   ├── config/
│   │   ├── application-systemapi.yml.tpl
│   │   └── feign-config.java.tpl
│   ├── exception/
│   │   └── SystemApiUnavailableException.java.tpl
│   └── test/
│       └── SystemApiAdapterTest.java.tpl
└── validation/
    ├── README.md
    └── systemapi-check.sh
```

---

## Naming Convention

```
mod-{domain}-{NNN}-{pattern}-{framework}-{library}
```

- `XXX`: 3-digit sequential number (001-999)
- `{pattern}`: Pattern being templated (kebab-case)
- `{framework}`: Technology framework
- `{library}`: Specific library if applicable

**Examples:**
- `mod-code-001-circuit-breaker-java-resilience4j`
- `mod-code-015-hexagonal-base-java-spring`
- `mod-code-020-circuit-breaker-nodejs-opossum`

---

## Required Files

### 1. MODULE.md

Main documentation with complete specifications.

```yaml
---
id: mod-{domain}-{NNN}-{pattern}-{framework}-{library}
title: "Module: {Title}"
version: X.Y.Z
date: YYYY-MM-DD
updated: YYYY-MM-DD
status: Draft|Active|Deprecated
derived_from: eri-{domain}-XXX-...   # REQUIRED - Source ERI
implements_adr: adr-XXX-...           # Optional - Direct ADR reference
tier: 3
tags:
  - {tag1}
used_by_skills:
  - skill-{domain}-XXX-...
---
```

### 2. OVERVIEW.md

Quick reference for Skills to understand the module.

```markdown
# mod-{domain}-{NNN}-{pattern}-{framework}-{library}

**Source ERI:** eri-{domain}-XXX-...  
**Version:** X.Y.Z

## Purpose

[One paragraph explaining what this module provides]

## Template Variables

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `{{serviceName}}` | string | ✅ | Service/class name (PascalCase) |
| `{{packageName}}` | string | ✅ | Base package (dot notation) |

## Template Catalog

This catalog defines the **output path** for each template. Skills use this to determine where each generated file should be placed.

| Template | Output Path | Description |
|----------|-------------|-------------|
| `Config.java.tpl` | `src/main/java/{packagePath}/config/{serviceName}Config.java` | Configuration class |

## Validation

Tier 3 validation checks in `validation/`:

| Script | Validates |
|--------|-----------|
| `{feature}-check.sh` | {what it validates} |

## Usage

Used by:
- skill-{domain}-XXX-...
```

---

## Template Format

### Handlebars Templates (.hbs)

```handlebars
// File: templates/Config.java.hbs
// Output: {{packagePath}}/config/{{serviceName}}Config.java

package {{packageName}}.config;

import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

/**
 * {{serviceName}} Circuit Breaker Configuration
 * Generated by: mod-{domain}-{NNN}-{pattern}-{framework}-{library}
 * ERI Reference: eri-{domain}-XXX-...
 */
@Configuration
public class {{serviceName}}Config {

    @Bean
    public CircuitBreakerConfig circuitBreakerConfig() {
        return CircuitBreakerConfig.custom()
            .slidingWindowSize({{slidingWindowSize}})
            .failureRateThreshold({{failureRateThreshold}})
            .waitDurationInOpenState(Duration.ofSeconds({{waitDuration}}))
            .build();
    }
}
```

### Template Variables

| Category | Variable | Type | Description |
|----------|----------|------|-------------|
| **Identity** | `{{serviceName}}` | string | PascalCase service name |
| | `{{serviceNameLower}}` | string | camelCase service name |
| | `{{serviceNameKebab}}` | string | kebab-case service name |
| **Package** | `{{packageName}}` | string | Dot notation (com.company.service) |
| | `{{packagePath}}` | string | Path notation (com/company/service) |
| **Config** | `{{configValue}}` | varies | Module-specific configuration |

---

## Tier 3 Validation

Each module MUST include validation scripts that verify the ERI constraints are met.

### validation/README.md

```markdown
# Tier 3 Validation: mod-{domain}-{NNN}-{pattern}

## Checks

| Script | Severity | Description |
|--------|----------|-------------|
| `{feature}-check.sh` | ERROR | {critical check} |
| `{feature}-config-check.sh` | WARNING | {recommended check} |

## ERI Constraint Mapping

| ERI Constraint | Script | Check |
|----------------|--------|-------|
| {constraint-1} | {script} | {how it's validated} |
```

### validation/{feature}-check.sh

```bash
#!/bin/bash
# {feature}-check.sh
# Tier 3 validation for mod-{domain}-{NNN}-{pattern}
# Validates ERI constraint: {constraint description}

SERVICE_DIR="${1:-.}"
PACKAGE_PATH="${2:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS:${NC} $1"; }
fail() { echo -e "${RED}❌ FAIL:${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}⚠️  WARN:${NC} $1"; }

ERRORS=0

# Check 1: {Description}
if [ condition ]; then
    pass "{what passed}"
else
    fail "{what failed}"
fi

# Check 2: {Description}
# ...

exit $ERRORS
```

---

## Complete MODULE.md Template

```markdown
# Module: {Title}

**Module ID:** mod-{domain}-{NNN}-{pattern}-{framework}-{library}  
**Source ERI:** eri-{domain}-XXX-...  
**Version:** X.Y.Z  
**Status:** Active

---

## Purpose

[What this module provides and when to use it]

## Template Variables

### Required Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `serviceName` | string | Service name (PascalCase) | `CustomerService` |
| `packageName` | string | Base package | `com.company.customer` |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `slidingWindowSize` | int | 10 | Circuit breaker window |

---

## Template Catalog

This catalog defines the **output path** for each template provided by this module.

| Template | Output Path | Description |
|----------|-------------|-------------|
| `{concern}/{Name}.java.tpl` | `src/main/java/{{basePackagePath}}/{layer}/{Name}.java` | {description} |

> **Note:** Templates are stored in `templates/` directory. The actual template content
> is in the .tpl files, not inline in this document.

---

## Validation (Tier 3)

### Scripts

| Script | Severity | Validates |
|--------|----------|-----------|
| `{script}.sh` | ERROR | {validation} |

### ERI Constraint Mapping

| ERI Constraint | Severity | Script | Check |
|----------------|----------|--------|-------|
| {constraint} | ERROR | {script} | {check} |

---

## Usage by Skills

This module is used by:

- `skill-{domain}-XXX-...` - {how it's used}

### Integration Example

```bash
# In skill's generate.sh
render_template "mod-{domain}-{NNN}-{pattern}/templates/Config.java.hbs" \
    --var serviceName="$SERVICE_NAME" \
    --var packageName="$PACKAGE_NAME" \
    --output "$OUTPUT_DIR/$PACKAGE_PATH/config/${SERVICE_NAME}Config.java"
```

---

## Related

- **ERI:** [eri-{domain}-XXX-...](../../../ERIs/eri-{domain}-XXX-.../)
- **ADR:** [adr-XXX-...](../../../ADRs/adr-XXX-.../)
- **Skills:** [skill-{domain}-XXX-...](../skill-{domain}-XXX-.../)

---

## Changelog

| Date | Version | Change | Author |
|------|---------|--------|--------|
| {date} | 1.0.0 | Initial version | {author} |
```

---

## Validation Checklist

Before marking a Module as "Active":

- [ ] `MODULE.md` is complete with all sections
- [ ] **`derived_from` references the source ERI** ← REQUIRED
- [ ] `OVERVIEW.md` provides quick reference
- [ ] All templates are in `templates/` directory
- [ ] Templates use consistent variable naming
- [ ] `validation/` contains at least one check script
- [ ] Validation scripts map to ERI constraints
- [ ] At least one Skill uses this module
- [ ] Templates generate compilable code
- [ ] **If module has variants, each corresponds to an ERI option** ← If applicable

---

## Relationships

```
ERI
 │
 │ abstracts_to (1:N)
 │ ERI provides reference code, Module makes it reusable
 │
 ▼
Module ─────────────────────────────────────────────────
 │                                                      │
 │ used_by (N:N)                                        │ validates_with
 │ Multiple Skills can use same Module                  │ Tier 3 validation
 │                                                      │
 ▼                                                      ▼
Skill                                            validation/*-check.sh
```

### Required Relationships

| Relationship | Requirement |
|--------------|-------------|
| `derived_from` | MUST reference exactly one ERI |
| `validation/` | MUST have at least one validation script |

> **CRITICAL:** Every module MUST have a `derived_from` field in its frontmatter pointing to the source ERI. Modules without an ERI reference are invalid.

---

## Best Practices

### Templates

1. **Idempotent:** Running twice produces same result
2. **Complete:** Generated code compiles without modification
3. **Documented:** Each template has header comment
4. **Testable:** Output can be validated

### Validation

1. **Map to ERI:** Each ERI constraint should have a validation
2. **Clear errors:** Messages explain what's wrong and how to fix
3. **Exit codes:** 0 = pass, non-zero = fail
4. **Severity:** Use ERROR for must-fix, WARNING for should-fix

### Synchronization with SKILLs

1. **Every template MUST be in Template Catalog** with its output path
2. **When adding templates:** Add entry to Template Catalog section
3. **When removing templates:** Remove from Template Catalog, check SKILLs for orphan references
4. **Template Catalog is authoritative** - Agents must use cataloged templates, not improvise

> **IMPORTANT:** The Template Catalog in MODULE.md is the single source of truth for 
> template → output path mapping. SKILLs reference modules via Module Resolution, 
> then use each module's Template Catalog to determine outputs.

---

## Related

- `model/standards/ASSET-STANDARDS-v1.4.md` - Module structure specification
- `authoring/ERI.md` - How to create source ERIs
- `authoring/SKILL.md` - How to create Skills that use Modules
- `modules/` - Existing modules

---

**Last Updated:** 2025-12-01
