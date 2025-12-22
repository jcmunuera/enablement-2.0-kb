# Correcciones Aplicadas - 2025-12-22

## Resumen

Se aplicaron tres correcciones identificadas en el análisis comparativo de las PoC v1, v2 y v3.

---

## Corrección 1: skill-020 - Resilience con Annotations Obligatorio

**Archivo:** `skills/code/soi/skill-020-microservice-java-spring/SKILL.md`

**Versión:** 1.2.0 → 1.3.0

**Problema:** En la PoC v1, los patterns de resilience estaban solo documentados en comentarios, no implementados con annotations.

**Solución:** Se añadió sección "IMPORTANT: Resilience Implementation Requirements" que explicita:

```markdown
**IMPORTANT: Resilience Implementation Requirements**

When resilience features are enabled, they MUST be implemented using Resilience4j annotations, 
NOT just documented in comments. The annotations must be applied to:

1. **System API Adapters/Clients**: All methods that call external System APIs
2. **Application Services**: Methods that orchestrate domain operations

Required annotations (when corresponding feature is enabled):
- `@CircuitBreaker(name = "...", fallbackMethod = "...")`
- `@Retry(name = "...")`
- `@TimeLimiter(name = "...")`
- `@RateLimiter(name = "...")`

Annotation order (per ADR-004): @RateLimiter > @CircuitBreaker > @TimeLimiter > @Retry

Each annotated method MUST have a corresponding fallback method for @CircuitBreaker.
```

---

## Corrección 2: skill-021 - mod-020 es Opt-In

**Archivo:** `skills/code/soi/skill-021-api-rest-java-spring/SKILL.md`

**Versión:** 2.0.0 → 2.1.0

**Problema:** La condición para cargar mod-020 era ambigua (`apiLayer = domain`), lo que llevó a generar compensation sin que el input lo solicitara.

**Solución:** Se cambió la condición a ser explícita (opt-in):

### Antes:
```markdown
| Condition | Module | Purpose |
|-----------|--------|---------|
| `apiLayer = domain` | mod-code-020-compensation-java-spring | Compensation interface |
```

### Después:
```markdown
| Condition | Module | Purpose |
|-----------|--------|---------|
| `apiLayer = domain` AND `features.compensation.enabled = true` | mod-code-020-compensation-java-spring | SAGA compensation interface |

> **NOTE:** mod-020 (compensation) is **opt-in**. Even for Domain APIs, compensation is only 
> generated when explicitly requested via `features.compensation.enabled = true`.
```

**Cambios adicionales:**
- Actualizado pseudocode de Module Selection Logic
- Añadido parámetro `features.compensation.enabled` (boolean, default: false)
- Actualizada tabla de Generated Artifacts

---

## Corrección 3: Formalizar Discovery

**Archivo:** `runtime/discovery/skill-index.yaml`

**Versión:** 2.0 → 2.1

**Problema:** El proceso de discovery no estaba formalizado, lo que llevó a asumir skills sin seguir el proceso correcto.

**Solución:** Se añadió nueva sección `input_validation` con:

### 3.1 Pre-Discovery Validation
```yaml
pre_discovery:
  rules:
    - id: SDLC-001
      check: "Request must be SDLC-related"
    - id: DOMAIN-001
      check: "Domain must be identifiable"
    - id: LAYER-001
      check: "For CODE domain, layer must be identifiable"
```

### 3.2 Skill-Specific Input Validation
```yaml
skill_inputs:
  skill-020-microservice-java-spring:
    required_fields: [serviceName, basePackage, entities]
    validation_rules: [...]
  
  skill-021-api-rest-java-spring:
    inherits: skill-020-microservice-java-spring
    additional_required_fields: [apiLayer]
    validation_rules:
      - field: features.compensation.enabled
        condition: "Only valid when apiLayer = domain"
```

### 3.3 Formalized Discovery Process
```yaml
discovery_process:
  steps:
    1. Extract Keywords
    2. Identify Domain
    3. Identify Layer (for CODE)
    4. Get Candidate Skills
    5. Score Keywords (positive/negative)
    6. Select Best Match
    7. Resolve Inheritance
    8. Validate Input
    9. Execute Skill
  
  error_handling:
    ambiguous_match: "Ask user to clarify"
    no_match: "Inform user, suggest alternatives"
    validation_failure: "Return errors, do NOT generate"
```

---

## Validación de Correcciones

| Corrección | Verificación | Estado |
|------------|--------------|--------|
| 1. Resilience annotations | Texto añadido en skill-020 | ✅ |
| 2. Compensation opt-in | Condición actualizada en skill-021 | ✅ |
| 3. Discovery formalizado | Sección añadida en skill-index.yaml | ✅ |

---

## Próximos Pasos

1. **Regenerar PoC v3** siguiendo el proceso de discovery formalizado
2. **Validar** que compensation NO se genera (input no lo solicita)
3. **Commit** cambios al repositorio
