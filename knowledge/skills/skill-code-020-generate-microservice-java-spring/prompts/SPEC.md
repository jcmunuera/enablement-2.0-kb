# SPEC.md - LLM Prompt Specification

## Skill: skill-020-generate-microservice-java-spring

---

## System Prompt

```
You are an expert Java/Spring Boot code generator specializing in Hexagonal Light architecture. Your task is to generate a complete, production-ready microservice from a JSON configuration.

## Architecture Principles

You MUST follow Hexagonal Light architecture (ADR-009):

1. **Domain Layer (Pure POJOs)**
   - NO Spring annotations (@Service, @Autowired, @Component, etc.)
   - NO framework dependencies
   - Contains: entities, value objects, domain services, repository interfaces
   - Business logic lives HERE

2. **Application Layer**
   - Spring @Service and @Transactional annotations
   - Thin orchestration - delegates to domain
   - Bridges adapters and domain

3. **Adapter Layer**
   - REST: @RestController, DTOs, mappers
   - Persistence: @Entity, JpaRepository, repository adapters
   - All framework code lives HERE

4. **Infrastructure**
   - @Configuration beans
   - Exception handlers
   - Cross-cutting concerns

## Dependency Direction

Adapters → Application → Domain

Domain layer knows NOTHING about Spring or JPA.

## API Type Constraints (ADR-001)

Based on apiType, apply these constraints:

- **domain_api**: Owns data, no cross-domain HTTP clients
- **composable_api**: Stateless orchestration, calls Domain APIs
- **system_api**: SoR integration, data transformation
- **experience_api**: BFF pattern, calls Composable/Domain APIs

## Code Quality Standards

1. Use Java records for DTOs and value objects
2. Use constructor injection (no @Autowired on fields)
3. Add JSR-380 validation annotations on request DTOs
4. Generate meaningful Javadoc comments
5. Use AssertJ for test assertions
6. Follow naming conventions exactly
```

---

## User Prompt Template

```
Generate a complete Spring Boot microservice with the following configuration:

<config>
{{CONFIG_JSON}}
</config>

## Requirements

1. Generate ALL files needed for a working microservice
2. Follow Hexagonal Light architecture strictly
3. Domain layer must have ZERO Spring annotations
4. Include unit tests for domain services (no Spring context needed)
5. Generate OpenAPI spec from entity definitions
6. Apply all enabled features from config

## Output Format

For each file, output:

```
### FILE: {relative/path/to/file.java}

\`\`\`java
// file contents
\`\`\`
```

Generate files in this order:
1. pom.xml
2. Application.java
3. Domain layer (all entities, services, repositories, exceptions)
4. Application layer (application services)
5. Adapter layer (REST: controllers, DTOs, mappers; Persistence: entities, repos, adapters)
6. Infrastructure (config, exception handlers)
7. Tests
8. Resources (application.yml, openapi.yaml)
9. Docker files (if enabled)

## Validation Checklist

Before outputting, verify:
- [ ] Domain layer has no @Service, @Autowired, @Component, @Repository annotations
- [ ] Repository interface is in domain layer
- [ ] Repository implementation (adapter) is in adapter layer
- [ ] All Spring annotations are in application or adapter layers
- [ ] DTOs use Jakarta validation annotations
- [ ] Constructor injection used everywhere
- [ ] Tests can run without Spring context
```

---

## Expected Response Structure

The LLM should output files in this order:

### Phase 1: Project Setup
```
### FILE: pom.xml
### FILE: .gitignore
### FILE: README.md
```

### Phase 2: Application Entry
```
### FILE: src/main/java/{package}/Application.java
```

### Phase 3: Domain Layer
```
### FILE: src/main/java/{package}/domain/model/{Entity}.java
### FILE: src/main/java/{package}/domain/model/{Entity}Id.java
### FILE: src/main/java/{package}/domain/model/{Entity}Registration.java
### FILE: src/main/java/{package}/domain/service/{Entity}DomainService.java
### FILE: src/main/java/{package}/domain/repository/{Entity}Repository.java
### FILE: src/main/java/{package}/domain/exception/{Entity}NotFoundException.java
```

### Phase 4: Application Layer
```
### FILE: src/main/java/{package}/application/service/{Entity}ApplicationService.java
```

### Phase 5: Adapter Layer - REST
```
### FILE: src/main/java/{package}/adapter/rest/controller/{Entity}Controller.java
### FILE: src/main/java/{package}/adapter/rest/dto/{Entity}DTO.java
### FILE: src/main/java/{package}/adapter/rest/dto/Create{Entity}Request.java
### FILE: src/main/java/{package}/adapter/rest/dto/Update{Entity}Request.java
### FILE: src/main/java/{package}/adapter/rest/mapper/{Entity}DtoMapper.java
```

### Phase 6: Adapter Layer - Persistence
```
### FILE: src/main/java/{package}/adapter/persistence/entity/{Entity}Entity.java
### FILE: src/main/java/{package}/adapter/persistence/repository/{Entity}JpaRepository.java
### FILE: src/main/java/{package}/adapter/persistence/adapter/{Entity}RepositoryAdapter.java
### FILE: src/main/java/{package}/adapter/persistence/mapper/{Entity}EntityMapper.java
```

### Phase 7: Infrastructure
```
### FILE: src/main/java/{package}/infrastructure/config/ApplicationConfig.java
### FILE: src/main/java/{package}/infrastructure/exception/GlobalExceptionHandler.java
### FILE: src/main/java/{package}/infrastructure/exception/ErrorResponse.java
```

### Phase 8: Tests
```
### FILE: src/test/java/{package}/domain/service/{Entity}DomainServiceTest.java
### FILE: src/test/java/{package}/adapter/rest/controller/{Entity}ControllerIntegrationTest.java
```

### Phase 9: Resources
```
### FILE: src/main/resources/application.yml
### FILE: src/main/resources/application-dev.yml
### FILE: src/main/resources/application-prod.yml
### FILE: src/main/resources/openapi.yaml
```

### Phase 10: Docker (if enabled)
```
### FILE: Dockerfile
### FILE: .dockerignore
```

---

## Validation Prompt

After generation, use this prompt to validate:

```
Review the generated code for compliance:

1. **Hexagonal Light Compliance**
   - Does domain layer have ANY Spring annotations? (FAIL if yes)
   - Is repository interface in domain layer? (FAIL if no)
   - Is repository implementation in adapter layer? (FAIL if no)

2. **Code Quality**
   - Are all dependencies injected via constructor?
   - Do request DTOs have validation annotations?
   - Do tests use AssertJ assertions?

3. **API Type Compliance**
   - If domain_api: Are there HTTP clients to other domains? (FAIL if yes)
   - If composable_api: Is persistence enabled? (WARN if yes)

List any violations found.
```

---

## Error Recovery Prompts

### If domain layer has Spring annotations:

```
The generated domain layer contains Spring annotations. This violates Hexagonal Light architecture.

Please regenerate the following files WITHOUT any Spring annotations:
- {list of files}

The domain layer must be pure POJOs. Move all Spring annotations to:
- Application layer (@Service, @Transactional)
- Adapter layer (@RestController, @Entity, @Repository, etc.)
```

### If tests require Spring context:

```
The generated domain tests require Spring context. This defeats the purpose of Hexagonal Light.

Please regenerate {Entity}DomainServiceTest.java:
- Use @ExtendWith(MockitoExtension.class) instead of @SpringBootTest
- Mock the repository interface
- No Spring annotations in test class
- Test should run in milliseconds without starting Spring
```

---

## Multi-LLM Support

This skill can be executed by:

| LLM | Notes |
|-----|-------|
| Claude 3.5 Sonnet | Recommended - best code quality |
| Claude 3 Opus | Good for complex configs |
| GPT-4 | Compatible with minor prompt adjustments |
| GPT-4 Turbo | Good for large file counts |

### LLM-Specific Adjustments

**For GPT-4:**
- Add explicit "Do not use @Autowired" instruction
- Emphasize file naming conventions

**For Claude:**
- Can handle full context in single prompt
- Better at maintaining consistency across files
