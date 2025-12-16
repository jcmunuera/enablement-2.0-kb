# Skill Type: CODE/REMOVE

**Version:** 1.0  
**Last Updated:** 2025-12-12  
**Domain:** CODE  
**Status:** 🔜 Planned

---

## Purpose

REMOVE skills remove features or code from existing projects. They are the inverse of ADD skills.

---

## Characteristics

| Aspect | Description |
|--------|-------------|
| Input | Existing code + Feature/code to remove |
| Output | Modified code (removals) |
| Modules | References same modules as ADD |
| Complexity | Medium - targeted removals |

---

## Input Schema

```yaml
# removal-request.yaml
projectPath: "./customer-service"

remove:
  type: "circuit_breaker"  # Feature to remove
  targets:
    - className: "InventoryClient"
      methods:
        - name: "getStock"
```

---

## Execution Flow

```
1. Validate Input
2. Analyze Existing Code
3. Identify Removal Targets
   - Annotations
   - Fallback methods
   - Configuration entries
   - Dependencies (if no longer needed)
4. Generate Removal Plan
5. Apply Removals
6. Update Manifest
7. Run Validations
8. Output
```

---

## Status

This skill type is planned but not yet implemented. See CODE/ADD for the inverse operation.
