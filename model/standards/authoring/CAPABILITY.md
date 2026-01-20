# Authoring Guide: CAPABILITY

**Version:** 3.0  
**Last Updated:** 2026-01-20  
**Asset Type:** Capability  
**Model Version:** 3.0

---

## What's New in v3.0

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | Capabilities are now the entry point for discovery |
| **Features Enriched** | Features include `config`, `input_spec`, `implementations` |
| **Multi-Implementation** | One feature can have multiple implementations (by stack/pattern) |
| **Stack Detection** | Explicit stack resolution with detection rules and defaults |
| **Single Discovery Path** | All discovery goes through capability-index only |

---

## Overview

Capabilities are **conceptual groupings of related features**. They represent technical concerns (architecture, persistence, resilience, etc.) and are the primary entry point for discovery.

### Capability Types

| Type | Description | Transformable | Example |
|------|-------------|---------------|---------|
| **Structural** | Defines fundamental code structure | NO | `architecture` |
| **Compositional** | Adds functionality on top of structure | YES | `resilience`, `persistence` |

---

## Entity Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       CAPABILITY HIERARCHY (v3.0)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  CAPABILITY                                                                 │
│      │                                                                      │
│      ├── type: structural | compositional                                   │
│      ├── transformable: true | false                                        │
│      ├── keywords: [...]                                                    │
│      │                                                                      │
│      └── FEATURES                                                           │
│              │                                                              │
│              ├── keywords: [...]                                            │
│              ├── requires: [other.features]                                 │
│              ├── incompatible_with: [other.features]                        │
│              ├── config: { key: value }                                     │
│              ├── input_spec: { field: schema }                              │
│              │                                                              │
│              └── IMPLEMENTATIONS                                            │
│                      │                                                      │
│                      ├── id: unique-identifier                              │
│                      ├── stack: java-spring | nodejs | ...                  │
│                      ├── pattern: annotation | client-config | ...          │
│                      └── module: mod-code-xxx                               │
│                                                                              │
│              └── default: implementation-id                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Where Capabilities Are Defined

Capabilities exist in TWO places (and must be synchronized):

### 1. capability-index.yaml (Definitive - Machine Readable)

```
runtime/discovery/capability-index.yaml
```

This is the **single source of truth** for:
- Capability type and transformable flag
- Features with all enriched attributes
- Implementations per stack/pattern
- Compatibility rules and defaults
- Keywords for discovery

### 2. Capability Documentation (Explanatory - Human Readable)

```
model/domains/code/capabilities/{capability}.md
```

This provides:
- Detailed explanation of the capability
- Usage guidelines and examples
- Related ADRs and ERIs

---

## capability-index.yaml Structure (v2.1)

```yaml
version: "2.1"
domain: code

# ─────────────────────────────────────────────────────────────────
# DEFAULTS
# ─────────────────────────────────────────────────────────────────
defaults:
  stack: java-spring                    # Organizational default
  patterns:
    timeout: annotation                 # Default when multiple patterns exist

# ─────────────────────────────────────────────────────────────────
# STACKS (with detection rules)
# ─────────────────────────────────────────────────────────────────
stacks:
  java-spring:
    description: "Java 17+ with Spring Boot 3.x"
    detection:
      - file: pom.xml
        contains: "spring-boot-starter"
    keywords: [java, spring, spring boot]
  
  java-quarkus:
    detection:
      - file: pom.xml
        contains: "quarkus"
    keywords: [java, quarkus]
  
  nodejs:
    detection:
      - file: package.json
    keywords: [node, nodejs, javascript]

# ─────────────────────────────────────────────────────────────────
# CAPABILITIES
# ─────────────────────────────────────────────────────────────────
capabilities:

  # STRUCTURAL CAPABILITY
  architecture:
    description: "Foundational architectural patterns"
    type: structural
    transformable: false
    documentation: "model/domains/code/capabilities/architecture.md"
    
    features:
      hexagonal-light:
        description: "Hexagonal Light architecture"
        keywords:
          - hexagonal
          - clean architecture
          - ports and adapters
        
        implementations:
          - id: java-spring
            module: mod-code-015-hexagonal-base-java-spring
            stack: java-spring
          # Future:
          # - id: java-quarkus
          #   module: mod-code-015-hexagonal-base-java-quarkus
          #   stack: java-quarkus
        
        default: java-spring

  # COMPOSITIONAL CAPABILITY (with enriched features)
  api-architecture:
    description: "API types according to Fusion model"
    type: compositional
    transformable: true
    documentation: "model/domains/code/capabilities/api_architecture.md"
    keywords: [API, REST, Fusion]
    
    features:
      domain-api:
        description: "Domain API - exposes business capabilities"
        keywords:
          - Domain API
          - API de dominio
          - business API
        
        # Dependencies
        requires:
          - architecture.hexagonal-light
        
        # Feature-specific configuration
        config:
          hateoas: true
          compensation_available: true
        
        # Input specification (what user must provide)
        input_spec:
          serviceName:
            type: string
            required: true
            pattern: "^[a-z][a-z0-9-]*$"
          basePackage:
            type: string
            required: true
          entities:
            type: array
            required: true
        
        # Multiple implementations
        implementations:
          - id: java-spring
            module: mod-code-019-api-public-exposure-java-spring
            stack: java-spring
        
        default: java-spring

  # COMPOSITIONAL WITH INCOMPATIBILITIES
  persistence:
    description: "Data persistence strategies"
    type: compositional
    transformable: true
    
    features:
      jpa:
        description: "JPA/Hibernate persistence"
        keywords: [JPA, database, SQL]
        
        incompatible_with:
          - persistence.systemapi
        
        implementations:
          - id: java-spring
            module: mod-code-016-persistence-jpa-spring
            stack: java-spring
        
        default: java-spring
      
      systemapi:
        description: "Persistence via System API"
        keywords: [System API, backend, legacy]
        
        requires:
          - integration.api-rest
        
        incompatible_with:
          - persistence.jpa
        
        implementations:
          - id: java-spring
            module: mod-code-017-persistence-systemapi
            stack: java-spring
        
        default: java-spring
```

---

## Creating a New Capability

### Step 1: Determine Type

| Question | If YES → |
|----------|----------|
| Does it define fundamental code structure? | Structural |
| Can existing code have this added? | Compositional |
| Would changing it require regenerating the code? | Structural |
| Is it a cross-cutting concern? | Compositional |

### Step 2: Define Features

For each feature, determine:
- **keywords:** How users will request this feature
- **requires:** Dependencies on other features
- **incompatible_with:** Mutually exclusive features
- **config:** Feature-specific configuration values
- **input_spec:** What user input is needed
- **implementations:** Which modules implement this (per stack)

### Step 3: Add to capability-index.yaml

```yaml
# In runtime/discovery/capability-index.yaml

caching:
  description: "Caching strategies"
  type: compositional
  transformable: true
  documentation: "model/domains/code/capabilities/caching.md"
  keywords:
    - cache
    - caching
  
  features:
    redis:
      description: "Distributed cache with Redis"
      keywords:
        - Redis
        - distributed cache
      
      config:
        ttl_default: 3600
        serializer: json
      
      input_spec:
        cacheName:
          type: string
          required: true
        ttl:
          type: integer
          required: false
          default: 3600
      
      implementations:
        - id: java-spring
          module: mod-code-025-cache-redis-java-spring
          stack: java-spring
      
      default: java-spring
    
    local:
      description: "Local cache with Caffeine"
      keywords:
        - local cache
        - Caffeine
        - in-memory
      
      implementations:
        - id: java-spring
          module: mod-code-026-cache-local-caffeine
          stack: java-spring
      
      default: java-spring
```

### Step 4: Create Documentation

```markdown
# model/domains/code/capabilities/caching.md

# Capability: Caching

## Overview

Caching strategies for improving performance.

## Type

- **Type:** Compositional
- **Transformable:** Yes

## Features

### redis
- Distributed cache using Redis
- Module: mod-code-025

### local
- Local in-memory cache using Caffeine
- Module: mod-code-026

## Related

- ADR: adr-015-caching-patterns
- ERI: eri-code-020-cache-redis
```

### Step 5: Create Associated Module(s)

Each implementation must have a corresponding module. See `authoring/MODULE.md`.

---

## Feature Attributes Reference

### keywords (Required)

Terms for discovery matching:

```yaml
keywords:
  - circuit breaker    # English
  - cortocircuito      # Spanish
  - CB                 # Abbreviation
  - breaker            # Partial
```

**Guidelines:**
- Include synonyms and abbreviations
- Include Spanish equivalents
- Avoid generic terms ("code", "service")

### requires (Optional)

Dependencies auto-added during discovery:

```yaml
requires:
  - architecture.hexagonal-light    # Always added if missing
  - integration.api-rest            # Always added if missing
```

### incompatible_with (Optional)

Mutually exclusive features:

```yaml
incompatible_with:
  - persistence.jpa                 # Error if both selected
```

### config (Optional)

Feature-specific configuration passed to module:

```yaml
config:
  hateoas: true
  compensation_available: true
  max_retries: 3
```

### input_spec (Optional)

Schema for user input:

```yaml
input_spec:
  serviceName:
    type: string
    required: true
    pattern: "^[a-z][a-z0-9-]*$"
    description: "Service name in kebab-case"
    example: "customer-api"
  
  entities:
    type: array
    required: true
    items:
      type: object
      properties:
        name: { type: string }
        fields: { type: array }
```

### implementations (Required)

List of implementations per stack/pattern:

```yaml
implementations:
  - id: java-spring-annotation       # Unique within feature
    module: mod-code-003-timeout     # Must exist
    stack: java-spring               # Required
    pattern: annotation              # Optional (if alternatives)
    description: "@TimeLimiter"      # Optional
  
  - id: java-spring-client-config
    module: mod-code-003b-timeout-restclient
    stack: java-spring
    pattern: client-config
```

### default (Required if multiple implementations)

Default implementation when not specified:

```yaml
default: java-spring-annotation
```

---

## Validation Checklist

### In capability-index.yaml

- [ ] Has `type: structural` or `type: compositional`
- [ ] Has `transformable: true` or `false`
- [ ] Structural capabilities have `transformable: false`
- [ ] Each feature has `keywords` array
- [ ] Each feature has `implementations` array
- [ ] Each implementation has `id`, `module`, `stack`
- [ ] Feature has `default` if multiple implementations
- [ ] All referenced modules exist
- [ ] `requires` references valid features
- [ ] `incompatible_with` references valid features

### In documentation

- [ ] File exists at path specified in `documentation`
- [ ] Overview explains purpose clearly
- [ ] All features are documented
- [ ] Compatibility is explained
- [ ] Related ADRs/ERIs are referenced

---

## Common Patterns

### Multi-Implementation Feature

```yaml
timeout:
  implementations:
    - id: java-spring-annotation
      module: mod-003-timeout-resilience4j
      stack: java-spring
      pattern: annotation
    
    - id: java-spring-client
      module: mod-003b-timeout-restclient
      stack: java-spring
      pattern: client-config
  
  default: java-spring-annotation
```

### Feature with Config

```yaml
domain-api:
  config:
    hateoas: true
    compensation_available: true
  
  implementations:
    - id: java-spring
      module: mod-019
      stack: java-spring
```

### Feature with Input Spec

```yaml
domain-api:
  input_spec:
    serviceName:
      type: string
      required: true
    entities:
      type: array
      required: true
```

### Mutually Exclusive Features

```yaml
jpa:
  incompatible_with: [persistence.systemapi]

systemapi:
  incompatible_with: [persistence.jpa]
```

---

## Related

- `runtime/discovery/capability-index.yaml` - Central capability index
- `ENABLEMENT-MODEL-v3.0.md` - Core model documentation
- `authoring/MODULE.md` - How modules implement features
- `runtime/discovery/discovery-guidance.md` - Discovery algorithm

---

**Last Updated:** 2026-01-20
