# Templates Pendientes de Actualización

**Fecha:** 2026-01-26  
**Última actualización:** 2026-01-26 (v3.0.10)
**Contexto:** DEC-024 (CONTEXT_RESOLUTION) requiere que todos los templates documenten sus variables requeridas

## Estado Actual

### ✅ Templates Actualizados (33)

#### mod-code-015-hexagonal-base (14/22)
- [x] `domain/Entity.java.tpl`
- [x] `domain/EntityId.java.tpl`
- [x] `domain/Repository.java.tpl`
- [x] `domain/NotFoundException.java.tpl`
- [x] `domain/Enum.java.tpl`
- [x] `application/ApplicationService.java.tpl`
- [x] `application/dto/CreateRequest.java.tpl`
- [x] `application/dto/Response.java.tpl`
- [x] `adapter/RestController.java.tpl`
- [x] `config/pom.xml.tpl`
- [x] `config/application.yml.tpl`
- [x] `infrastructure/GlobalExceptionHandler.java.tpl`
- [x] `infrastructure/CorrelationIdFilter.java.tpl`
- [x] `Application.java.tpl`

#### mod-code-017-persistence-systemapi (4/11)
- [x] `adapter/SystemApiAdapter.java.tpl`
- [x] `mapper/SystemApiMapper.java.tpl`
- [x] `exception/SystemApiUnavailableException.java.tpl`
- [x] `config/application-systemapi.yml.tpl`

#### mod-code-018-api-integration-rest (4/9)
- [x] `client/restclient.java.tpl`
- [x] `config/restclient-config.java.tpl`
- [x] `exception/IntegrationException.java.tpl`
- [x] `config/application-integration.yml.tpl`

#### mod-code-019-api-public-exposure (3/6)
- [x] `assembler/EntityModelAssembler.java.tpl`
- [x] `dto/PageResponse.java.tpl`
- [x] `dto/FilterRequest.java.tpl`

#### mod-code-001-circuit-breaker (3/7)
- [x] `annotation/basic-fallback.java.tpl`
- [x] `config/application-circuitbreaker.yml.tpl`
- [x] `config/pom-circuitbreaker.xml.tpl`

#### mod-code-002-retry (3/6)
- [x] `annotation/basic-retry.java.tpl`
- [x] `config/application-retry.yml.tpl`
- [x] `config/pom-retry.xml.tpl`

#### mod-code-003-timeout (2/8)
- [x] `client/timeout-config.java.tpl` (variante client-timeout)
- [x] `client/application-client-timeout.yml.tpl`

### ❌ Templates Pendientes (36)

#### mod-code-015-hexagonal-base (8 pendientes)
- [ ] `domain/DomainService.java.tpl`
- [ ] `application/dto/UpdateRequest.java.tpl`
- [ ] `application/dto/Response-hateoas.java.tpl`
- [ ] `infrastructure/ApplicationConfig.java.tpl`
- [ ] `test/ControllerTest.java.tpl`
- [ ] `test/EntityTest.java.tpl`
- [ ] `test/EntityIdTest.java.tpl`
- [ ] `test/DomainServiceTest.java.tpl`

#### mod-code-017-persistence-systemapi (7 pendientes)
- [ ] `client/restclient.java.tpl`
- [ ] `client/feign.java.tpl`
- [ ] `client/resttemplate.java.tpl`
- [ ] `config/feign-config.java.tpl`
- [ ] `dto/Dto.java.tpl`
- [ ] `dto/Request.java.tpl`
- [ ] `test/SystemApiAdapterTest.java.tpl`

#### mod-code-018-api-integration-rest (5 pendientes)
- [ ] `client/feign.java.tpl`
- [ ] `client/resttemplate.java.tpl`
- [ ] `config/feign-config.java.tpl`
- [ ] `config/resttemplate-config.java.tpl`
- [ ] `test/ClientTest.java.tpl`

#### mod-code-019-api-public-exposure (3 pendientes)
- [ ] `config/PageableConfig.java.tpl`
- [ ] `config/application-pagination.yml.tpl`
- [ ] `test/AssemblerTest.java.tpl`

#### mod-code-001-circuit-breaker (4 pendientes)
- [ ] `annotation/chain-fallback.java.tpl`
- [ ] `annotation/fail-fast.java.tpl`
- [ ] `programmatic/programmatic.java.tpl`
- [ ] `test/CircuitBreakerTest.java.tpl`

#### mod-code-002-retry (3 pendientes)
- [ ] `annotation/retry-with-fallback.java.tpl`
- [ ] `annotation/retry-with-circuitbreaker.java.tpl`
- [ ] `test/RetryTest.java.tpl`

#### mod-code-003-timeout (6 pendientes)
- [ ] `annotation/basic-timeout.java.tpl`
- [ ] `annotation/timeout-with-fallback.java.tpl`
- [ ] `annotation/full-resilience-stack.java.tpl`
- [ ] `config/application-timeout.yml.tpl`
- [ ] `config/pom-timeout.xml.tpl`
- [ ] `test/TimeoutTest.java.tpl`

## Prioridad de Actualización

**Completado (Alta - PoC Customer API):**
- ✅ mod-015: Templates estructurales principales
- ✅ mod-017: SystemApiAdapter, SystemApiMapper
- ✅ mod-018: restclient (default), config
- ✅ mod-019: Assembler, PageResponse
- ✅ mod-001/002/003: Resilience básicos

**Pendiente (Media):**
- Tests templates
- Variantes alternativas (feign, resttemplate)

**Pendiente (Baja):**
- Templates de casos edge
- DomainService (no usado en PoC)
