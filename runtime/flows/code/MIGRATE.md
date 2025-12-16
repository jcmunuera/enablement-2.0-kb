# Skill Type: CODE/MIGRATE

**Version:** 1.0  
**Last Updated:** 2025-12-12  
**Domain:** CODE  
**Status:** 🔜 Planned

---

## Purpose

MIGRATE skills transform code from one version or framework to another. They handle technical migrations like Spring Boot 2→3, JUnit 4→5, Java 8→17, etc.

---

## Characteristics

| Aspect | Description |
|--------|-------------|
| Input | Existing code + Target version/framework |
| Output | Migrated code |
| Modules | Migration-specific modules with transformation rules |
| Complexity | High - extensive changes |

---

## Planned Skills

| Skill | Purpose |
|-------|---------|
| `skill-code-080-migrate-spring-boot-2-to-3` | Spring Boot 2.x to 3.x |
| `skill-code-081-migrate-junit4-to-5` | JUnit 4 to JUnit 5 |
| `skill-code-082-migrate-java-8-to-17` | Java 8 to Java 17 |
| `skill-code-083-migrate-javax-to-jakarta` | javax.* to jakarta.* |

---

## Migration Modules

Migration modules contain transformation rules rather than templates:

```
mod-code-080-migration-springboot3/
├── MODULE.md
├── transformations/
│   ├── dependencies.rules      # Dependency updates
│   ├── annotations.rules       # Annotation changes
│   ├── configuration.rules     # Config property changes
│   └── code-patterns.rules     # Code pattern updates
└── validation/
    └── validate-migration.sh
```

---

## Status

This skill type is planned but not yet implemented.
