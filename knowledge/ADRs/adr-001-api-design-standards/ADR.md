---
id: adr-001-api-design-standards
title: "ADR-001: API Design Standards"
sidebar_label: API Design Standards
version: 2.0
date: 2025-05-27
updated: 2025-11-24
status: Accepted
author: Architecture Team
framework: agnostic
api_layers:
  - experience-api
  - composable-api
  - domain-api
  - system-api
tags:
  - api
  - architecture
  - microservices
  - api-led-connectivity
  - transaction
  - saga
  - orchestration
related:
  - adr-009-service-architecture-patterns
  - eri-code-001-hexagonal-light-java-spring
  - eri-002-domain-api-java-spring
  - eri-003-composable-api-java-spring
  - eri-004-experience-api-java-spring
---

# ADR-001: API Design Standards

**Status:** Accepted  
**Date:** 2025-05-27  
**Updated:** 2025-11-24 (v2.0 - Framework-agnostic)  
**Deciders:** Architecture Team

---

## Context

In our microservices-based application architecture, we need a consistent approach to API design that enables:

- Reliable orchestration of complex business workflows spanning multiple domains
- Clear separation of concerns between orchestration, business logic, and integrations
- Reusability and consistency across a multinational, distributed organization
- Flexible, resilient, and maintainable transaction management

**Problems we face:**
- Inconsistent API structures across teams
- Unclear boundaries between API responsibilities
- Difficulty coordinating multi-domain transactions
- Tight coupling between UI requirements and business logic
- Complex integration management with Systems of Record (SoR)

**Business impact:**
- Slower time-to-market for new features
- Higher maintenance costs
- Difficulty scaling across locations
- Increased risk of cascade failures

---

## Decision

We adopt a **4-layer API architecture** (API-led Connectivity) with clear responsibilities per layer.

### API Layer Model

```
┌─────────────────────────────────────────────────────────────────┐
│                     EXPERIENCE / BFF LAYER                       │
│  Purpose: Channel-specific data transformation and optimization  │
│  Consumers: UI applications (Web, Mobile, etc.)                  │
│  Calls: Composable APIs                                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                       COMPOSABLE API LAYER                       │
│  Purpose: Orchestration of multi-domain workflows                │
│  Responsibility: Transaction management (SAGA pattern)           │
│  Calls: Multiple Domain APIs                                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN API LAYER                          │
│  Purpose: Atomic business capabilities per domain                │
│  Responsibility: Business logic, data ownership                  │
│  Calls: System APIs (within same domain only)                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        SYSTEM API LAYER                          │
│  Purpose: Abstraction of Systems of Record (SoR)                 │
│  Responsibility: Integration contracts, data transformation      │
│  Calls: External systems, databases, third-party APIs            │
└─────────────────────────────────────────────────────────────────┘
```

---

### Layer 1: Experience API (BFF)

**Purpose:** Interface between UI and backend, optimized for specific channels.

**Characteristics:**
- Channel-specific (Mobile BFF, Web BFF, etc.)
- Data aggregation and transformation for UI needs
- No business logic
- Caching for UI performance
- Authentication/session management

**Constraints:**
- ✅ CAN call Composable APIs
- ✅ CAN call Domain APIs directly (simple read operations)
- ❌ CANNOT call System APIs directly
- ❌ CANNOT implement business logic
- ❌ CANNOT own data

**Example use cases:**
- Mobile dashboard aggregating customer + orders + loyalty
- Web checkout flow calling order orchestration
- Admin portal with role-based data filtering

---

### Layer 2: Composable API

**Purpose:** Orchestration of multi-domain business workflows.

**Characteristics:**
- Coordinates calls to multiple Domain APIs
- Implements transaction management (SAGA pattern)
- Manages compensation logic for failures
- Stateless orchestration (state in Domain APIs)

**Constraints:**
- ✅ CAN call multiple Domain APIs
- ✅ CAN implement SAGA orchestration
- ✅ CAN manage cross-domain transactions
- ❌ CANNOT call System APIs directly
- ❌ CANNOT own data (delegates to Domain APIs)
- ❌ CANNOT bypass Domain APIs

**Transaction Management:**
- Use SAGA pattern (orchestration preferred over choreography)
- Each Domain API provides compensation endpoints
- Composable API coordinates rollback on failure

**Example use cases:**
- Order creation: validate customer → reserve inventory → process payment → create order
- Account opening: KYC check → create account → setup products → send notifications
- Loan application: credit check → risk assessment → approval → disbursement

---

### Layer 3: Domain API

**Purpose:** Atomic business capabilities for a specific business domain (bounded context).

#### Terminology: Domain API vs Domain Microservices

A **bounded context** (domain) may be implemented by multiple microservices:

```
┌─────────────────────────────────────────────────────────────────┐
│                    CUSTOMER DOMAIN (Bounded Context)             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────┐                       │
│   │       DOMAIN API                     │  ← Exposes domain    │
│   │   (customer-management-api)          │    capabilities      │
│   │                                      │    externally        │
│   │   - Aggregate root operations        │                      │
│   │   - External contract (OpenAPI)      │                      │
│   │   - Called by Composable APIs        │                      │
│   └──────────────┬──────────────────────┘                       │
│                  │ internal calls                                │
│                  ↓                                               │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │           DOMAIN MICROSERVICES (internal)                 │  │
│   │                                                           │  │
│   │   ┌─────────────────┐    ┌─────────────────┐             │  │
│   │   │ customer-events │    │ customer-search │             │  │
│   │   │   (async jobs)  │    │  (read model)   │             │  │
│   │   └─────────────────┘    └─────────────────┘             │  │
│   │                                                           │  │
│   │   - Support the Domain API                                │  │
│   │   - Internal to bounded context                           │  │
│   │   - Not exposed externally                                │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Domain API:**
- The **primary microservice** that exposes the domain's capabilities externally
- Typically implements the **aggregate root** operations
- Has a formal **OpenAPI contract**
- Is called by **Composable APIs** or **Experience APIs**

**Domain Microservices (internal):**
- Supporting microservices within the same bounded context
- Handle specific concerns (async processing, read models, etc.)
- Called **only** by the Domain API or other internal microservices
- **Not exposed** outside the bounded context

#### Characteristics

- Domain API owns its data (single source of truth for the domain)
- Implements domain business logic
- Provides CRUD + business operations
- Exposes compensation endpoints for SAGA

#### Constraints

**Domain API:**
- ✅ CAN call System APIs (within same domain)
- ✅ CAN call domain microservices (within same bounded context)
- ✅ CAN implement business rules
- ✅ CAN own and manage domain data
- ❌ CANNOT call Domain APIs from **other** domains (use Composable layer)
- ❌ CANNOT call Composable APIs
- ❌ CANNOT call Experience APIs

**Domain Microservices (internal):**
- ✅ CAN call other microservices in same bounded context
- ✅ CAN call System APIs (within same domain)
- ❌ CANNOT be called from outside the bounded context
- ❌ CANNOT call services in other domains

#### Communication Patterns (Future)

| Communication | Mechanism | Notes |
|---------------|-----------|-------|
| Cross-domain calls | API Gateway | Domain API → Gateway → Other Domain API |
| Intra-domain calls | Service Mesh / Direct | Domain API → Domain Microservices |
| Async communication | Message Broker | Events between domains or microservices |

*Note: Gateway vs Service Mesh implementation details to be defined in future ADR.*

#### Compensation Endpoints

- Standard convention: `POST /api/v1/{entity}/compensate`
- Idempotent operations
- Clear compensation semantics

#### Example Domains

| Domain | Domain API | Internal Microservices |
|--------|------------|------------------------|
| **Customer** | customer-management-api | customer-events, customer-search |
| **Order** | order-management-api | order-fulfillment, order-notifications |
| **Inventory** | inventory-management-api | inventory-sync, stock-alerts |
| **Payment** | payment-processing-api | payment-reconciliation |

---

### Layer 4: System API

**Purpose:** Abstraction layer for Systems of Record (SoR) and external integrations.

**Characteristics:**
- Standardizes access to backend systems
- Transforms data between SoR and domain models
- Handles integration complexity (protocols, formats)
- Provides consistent contracts regardless of SoR variations

**Constraints:**
- ✅ CAN call external systems, databases, third-party APIs
- ✅ CAN transform data formats
- ✅ CAN handle integration protocols
- ❌ CANNOT implement business logic
- ❌ CANNOT be called by Experience or Composable APIs directly

**Benefits:**
- Decouples business logic from integration details
- Standardizes contracts across locations (multinational)
- Simplifies SoR replacement or upgrade
- Centralizes error handling and security

**Example integrations:**
- Core banking system connector
- Payment gateway adapter
- CRM system interface
- Legacy mainframe wrapper

---

## Technical Standards

### API Contract Standards

| Aspect | Standard |
|--------|----------|
| **Specification** | OpenAPI 3.0+ |
| **Versioning** | URL path versioning (`/api/v1/`, `/api/v2/`) |
| **Naming** | RESTful conventions, kebab-case for paths |
| **Methods** | Standard HTTP verbs (GET, POST, PUT, PATCH, DELETE) |
| **Status Codes** | Standard HTTP status codes (see Error Handling) |

### Error Handling

| Status Code | Usage |
|-------------|-------|
| **200** | Successful GET, PUT, PATCH |
| **201** | Successful POST (resource created) |
| **204** | Successful DELETE (no content) |
| **400** | Bad Request (validation errors) |
| **401** | Unauthorized (authentication required) |
| **403** | Forbidden (authorization failed) |
| **404** | Not Found (resource doesn't exist) |
| **409** | Conflict (business rule violation) |
| **422** | Unprocessable Entity (semantic errors) |
| **500** | Internal Server Error |
| **503** | Service Unavailable |

### Error Response Format

```json
{
  "timestamp": "2025-11-24T10:15:30.123Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/v1/customers",
  "correlationId": "abc-123-def-456",
  "details": [
    {
      "field": "email",
      "message": "must be a valid email address"
    }
  ]
}
```

### Cross-Cutting Concerns

| Concern | Implementation |
|---------|----------------|
| **Correlation ID** | Propagate `X-Correlation-ID` header across all calls |
| **Authentication** | OAuth2 / JWT tokens |
| **Authorization** | Role-based access control (RBAC) |
| **Rate Limiting** | Per-client limits on public APIs |
| **Timeouts** | All external calls must have timeouts |
| **Resilience** | Circuit breaker on external dependencies (see ADR-004) |

---

## Rationale

This decision was made based on the following considerations:

1. **Industry Standards Alignment**: REST with OpenAPI is the most widely adopted standard for API design, ensuring broad tooling support and developer familiarity.

2. **Layered Architecture Benefits**: Separating API contracts from domain logic allows independent evolution of external interfaces without impacting core business rules.

3. **Operational Excellence**: Standardized error responses, versioning strategy, and security patterns reduce cognitive load for API consumers and simplify debugging.

4. **Maintainability**: Consistent patterns across all APIs reduce onboarding time for new developers and minimize decision fatigue during implementation.

5. **Interoperability**: RESTful APIs with standard HTTP semantics integrate easily with existing infrastructure (load balancers, API gateways, monitoring tools).

**Alternatives Considered:**
- **GraphQL**: Rejected for external APIs due to complexity in caching, rate limiting, and lack of standardization in error handling. May be considered for internal BFF layers.
- **gRPC**: Rejected for external APIs due to limited browser support. Suitable for internal service-to-service communication.

---

## Consequences

### Positive

- ✅ Clear separation of concerns across layers
- ✅ Reusable Domain APIs across multiple Composable flows
- ✅ Consistent transaction management via SAGA
- ✅ Decoupled UI from business logic
- ✅ Standardized integration contracts
- ✅ Easier scaling and maintenance
- ✅ Better testability per layer

### Negative

- ⚠️ More layers = more network hops (latency)
- ⚠️ Increased complexity for simple use cases
- ⚠️ Requires discipline to maintain layer boundaries
- ⚠️ SAGA complexity for multi-domain transactions

### Mitigations

- Use caching at Experience layer to reduce latency
- Allow Experience to call Domain directly for simple reads
- Provide templates and automation for layer creation
- Clear guidelines and code review enforcement
- Automated compliance validation

---

## Implementation

### Enterprise Reference Implementations (ERIs)

| Layer | ERI | Framework |
|-------|-----|-----------|
| Experience/BFF | eri-004-experience-api-java-spring | Java/Spring |
| Composable | eri-003-composable-api-java-spring | Java/Spring |
| Domain | eri-002-domain-api-java-spring | Java/Spring |
| System | eri-005-system-api-java-spring | Java/Spring |
| Base Structure | eri-code-001-hexagonal-light-java-spring | Java/Spring |

### Automated Skills

| Skill | Purpose |
|-------|---------|
| skill-code-020-generate-microservice-java-spring | Generate base microservice with Hexagonal Light |
| skill-code-021-generate-domain-api-java-spring | Generate Domain API with constraints |
| skill-code-022-generate-composable-api-java-spring | Generate Composable API with SAGA support |

---

## Validation

### Success Criteria

- [ ] All new APIs follow 4-layer model
- [ ] 100% of Domain APIs have compensation endpoints
- [ ] Zero direct calls from Experience to System APIs
- [ ] All cross-domain coordination via Composable APIs
- [ ] OpenAPI specs for all APIs

### Compliance Checks

- Automated layer boundary validation
- API contract compliance checks
- SAGA pattern implementation verification

---

## References

### Related ADRs
- **ADR-004:** Resilience Patterns
- **ADR-006:** Error Handling Standards
- **ADR-009:** Service Architecture Patterns (Hexagonal Light)

### External Resources
- [SAGA Pattern](https://microservices.io/patterns/data/saga.html)
- [API-led Connectivity (MuleSoft)](https://www.mulesoft.com/resources/api/api-led-connectivity)
- [BFF Pattern (Sam Newman)](https://samnewman.io/patterns/architectural/bff/)

---

## Changelog

### v2.0 (2025-11-24)
- Made framework-agnostic (moved Java specifics to ERIs)
- Clarified layer constraints and responsibilities
- Added API contract standards
- Added error response format
- Referenced new ERIs and Skills

### v1.0 (2025-05-27)
- Initial version with 4-layer model
- SAGA pattern for Composable layer

---

**Decision Status:** ✅ Accepted and Active  
**Review Date:** Q2 2025
