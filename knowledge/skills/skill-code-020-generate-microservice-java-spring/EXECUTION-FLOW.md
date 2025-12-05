# Execution Flow: skill-code-020-generate-microservice-java-spring

**Skill Type:** GENERATE  
**Version:** 1.2  
**Last Updated:** 2025-12-05

---

## Overview

This document defines the **deterministic execution flow** for generating a microservice.
This skill is **generic** - it can generate any type of microservice:

| Service Type | Description | Example |
|--------------|-------------|---------|
| `experience_api` | Frontend-facing, aggregates backends (BFF) | Mobile BFF |
| `composable_api` | Orchestrates domain APIs | Order orchestrator |
| `domain_api` | Business capability exposure | Customer API |
| `system_api` | Backend/legacy wrapper | Parties API |
| `internal_service` | Domain support service, not exposed as API | Notification service |

Any AI agent or orchestrator MUST follow these steps exactly to ensure reproducible results.

---

## Prerequisites

Before execution, the following inputs MUST be available:

| Input | Source | Required | Description |
|-------|--------|----------|-------------|
| `generation-request.json` | Discovery phase or user | ✅ Always | Service configuration, entities, features |
| `service-api-spec.yaml` | User provided | Conditional | OpenAPI spec of the service being generated (if it exposes an API) |
| `integrations/*.yaml` | User provided | Conditional | OpenAPI specs for each REST API integration |
| `mappings/*.json` | User provided or generated | Conditional | Field mappings between domain model and integrations |

---

## Integrations Model

The microservice may need to integrate with **0 to N external components**. 

### Supported Integration Types

Per **ADR-012 (API Integration Patterns)**, the following integration types are defined:

| Type | Protocol | Status | ERI | Module |
|------|----------|--------|-----|--------|
| `api-rest` | REST/HTTP | ✅ **Supported** | ERI-013 | mod-018 |
| `api-grpc` | gRPC/HTTP2 | 🔮 Planned | - | - |
| `async-request-reply` | AMQP/Kafka | 🔮 Planned | - | - |
| `event-choreography` | Kafka/Events | 🔮 Planned | - | - |
| `event-orchestration` | SAGA | 🔮 Planned | - | - |

> **Current Scope:** This version of the skill only supports `api-rest` integrations.
> Future integration types will require corresponding ERIs and Modules per ADR-012.

### Integration Definition (api-rest)

Each REST API integration is defined by:

```yaml
integrations:
  - id: "parties-api"                         # Unique identifier
    type: "api-rest"                          # Only supported type currently
    spec_file: "integrations/parties-api.yaml"  # OpenAPI 3.x spec
    mapping_file: "mappings/parties-mapping.json"  # Optional field mapping
    
  - id: "accounts-api"
    type: "api-rest"
    spec_file: "integrations/accounts-api.yaml"
```

**Note:** The integrated APIs can be of ANY classification (Domain, Composable, System, Experience) - 
the skill only cares about their interface contract (OpenAPI spec), not their architectural role.

### References

- **ADR-012:** API Integration Patterns (defines taxonomy)
- **ERI-013:** api-integration-rest-java-spring (reference implementation)
- **mod-018:** api-integration-rest-java-spring (templates)

---

## Execution Steps

### Step 1: Validate Input

```
ACTION: Validate generation-request.json against schema
INPUT:  generation-request.json
OUTPUT: Validated input or ERROR

RULES:
1. Load generation-request.json
2. Validate required fields:
   - service.name (string, kebab-case)
   - service.group_id (string, dot notation)
   - service.base_package (string, dot notation)
   - service.type (enum: experience_api|composable_api|domain_api|system_api|internal_service)
   - entities[] (at least one)
   
3. Validate persistence configuration:
   - persistence.type (enum: jpa|integration|memory|none)
   - If "integration" → integrations[] must have at least one entry
   
4. Validate each integration in integrations[]:
   - id (string, unique)
   - type (enum: api-rest)  ← Only supported type currently
   - spec_file (string, file must exist, must be valid OpenAPI 3.x)
   - If type is not "api-rest" → ERROR: "Integration type not supported. See ADR-012 for roadmap."
   
5. If validation fails → STOP with error
6. Log: "Input validated successfully"
```

### Step 2: Resolve Modules

```
ACTION: Determine which modules are required based on features
INPUT:  generation-request.json
OUTPUT: modules_required[]

RULES:
1. ALWAYS include: mod-015-hexagonal-base-java-spring

2. Check persistence.type:
   - If "jpa" → ADD mod-016-persistence-jpa-spring
   - If "integration" → Check each integration type (see 2.1)
   - If "memory" → No additional module (in-memory implementation)
   - If "none" → No persistence layer generated

2.1. For each integration in integrations[]:
     - If type="api-rest" → ADD mod-018-api-integration-rest-java-spring
     - If type is other → ERROR: "Module not available for integration type. See ADR-012."
     - Note: mod-018 is added ONCE even if multiple api-rest integrations

3. Check features.resilience:
   - If circuit_breaker.enabled=true → ADD mod-001-circuit-breaker-java-resilience4j
   - If retry.enabled=true → ADD mod-002-retry-java-resilience4j
   - If timeout.enabled=true AND timeout.strategy="timelimiter" → ADD mod-003-timeout-java-resilience4j
   - If rate_limiter.enabled=true → ADD mod-004-rate-limiter-java-resilience4j

4. Log: "Modules resolved: [list]"
```

### Step 3: Build Variable Context

```
ACTION: Extract all template variables from input
INPUT:  generation-request.json, integration specs
OUTPUT: variable_context{}

RULES:
1. Service-level variables:
   - serviceName = service.name (as-is, kebab-case)
   - serviceNamePascal = PascalCase(service.name)
   - serviceNameCamel = camelCase(service.name)
   - serviceType = service.type
   - groupId = service.group_id
   - artifactId = service.artifact_id OR service.name
   - basePackage = service.base_package
   - basePackagePath = replace(basePackage, ".", "/")
   - javaVersion = technology.java_version OR "17"
   - springBootVersion = technology.spring_boot_version OR "3.2.0"

2. For each entity in entities[]:
   - Entity = entity.name (PascalCase)
   - entityLower = camelCase(entity.name)
   - entityPlural = pluralize(entity.name, lowercase)
   - entityFields = entity.fields[]
   
3. For each integration in integrations[]:
   - integrationId = integration.id
   - integrationIdPascal = PascalCase(integration.id)
   - integrationIdCamel = camelCase(integration.id)
   - integrationType = integration.type
   - integrationSpec = parsed content of spec_file (OpenAPI)
   - integrationMapping = parsed content of mapping_file (if exists)
   
4. Log: "Variable context built with [count] variables"
```

### Step 4: Process Each Module

```
ACTION: For each resolved module, process its Template Catalog
INPUT:  modules_required[], variable_context{}
OUTPUT: generated_files[]

FOR EACH module IN modules_required:
    
    4.1. Load Template Catalog
         - Read: {module}/MODULE.md
         - Parse: "## Template Catalog" section
         - Extract: list of (template, output_path, condition)
    
    4.2. For Each Template in Catalog
         
         4.2.1. Check Condition
                - If template has condition (e.g., "persistence.type=integration")
                - Evaluate condition against generation-request.json
                - If FALSE → SKIP this template
         
         4.2.2. Handle Cardinality
                - If template is per-entity → Loop over entities[]
                - If template is per-integration → Loop over integrations[]
                - If template is singleton → Process once
         
         4.2.3. Read Template File
                - Path: {module}/templates/{template}
                - If file not found → LOG ERROR, mark as GAP
         
         4.2.4. Render Template
                - Substitute all {{variable}} with values from variable_context
                - Handle loops: {{#entities}}...{{/entities}}, {{#integrations}}...{{/integrations}}
                - Handle conditionals: {{#if condition}}...{{/if}}
         
         4.2.5. Add Traceability Header
                ```
                // =============================================================================
                // GENERATED CODE - DO NOT EDIT
                // Template: {template_name}
                // Module: {module_id}
                // Generated by: skill-code-020-generate-microservice-java-spring
                // Timestamp: {ISO-8601}
                // =============================================================================
                ```
         
         4.2.6. Write Output File
                - Path: Render output_path with variables
                - Create directories if needed
                - Write content
         
         4.2.7. Record in Manifest
                - Add entry: {output, template, module, variables_used, cardinality_source}
    
    4.3. Log: "Module {module} processed: [count] files generated"
```

### Step 5: Merge Configuration Files

```
ACTION: Combine configuration snippets into final files
INPUT:  All generated config files
OUTPUT: Merged application.yml, merged pom.xml

RULES for application.yml:
1. Start with base: mod-015/config/application.yml.tpl output
2. Merge persistence config (if applicable):
   - mod-016 JPA config (under spring.datasource, spring.jpa)
3. Merge integration configs (for each api-rest integration):
   - mod-018 REST client config (per integration)
4. Merge resilience configs (in order):
   - mod-001 circuit breaker config (under resilience4j.circuitbreaker)
   - mod-002 retry config (under resilience4j.retry)
   - mod-003 timeout config (under resilience4j.timelimiter)
5. YAML merge strategy: deep merge, later values override

RULES for pom.xml:
1. Start with base: mod-015/config/pom.xml.tpl output
2. Collect all <dependency> blocks from module configs
3. Deduplicate by groupId+artifactId
4. Sort alphabetically by groupId, then artifactId
5. Insert into <dependencies> section

Log: "Configuration files merged"
```

### Step 6: Generate Manifest

```
ACTION: Create traceability manifest
INPUT:  All execution data
OUTPUT: manifest.json

SCHEMA:
{
  "generatedAt": "{ISO-8601 timestamp}",
  "skill": "skill-code-020-generate-microservice-java-spring",
  "skillVersion": "1.2.0",
  "input": {
    "generationRequestHash": "{SHA-256 of generation-request.json}",
    "serviceName": "{service.name}",
    "serviceType": "{service.type}"
  },
  "integrations": [
    {
      "id": "parties-api",
      "type": "api-rest",
      "specHash": "{SHA-256 of spec file}"
    }
  ],
  "modulesUsed": [
    {
      "module": "mod-015-hexagonal-base-java-spring",
      "version": "1.1",
      "reason": "always required (base hexagonal)"
    },
    {
      "module": "mod-018-api-integration-rest-java-spring",
      "version": "1.0",
      "reason": "integration type=api-rest"
    }
  ],
  "filesGenerated": [
    {
      "output": "src/main/java/.../Customer.java",
      "template": "domain/Entity.java.tpl",
      "module": "mod-015-hexagonal-base-java-spring",
      "cardinalitySource": "entity:Customer",
      "checksum": "{SHA-256}"
    }
  ],
  "improvisations": [],
  "warnings": []
}

WRITE: manifest.json to project root
Log: "Manifest generated with [count] files"
```

### Step 7: Run Validations

```
ACTION: Execute all applicable validators
INPUT:  Generated project
OUTPUT: validation-report.json

7.1. Tier-1 Validation (Universal)
     - Run: validators/tier-1/project-structure-check.sh
     - Run: validators/tier-1/traceability-check.sh
     - Record results

7.2. Tier-2 Validation (Technology)
     - Run: validators/tier-2/java-spring/java-compile-check.sh
     - Run: validators/tier-2/java-spring/spring-boot-check.sh
     - Record results

7.3. Tier-3 Validation (Module-specific)
     FOR EACH module IN modules_used:
         - Run: {module}/validation/*.sh
         - Record results

7.4. Generate Report
     {
       "timestamp": "{ISO-8601}",
       "overall": "PASS|FAIL",
       "tier1": { "status": "PASS", "checks": [...] },
       "tier2": { "status": "PASS", "checks": [...] },
       "tier3": {
         "mod-015": { "status": "PASS", "script": "hexagonal-check.sh" },
         "mod-018": { "status": "PASS", "script": "rest-integration-check.sh" }
       }
     }

WRITE: validation-report.json
Log: "Validation complete: {overall_status}"
```

### Step 8: Generate Execution Audit

```
ACTION: Create complete audit trail
INPUT:  All execution data and decisions
OUTPUT: execution-audit.json

SCHEMA:
{
  "executionId": "{UUID}",
  "timestamp": "{ISO-8601}",
  "skill": "skill-code-020-generate-microservice-java-spring",
  "input": {
    "generationRequest": { /* full content */ },
    "serviceApiSpec": "service-api-spec.yaml (if provided)",
    "integrations": [
      { "id": "parties-api", "type": "api-rest", "specFile": "integrations/parties-api.yaml" }
    ],
    "mappings": ["mappings/parties-mapping.json"]
  },
  "decisions": {
    "modulesResolved": [
      { "module": "mod-015", "reason": "always required" },
      { "module": "mod-018", "reason": "integration type=api-rest" }
    ],
    "templatesProcessed": [...],
    "templatesSkipped": [...]
  },
  "improvisations": [],
  "validation": { /* from validation-report.json */ },
  "outputs": {
    "projectPath": "./customer-service",
    "filesCount": 28,
    "manifestPath": "./customer-service/manifest.json"
  }
}

WRITE: execution-audit.json
Log: "Execution audit generated"
```

---

## Error Handling

| Error | Action |
|-------|--------|
| Input validation fails | STOP, return error with details |
| Integration type not supported | STOP, return error with reference to ADR-012 |
| Integration spec not found | STOP, return error (spec is required) |
| Template file not found | LOG as GAP, continue if non-critical |
| Template render fails | LOG error, mark file as FAILED in manifest |
| Validation fails (Tier-1/2) | STOP, return validation report |
| Validation fails (Tier-3) | WARN, continue, include in report |

---

## Determinism Guarantees

1. **Same input → Same modules:** Module Resolution rules are deterministic
2. **Same modules → Same templates:** Template Catalog is explicit
3. **Same templates → Same output:** Variable substitution is deterministic
4. **Ordering is defined:** Alphabetical processing by module, entity, integration
5. **No external dependencies:** No network calls, no randomness
6. **Full traceability:** Every decision recorded in audit

---

## Outputs Summary

| Output | Path | Purpose |
|--------|------|---------|
| Generated code | `{serviceName}/src/**` | The microservice code |
| `manifest.json` | `{serviceName}/manifest.json` | File-level traceability |
| `validation-report.json` | `{serviceName}/validation-report.json` | Validation results |
| `execution-audit.json` | `./execution-audit.json` | Complete execution trace |

---

## Knowledge Base References

| Asset | ID | Purpose |
|-------|-----|---------|
| ADR | ADR-012 | API Integration Patterns (taxonomy) |
| ERI | ERI-013 | api-integration-rest-java-spring |
| Module | mod-015 | Hexagonal base |
| Module | mod-016 | Persistence JPA |
| Module | mod-018 | API Integration REST |
| Module | mod-001..004 | Resilience patterns |

---

## Gaps and Future Work

| Gap ID | Description | Blocking? | ADR Reference |
|--------|-------------|-----------|---------------|
| GAP-INT-001 | gRPC integration not supported | No | ADR-012 |
| GAP-INT-002 | Async Request/Reply not supported | No | ADR-012 |
| GAP-INT-003 | Event Choreography not supported | No | ADR-012 |
| GAP-INT-004 | Event Orchestration (SAGA) not supported | No | ADR-012 |

When these integration types are needed:
1. Create corresponding ERI (following ERI-013 as reference)
2. Create corresponding Module (following mod-018 as reference)
3. Update ADR-012 status table
4. Update this EXECUTION-FLOW to support new type

---

## Appendix: Example generation-request.json

```json
{
  "service": {
    "name": "customer-service",
    "type": "domain_api",
    "description": "Customer management domain API",
    "group_id": "com.bank.customer",
    "artifact_id": "customer-service",
    "base_package": "com.bank.customer"
  },
  "entities": [
    {
      "name": "Customer",
      "fields": [
        { "name": "id", "type": "UUID", "required": true },
        { "name": "firstName", "type": "String", "required": true },
        { "name": "lastName", "type": "String", "required": true },
        { "name": "email", "type": "String", "required": true },
        { "name": "status", "type": "CustomerStatus", "required": true }
      ]
    }
  ],
  "persistence": {
    "type": "integration"
  },
  "integrations": [
    {
      "id": "parties-api",
      "type": "api-rest",
      "description": "Party management System API",
      "spec_file": "integrations/parties-api.yaml",
      "mapping_file": "mappings/customer-party-mapping.json"
    }
  ],
  "features": {
    "resilience": {
      "circuit_breaker": { "enabled": true },
      "retry": { "enabled": true },
      "timeout": { "enabled": true, "strategy": "client_level" }
    }
  },
  "technology": {
    "java_version": "17",
    "spring_boot_version": "3.2.0"
  }
}
```
