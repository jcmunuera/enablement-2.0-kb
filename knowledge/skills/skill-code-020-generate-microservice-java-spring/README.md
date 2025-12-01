# skill-code-020-generate-microservice-java-spring

> Generate complete Spring Boot microservices with Hexagonal Light architecture

**Domain:** CODE | **Type:** CREATION | **Version:** 1.2.0

## Quick Start

### 1. Create config file

#### Example: Domain API with JPA

```json
{
  "serviceName": "customer-service",
  "groupId": "com.company",
  "basePackage": "com.company.customer",
  "javaVersion": "17",
  "springBootVersion": "3.2.0",
  
  "apiType": "domain_api",
  
  "entities": [
    {
      "name": "Customer",
      "fields": [
        { "name": "name", "type": "String", "required": true },
        { "name": "email", "type": "String", "required": true, "format": "email" },
        { "name": "age", "type": "int", "required": true, "min": 18 }
      ]
    }
  ],
  
  "features": {
    "resilience": {
      "circuit_breaker": { "enabled": true }
    },
    "persistence": { 
      "enabled": true, 
      "type": "jpa",
      "database": "postgresql" 
    }
  }
}
```

#### Example: Domain API with System API (Mainframe)

```json
{
  "serviceName": "account-service",
  "groupId": "com.company",
  "basePackage": "com.company.account",
  "apiType": "domain_api",
  
  "entities": [
    {
      "name": "Account",
      "fields": [
        { "name": "accountNumber", "type": "String", "required": true },
        { "name": "balance", "type": "BigDecimal", "required": true }
      ]
    }
  ],
  
  "features": {
    "resilience": {
      "circuit_breaker": { "enabled": true },
      "retry": { "enabled": true },
      "timeout": { "enabled": true, "duration": "5s" }
    },
    "persistence": { 
      "enabled": true, 
      "type": "system_api",
      "system_api": { "client": "feign" }
    }
  }
}
```

### 2. Run skill

```bash
# Using Fusion CLI (future)
fusion generate --skill skill-code-020 --config customer-config.json

# Or via MCP
# Send config to skill-code-020 endpoint
```

### 3. Output

```
customer-service/
├── pom.xml
├── src/main/java/com/company/customer/
│   ├── domain/           # Pure POJOs - business logic
│   ├── application/      # Spring @Service orchestration
│   ├── adapter/          # REST + persistence (JPA or System API)
│   └── infrastructure/   # Config + exception handling
├── src/test/java/...
└── src/main/resources/
    ├── application.yml
    └── openapi.yaml      # Generated API spec
```

## API Types

| Type | Use Case | Key Characteristics |
|------|----------|---------------------|
| `domain_api` | Business domain services | Owns data, no cross-domain calls |
| `composable_api` | Orchestration | Calls multiple Domain APIs, stateless |
| `system_api` | SoR integration | Abstracts backend systems |
| `experience_api` | BFF for UI | Channel-specific, calls Composable/Domain |

## Features

### Resilience

| Feature | Config | What it adds |
|---------|--------|--------------|
| Circuit Breaker | `resilience.circuit_breaker.enabled: true` | Resilience4j + fallbacks |
| Retry | `resilience.retry.enabled: true` | Exponential backoff |
| Timeout | `resilience.timeout.enabled: true` | TimeLimiter |
| Rate Limiter | `resilience.rate_limiter.enabled: true` | Request throttling |

### Persistence

| Type | Config | What it adds |
|------|--------|--------------|
| JPA | `persistence.type: "jpa"` | JPA entities + Spring Data |
| System API | `persistence.type: "system_api"` | REST client + resilience |

**System API client options:** `feign` (recommended), `resttemplate`, `restclient`

### Other Features

| Feature | Config | What it adds |
|---------|--------|--------------|
| Health Checks | `health_checks.enabled: true` | Actuator endpoints |
| Logging | `structured_logging.enabled: true` | JSON logging |
| Docker | `docker.enabled: true` | Dockerfile |

## Documentation

- [SKILL.md](./SKILL.md) - Full specification
- [examples/](./examples/) - Example configs and outputs

## Dependencies

- **ADRs:** adr-009, adr-001, adr-004, adr-011
- **ERIs:** eri-code-001, eri-code-008 to eri-code-012
- **Modules:** mod-015, mod-001 to mod-004, mod-016, mod-017
