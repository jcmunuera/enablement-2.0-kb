# Skill Type: CODE/ADD

**Version:** 1.0  
**Last Updated:** 2025-12-12  
**Domain:** CODE

---

## Purpose

ADD skills add specific features to existing code. They modify an existing codebase to include new capabilities without rebuilding from scratch.

---

## Characteristics

| Aspect | Description |
|--------|-------------|
| Input | Existing code + Feature specification |
| Output | Modified code (targeted changes) |
| Modules | Typically one (the feature module) |
| Complexity | Medium - targeted modifications |

---

## Input Schema

```yaml
# transformation-request.yaml
projectPath: "./customer-service"

feature:
  type: "circuit_breaker"  # The feature to add
  config:
    pattern: "basic_fallback"
    failureRateThreshold: 50
    waitDurationInOpenState: "30s"

targets:
  - className: "InventoryClient"
    methods:
      - name: "getStock"
        fallbackValue: "Stock.empty()"
```

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CODE/ADD EXECUTION FLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  STEP 1: VALIDATE INPUT                                                      │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Validate transformation-request against schema                      │
│  Input:  transformation-request.yaml                                         │
│  Output: Validated request or ERROR                                          │
│                                                                              │
│  Rules:                                                                      │
│  - projectPath: required, must exist                                         │
│  - feature.type: required, must match available module                       │
│  - targets: at least one target                                              │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 2: ANALYZE EXISTING CODE                                               │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Parse and understand the existing project                           │
│  Input:  Project at projectPath                                              │
│  Output: Code analysis context                                               │
│                                                                              │
│  Analysis includes:                                                          │
│  - Project structure (Maven/Gradle, package layout)                         │
│  - Existing dependencies (pom.xml/build.gradle)                             │
│  - Target classes and methods                                                │
│  - Existing configurations (application.yml)                                 │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 3: RESOLVE MODULE                                                      │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Determine which module provides the feature                         │
│  Input:  feature.type                                                        │
│  Output: Single module                                                       │
│                                                                              │
│  Resolution:                                                                 │
│  - circuit_breaker → mod-code-001-circuit-breaker-java-resilience4j         │
│  - retry → mod-code-002-retry-java-resilience4j                             │
│  - timeout → mod-code-003-timeout-java-resilience4j                         │
│  - rate_limiter → mod-code-004-rate-limiter-java-resilience4j               │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 4: LOCATE TARGET FILES                                                 │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Find the files to modify                                            │
│  Input:  targets + code analysis                                             │
│  Output: List of files with modification points                              │
│                                                                              │
│  For each target:                                                            │
│  - Locate class file by name                                                 │
│  - Verify methods exist                                                      │
│  - Identify insertion points                                                 │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 5: BUILD VARIABLE CONTEXT                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Extract variables from existing code + request                      │
│  Input:  Code analysis + Request config                                      │
│  Output: Variable context for templates                                      │
│                                                                              │
│  Variables from analysis:                                                    │
│  - package: from existing class                                              │
│  - className, methodName: from targets                                       │
│  - existingAnnotations: to avoid duplicates                                  │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 6: GENERATE MODIFICATIONS                                              │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Prepare code changes using module templates                         │
│  Input:  Module templates + Variable context                                 │
│  Output: Modification set (what to add/change)                               │
│                                                                              │
│  Modifications may include:                                                  │
│  - Add annotations to methods                                                │
│  - Add fallback methods                                                      │
│  - Add imports                                                               │
│  - Add configuration entries                                                 │
│  - Add dependencies to pom.xml                                               │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 7: APPLY MODIFICATIONS                                                 │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Apply changes to existing files                                     │
│  Input:  Modification set + Target files                                     │
│  Output: Modified files                                                      │
│                                                                              │
│  For each modification:                                                      │
│  1. Read original file                                                       │
│  2. Apply transformation (AST-based or text-based)                          │
│  3. Write modified file                                                      │
│  4. Record change in audit                                                   │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 8: UPDATE MANIFEST                                                     │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Update or create traceability manifest                              │
│  Input:  Modifications applied                                               │
│  Output: Updated .enablement/manifest.json                                   │
│                                                                              │
│  Add to manifest:                                                            │
│  - Transformation timestamp                                                  │
│  - Feature added                                                             │
│  - Module used                                                               │
│  - Files modified                                                            │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 9: RUN VALIDATIONS                                                     │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Validate modified code                                              │
│  Input:  Modified project                                                    │
│  Output: Validation report                                                   │
│                                                                              │
│  Validation sequence:                                                        │
│  1. Tier 1: Traceability present                                            │
│  2. Tier 2: Compilation succeeds, tests pass                                │
│  3. Tier 3: Module-specific validators                                      │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                    │                                         │
│                                    ▼                                         │
│  STEP 10: OUTPUT                                                             │
│  ───────────────────────────────────────────────────────────────────────────│
│  Action: Return modification summary                                         │
│  Output: Modified files list + validation report + diff                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Difference from GENERATE

| Aspect | GENERATE | ADD |
|--------|----------|-----|
| Starting point | Nothing | Existing project |
| Module count | Multiple (N) | Typically one |
| Output | New project | Modified files |
| Scope | Full project structure | Targeted changes |
| Complexity | High | Medium |

---

## Module Resolution Table

| feature.type | Module |
|--------------|--------|
| `circuit_breaker` | mod-code-001-circuit-breaker-java-resilience4j |
| `retry` | mod-code-002-retry-java-resilience4j |
| `timeout` | mod-code-003-timeout-java-resilience4j |
| `rate_limiter` | mod-code-004-rate-limiter-java-resilience4j |
| `jpa_repository` | mod-code-016-persistence-jpa-spring |
| `rest_client` | mod-code-018-api-integration-rest-java-spring |

---

## Modification Types

| Type | Description | Example |
|------|-------------|---------|
| `add_annotation` | Add annotation to method/class | `@CircuitBreaker` |
| `add_method` | Add new method to class | Fallback method |
| `add_import` | Add import statement | `import io.resilience4j...` |
| `add_config` | Add configuration entry | YAML section |
| `add_dependency` | Add Maven/Gradle dependency | pom.xml entry |
| `modify_method` | Change existing method | Wrap with try-catch |

---

## Output Structure

```
{projectPath}/
├── .enablement/
│   └── manifest.json           # Updated with transformation
├── src/
│   └── main/
│       ├── java/
│       │   └── {package}/
│       │       └── {modified classes}
│       └── resources/
│           └── application.yml  # Updated configuration
└── pom.xml                      # Updated dependencies
```

---

## Validation Requirements

### Pre-modification
- Project compiles before changes
- Target classes exist
- Target methods exist

### Post-modification
- Project still compiles
- All tests pass
- Module-specific validations pass

---

## Error Handling

| Error | Handling |
|-------|----------|
| Project not found | Return error with path |
| Target class not found | Return error, suggest similar |
| Target method not found | Return error, list available |
| Compilation failure after modification | Rollback changes, return error |
| Feature already present | Warn, skip or update based on config |

---

## Example Skills

- `skill-code-001-add-circuit-breaker-java-resilience4j`
- `skill-code-002-add-retry-java-resilience4j` (future)
- `skill-code-003-add-timeout-java-resilience4j` (future)
- `skill-code-004-add-rate-limiter-java-resilience4j` (future)
