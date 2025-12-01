# skill-code-001: Add Circuit Breaker (Java)

> Transforms Java methods to add Resilience4j circuit breaker pattern.

**Domain:** CODE | **Type:** TRANSFORMATION

## Quick Start

```json
{
  "targetClass": "com.example.PaymentService",
  "targetMethod": "processPayment",
  "pattern": {
    "type": "basic_fallback"
  }
}
```

## Patterns

1. **basic_fallback** - Standard (default)
2. **multiple_fallbacks** - Fallback chain
3. **fail_fast** - No fallback
4. **programmatic** - No annotations

## Files Modified

- Java class (annotation + fallback)
- pom.xml (dependencies)
- application.yml (configuration)

## Examples

See `examples/` for before/after code.

## Dependencies

- **ADR:** adr-004-resilience-patterns
- **ERI:** eri-code-008-circuit-breaker-java-resilience4j
- **Module:** mod-001-circuit-breaker-java-resilience4j
