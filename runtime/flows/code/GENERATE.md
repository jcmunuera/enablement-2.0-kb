# Skill Type: CODE/GENERATE

**Version:** 1.0  
**Last Updated:** 2025-12-12  
**Domain:** CODE

---

## Purpose

GENERATE skills create new code projects from scratch based on requirements. They produce complete, runnable project structures.

---

## Characteristics

| Aspect | Description |
|--------|-------------|
| Input | Requirements (JSON/YAML generation request) |
| Output | Complete project structure |
| Modules | Multiple (N modules based on features) |
| Complexity | High - orchestrates many modules |

---

## Input Schema

```yaml
# generation-request.yaml
serviceName: "customer-service"
groupId: "com.example"
artifactId: "customer-service"
version: "1.0.0"
description: "Customer management service"

apiType: "domain_api"  # experience_api | composable_api | domain_api

features:
  resilience:
    circuit_breaker:
      enabled: true
      pattern: "basic_fallback"
    retry:
      enabled: true
      strategy: "exponential_backoff"
    timeout:
      enabled: true
      strategy: "client_level"
      duration: "10s"
  
  persistence:
    type: "jpa"  # jpa | system_api | none
    
  integration:
    rest_clients:
      - name: "inventory-service"
        baseUrl: "${INVENTORY_SERVICE_URL}"
        endpoints:
          - name: "getStock"
            method: "GET"
            path: "/api/v1/stock/{productId}"
```

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     CODE/GENERATE EXECUTION FLOW                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  STEP 1: VALIDATE INPUT                                                      │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Validate generation-request against schema                          │
│  Input:  generation-request.yaml                                             │
│  Output: Validated request or ERROR                                          │
│                                                                              │
│  Rules:                                                                      │
│  - serviceName: required, pattern [a-z][a-z0-9-]*                           │
│  - groupId: required, valid Java package                                     │
│  - features: at least one feature enabled                                    │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 2: RESOLVE MODULES                                                     │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Determine which modules to use based on features                    │
│  Input:  Validated request + Capability definitions                          │
│  Output: Ordered list of modules                                             │
│                                                                              │
│  Resolution Rules:                                                           │
│  - Always include: mod-code-015-hexagonal-base (base architecture)          │
│  - If circuit_breaker.enabled → mod-code-001-circuit-breaker                │
│  - If retry.enabled → mod-code-002-retry                                    │
│  - If timeout.enabled + strategy=timelimiter → mod-code-003-timeout         │
│  - If timeout.enabled + strategy=client_level → mod-code-018-integration    │
│  - If persistence.type=jpa → mod-code-016-persistence-jpa                   │
│  - If persistence.type=system_api → mod-code-017-persistence-systemapi      │
│  - If integration.rest_clients not empty → mod-code-018-integration         │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 3: BUILD VARIABLE CONTEXT                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Extract and compute all template variables                          │
│  Input:  Request + Module variable definitions                               │
│  Output: Complete variable context                                           │
│                                                                              │
│  Variable Sources:                                                           │
│  - Direct from request: serviceName, groupId, artifactId                    │
│  - Computed: ServiceName (PascalCase), package (path format)                │
│  - From features: config values with defaults                                │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 4: PROCESS EACH MODULE                                                 │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: For each resolved module, process its Template Catalog              │
│  Input:  Module + Variable context                                           │
│  Output: Generated files                                                     │
│                                                                              │
│  For each module (in order):                                                 │
│    For each template in Template Catalog:                                    │
│      1. Load template file                                                   │
│      2. Apply variable substitution                                          │
│      3. Determine output path                                                │
│      4. Write to output (create/merge based on strategy)                    │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 5: MERGE CONFIGURATION FILES                                           │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Combine contributions to shared files                               │
│  Input:  All module outputs                                                  │
│  Output: Merged application.yml, pom.xml, etc.                              │
│                                                                              │
│  Merge targets:                                                              │
│  - application.yml: Deep merge YAML                                          │
│  - pom.xml: Merge dependencies, plugins                                      │
│  - Dockerfile: Merge if multiple contributions                               │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 6: GENERATE MANIFEST                                                   │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Create traceability manifest                                        │
│  Input:  All decisions and outputs                                           │
│  Output: .enablement/manifest.json                                           │
│                                                                              │
│  Manifest contains:                                                          │
│  - Generation timestamp                                                      │
│  - Skill and version used                                                    │
│  - Modules resolved                                                          │
│  - ADR compliance                                                            │
│  - File → Template mapping                                                   │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 7: RUN VALIDATIONS                                                     │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Execute Tier 1, 2, 3 validators                                     │
│  Input:  Generated project                                                   │
│  Output: Validation report                                                   │
│                                                                              │
│  Validation sequence:                                                        │
│  1. Tier 1 (Universal): traceability, manifest presence                     │
│  2. Tier 2 (Technology): java-maven compilation, spring-boot config         │
│  3. Tier 3 (Module): Each module's specific validators                      │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 8: OUTPUT                                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Return generated project                                            │
│  Output: Project folder + validation report + execution audit               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Module Resolution Table

| Feature Path | Condition | Module |
|--------------|-----------|--------|
| (always) | - | mod-code-015-hexagonal-base-java-spring |
| `features.resilience.circuit_breaker.enabled` | `true` | mod-code-001-circuit-breaker-java-resilience4j |
| `features.resilience.retry.enabled` | `true` | mod-code-002-retry-java-resilience4j |
| `features.resilience.timeout.enabled` | `true` AND `strategy=timelimiter` | mod-code-003-timeout-java-resilience4j |
| `features.resilience.rate_limiter.enabled` | `true` | mod-code-004-rate-limiter-java-resilience4j |
| `features.persistence.type` | `jpa` | mod-code-016-persistence-jpa-spring |
| `features.persistence.type` | `system_api` | mod-code-017-persistence-systemapi |
| `features.integration.rest_clients` | not empty | mod-code-018-api-integration-rest-java-spring |

---

## Output Structure

```
{serviceName}/
├── .enablement/
│   └── manifest.json           # Traceability
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── {package}/
│   │   │       ├── Application.java
│   │   │       ├── application/     # Application layer
│   │   │       ├── domain/          # Domain layer
│   │   │       ├── infrastructure/  # Infrastructure layer
│   │   │       └── config/          # Configuration
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── pom.xml
├── Dockerfile
└── README.md
```

---

## Validation Requirements

### Tier 1 (Universal)
- `manifest.json` exists and is valid
- All required traceability fields present

### Tier 2 (Java/Maven)
- `mvn compile` succeeds
- `mvn test` succeeds (if tests generated)
- Spring Boot configuration valid

### Tier 3 (Per Module)
- Each module's validators pass
- Example: Circuit breaker annotations have fallback methods

---

## Error Handling

| Error | Handling |
|-------|----------|
| Invalid input schema | Return validation errors, stop |
| Module not found | Return error, list available modules |
| Template processing error | Return error with template and line |
| Merge conflict | Return error with conflicting keys |
| Validation failure | Return report, mark as failed |

---

## Example Skills

- `skill-code-020-generate-microservice-java-spring`
- `skill-code-021-generate-rest-api-java-spring` (future)
- `skill-code-022-generate-event-consumer-java-kafka` (future)
