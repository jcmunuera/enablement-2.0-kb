# skill-021-api-rest-java-spring

## Overview

**Skill ID:** skill-021-api-rest-java-spring  
**Extends:** skill-020-microservice-java-spring  
**Type:** GENERATE  
**Framework:** Java 17+ / Spring Boot 3.2.x  
**Architecture:** Hexagonal Light + API Standards (ADR-001)

---

## Purpose

**Extends skill-020** to generate REST APIs following the 4-layer API model (Experience, Composable, Domain, System) defined in ADR-001.

This skill **inherits all capabilities** from skill-020 (hexagonal structure, resilience, persistence, future observability/caching) and **adds only the delta** for REST API patterns:
- Pagination (PageResponse, filtering, sorting)
- HATEOAS (hypermedia links)
- Compensation (SAGA participation for Domain APIs)

**Relationship to skill-020:**
- skill-020: Base microservice (DDD, hexagonal, cross-cutting concerns)
- skill-021: skill-020 + REST API patterns (pagination, HATEOAS, compensation)

---

## When to Use

✅ **Use this skill when:**
- Creating an API that follows the 4-layer model (Experience, Composable, Domain, System)
- Need OpenAPI contract with pagination and filtering
- Building a Domain API that participates in SAGA orchestration
- Want HATEOAS links for discoverability
- Need standardized error responses (RFC 7807)

❌ **Do NOT use when:**
- Building internal DDD microservices (use skill-020)
- Creating gRPC services (use skill-022 when available)
- Building async/event-driven services (use skill-023 when available)
- Simple internal CRUD without public contract

---

## Capabilities

| Capability | Description |
|------------|-------------|
| **4-Layer API Model** | Experience, Composable, Domain, System APIs |
| **Pagination** | Standard PageResponse with page metadata per ADR-001 |
| **HATEOAS** | Hypermedia links for resource discoverability |
| **Filtering & Sorting** | Query parameter support with standard conventions |
| **Compensation** | /compensate endpoint for Domain APIs in SAGA |
| **OpenAPI 3.0** | Complete API documentation |
| **Error Handling** | RFC 7807 Problem Details |

---

## API Layer Features

| Layer | Pagination | HATEOAS | Compensation | OpenAPI |
|-------|------------|---------|--------------|---------|
| **Experience** | ✅ | ✅ | ❌ | ✅ |
| **Composable** | ✅ | ⚠️ Optional | ❌ | ✅ |
| **Domain** | ✅ | ✅ | ✅ | ✅ |
| **System** | ✅ | ❌ | ❌ | ✅ |

---

## Input Summary

```json
{
  "serviceName": "customer-management-api",
  "basePackage": "com.bank.customer",
  "apiLayer": "domain",
  "entities": [
    {
      "name": "Customer",
      "fields": [
        { "name": "firstName", "type": "String" },
        { "name": "lastName", "type": "String" },
        { "name": "email", "type": "String" }
      ]
    }
  ],
  "features": {
    "resilience": { "enabled": true },
    "persistence": { "type": "system_api" }
  }
}
```

---

## Output Summary

```
customer-management-api/
├── pom.xml
├── src/main/java/.../
│   ├── domain/
│   │   ├── model/
│   │   ├── repository/
│   │   └── transaction/        # Compensation (Domain layer only)
│   │       ├── Compensable.java
│   │       ├── CompensationRequest.java
│   │       └── CompensationResult.java
│   ├── application/
│   │   └── service/
│   ├── adapter/
│   │   └── in/rest/
│   │       ├── CustomerController.java
│   │       ├── dto/
│   │       │   ├── PageResponse.java
│   │       │   └── CustomerFilter.java
│   │       └── assembler/
│   │           └── CustomerModelAssembler.java
│   └── infrastructure/
│       └── web/
│           └── PageableConfig.java
├── src/main/resources/
│   ├── application.yml
│   └── openapi.yaml
└── .enablement/
    └── manifest.json
```

---

## Dependencies

### Inherited from skill-020
> All base dependencies from skill-020 are inherited (mod-015, mod-001-004, mod-016/017, etc.)

### Additional Dependencies (Delta)
- **ADR-001:** API Design - Model, Types & Standards
- **ADR-013:** Distributed Transactions (for Domain layer)
- **ERI-014:** API Public Exposure Java Spring
- **ERI-015:** Distributed Transactions Java Spring
- **mod-019:** api-public-exposure-java-spring (always)
- **mod-020:** compensation-java-spring (Domain layer only)

---

## Related Skills

| Skill | Relationship |
|-------|--------------|
| skill-020-microservice-java-spring | **Parent** - base microservice (inherited) |
| skill-022-api-grpc-java-spring | **Sibling** - extends skill-020 for gRPC (planned) |
| skill-023-api-async-java-spring | **Sibling** - extends skill-020 for Async (planned) |

---

## Tags

`generation` `api` `rest` `spring-boot` `java` `hexagonal` `pagination` `hateoas` `compensation` `domain-api`

---

## Version

**Current:** 2.0.0  
**Status:** Active  
**Last Updated:** 2025-12-19
