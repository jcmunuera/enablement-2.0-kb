# PoC: Code Generation - Customer Domain API

## Objetivo

Demostrar la generación de código para una Domain API completa usando el Knowledge Base de Enablement 2.0.

## Escenario

```
┌─────────────────────┐     ┌─────────────────────┐
│   Customer          │     │   Parties           │
│   Domain API        │────▶│   System API        │
│   (a generar)       │     │   (mainframe)       │
└─────────────────────┘     └─────────────────────┘
         │                           │
    REST normalizado            Legacy COBOL/CICS
    camelCase                   UPPERCASE, abreviado
    Enums                       Single char codes
    ISO timestamps              DB2 timestamps
```

## Inputs

| Archivo | Descripción | Origen |
|---------|-------------|--------|
| `domain-api-spec.yaml` | OpenAPI de la Domain API | Skill de diseño (simulado) |
| `system-api-parties.yaml` | OpenAPI de la System API | Existente (legacy) |
| `mapping.json` | Mapeo de campos y transformaciones | Skill de mapping + validación humana |
| `prompt.md` | Solicitud del usuario | Usuario |
| `generation-request.json` | Request estructurado para skill-020 | Skill de interpretación (simulado) |

## Capacidades Aplicadas

| Capability | Module | Descripción |
|------------|--------|-------------|
| Hexagonal Light | mod-015 | Estructura base del proyecto |
| Integration REST | mod-018 | RestClient para System API |
| Persistence System API | mod-017 | Adapter de persistencia |
| Circuit Breaker | mod-001 | Protección ante fallos |
| Retry | mod-002 | Reintentos con backoff |
| Timeout | mod-003 | Límite de tiempo |

## Flujo de Generación

```
[1] prompt.md
     │
     ▼
[2] Skill Interpretación (simulated)
     ├── Lee domain-api-spec.yaml
     ├── Lee system-api-parties.yaml
     ├── Lee mapping.json
     │
     ▼
[3] generation-request.json
     │
     ▼
[4] Skill Generation (skill-020)
     ├── Resuelve modules necesarios
     ├── Procesa templates (.tpl)
     ├── Aplica variables
     │
     ▼
[5] output/customer-domain-api/
```

## Estructura de Output Esperada

```
output/customer-domain-api/
├── pom.xml
├── README.md
├── src/main/java/com/bank/customer/
│   ├── CustomerApplication.java
│   │
│   ├── domain/
│   │   ├── model/
│   │   │   ├── Customer.java
│   │   │   ├── CustomerId.java
│   │   │   └── CustomerStatus.java
│   │   ├── repository/
│   │   │   └── CustomerRepository.java          # Port (interface)
│   │   ├── exception/
│   │   │   └── CustomerNotFoundException.java
│   │   └── service/
│   │       └── CustomerDomainService.java       # Pure POJO
│   │
│   ├── application/
│   │   ├── dto/
│   │   │   ├── CustomerResponse.java
│   │   │   └── CreateCustomerRequest.java
│   │   ├── mapper/
│   │   │   └── CustomerApplicationMapper.java
│   │   └── service/
│   │       └── CustomerApplicationService.java  # @Service, @Transactional
│   │
│   ├── adapter/
│   │   ├── inbound/
│   │   │   └── rest/
│   │   │       └── CustomerController.java
│   │   └── outbound/
│   │       └── systemapi/
│   │           ├── client/
│   │           │   └── PartiesApiClient.java    # RestClient
│   │           ├── dto/
│   │           │   └── PartyDto.java
│   │           ├── mapper/
│   │           │   └── PartyMapper.java         # Domain <-> System API
│   │           └── CustomerSystemApiAdapter.java # Implements port + resilience
│   │
│   └── infrastructure/
│       └── config/
│           ├── ApplicationConfig.java
│           ├── RestClientConfig.java
│           └── ResilienceConfig.java
│
├── src/main/resources/
│   └── application.yml
│
└── src/test/java/com/bank/customer/
    ├── domain/
    │   └── service/
    │       └── CustomerDomainServiceTest.java
    └── adapter/
        └── outbound/
            └── CustomerSystemApiAdapterTest.java
```

## Cómo Ejecutar (futuro)

```bash
# Cuando exista el motor de generación
./generate.sh --config inputs/generation-request.json --output output/

# Verificar output
cd output/customer-domain-api
mvn clean verify
```

## Trazabilidad

Ver `trace/generation-trace.md` para el log de decisiones tomadas durante la generación.
