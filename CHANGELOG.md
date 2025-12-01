# Changelog

All notable changes to Enablement 2.0 will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2025-12-01

### 🎉 Initial Release

First version of the Knowledge Base on GitHub. Corresponds to internal version v7.0.

#### Added

**Resilience Patterns (Complete)**
- ERI-CODE-008: Circuit Breaker (Resilience4j)
- ERI-CODE-009: Retry Pattern (Resilience4j)
- ERI-CODE-010: Timeout Pattern (Resilience4j)
- ERI-CODE-011: Rate Limiter (Resilience4j)
- mod-001 through mod-004: Templates for each pattern
- ADR-004: Resilience Patterns decision record

**Persistence Patterns (New)**
- ERI-CODE-012: Persistence Patterns (JPA + System API unified)
- mod-016: JPA persistence template
- mod-017: System API persistence template (Feign/RestTemplate/RestClient variants)
- ADR-011: Persistence Patterns decision record
- CAPABILITY: persistence

**Hexagonal Architecture**
- ERI-CODE-001: Hexagonal Light (Java/Spring)
- mod-015: Hexagonal base template
- ADR-009: Service Architecture Patterns

**Skills**
- skill-code-001: Add Circuit Breaker to existing service
- skill-code-020: Generate Microservice (v1.2.0)
  - Full resilience options
  - Persistence type selection (JPA vs System API)
  - System API client selection (Feign/RestTemplate/RestClient)

**Model & Standards**
- ENABLEMENT-MODEL v1.2
- ASSET-STANDARDS v1.3
- Authoring guides with ERI/MODULE breakdown criteria
- 4-tier validation system

**Project Structure**
- GitHub repository structure
- Work methodology documented
- Session documentation system

#### Technical Details

| Metric | Value |
|--------|-------|
| Total Files | ~215 |
| ERIs | 6 |
| MODULEs | 7 |
| ADRs | 4 |
| SKILLs | 2 |
| CAPABILITIEs | 3 |

---

## Version History (Pre-GitHub)

For reference, internal versions before GitHub migration:

| Internal | Description | Date |
|----------|-------------|------|
| v7.0 | Resilience complete + Persistence patterns | 2025-12-01 |
| v6.0 | ERI machine-readable annex mandatory | 2025-11-28 |
| v5.0 | Validator restructure, domain prefixes | 2025-11-27 |
| v4.0 | Model reorganization, 4-tier validation | 2025-11-26 |
| v3.0 | Governance documents, traceability | 2025-11-25 |

---

## Upcoming

### [1.1.0] - Planned
- Code Generation PoC results
- Observability patterns (planned)

### [2.0.0] - Future
- MCP Server integration
- Multi-agent architecture
