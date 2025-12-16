---
id: qa
name: "QA"
version: 1.0
status: Planned
created: 2025-12-12
updated: 2025-12-12
swarm_alignment: "QA Swarm"
---

# Domain: QA

## Purpose

Code analysis, validation, and audit. This domain produces analysis reports, validation results, and audit documentation to ensure code quality and compliance.

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **ANALYZE** | Analyze code to detect issues | Existing code | Analysis report |
| **VALIDATE** | Verify compliance with standards | Existing code + standards | Validation report |
| **AUDIT** | Generate audit reports | Existing code | Audit report |

See `skill-types/` for detailed execution flows.

---

## Module Structure

Modules in the QA domain contain:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Report templates |
| `rules/` | ✅ | Analysis rules and checks |
| `validation/` | ✅ | Report format validators |

### Rule Structure

```
rules/
├── rule-001-check-name.sh      # Individual check
├── rule-002-check-name.sh
└── ruleset.yaml                # Rule configuration
```

### Ruleset Format

```yaml
ruleset:
  id: architecture-compliance
  version: 1.0
  rules:
    - id: rule-001
      name: "Hexagonal Layer Separation"
      severity: ERROR
      check: "rule-001-hexagonal-layers.sh"
    - id: rule-002
      name: "No Domain to Infrastructure"
      severity: ERROR
      check: "rule-002-dependency-direction.sh"
```

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `analysis-report` | Detailed analysis findings | Architecture compliance report |
| `validation-report` | Pass/fail validation | ADR compliance check |
| `audit-report` | Comprehensive audit | Security audit, dependency audit |

---

## Capabilities

Planned capabilities for QA domain:

| Capability | Description | Status |
|------------|-------------|--------|
| `architecture_analysis` | Architecture compliance checks | 🔜 Planned |
| `code_quality` | Code quality metrics | 🔜 Planned |
| `security_analysis` | Security vulnerability detection | 🔜 Planned |
| `dependency_audit` | Dependency analysis | 🔜 Planned |

---

## Applicable Concerns

| Concern | How it applies to QA |
|---------|----------------------|
| Security | Security-focused analysis rules |
| Performance | Performance analysis rules |
| Observability | Observability completeness checks |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-qa-{NNN}-{analysis-type}` | `eri-qa-001-architecture-compliance` |
| Module | `mod-qa-{NNN}-{analysis-type}` | `mod-qa-001-adr-compliance-rules` |
| Skill | `skill-qa-{NNN}-{type}-{target}` | `skill-qa-001-analyze-architecture-compliance` |

---

## Status

This domain is **planned** but not yet implemented.

### Planned Skills

```
QA/ANALYZE:
├── skill-qa-001-analyze-architecture-compliance
├── skill-qa-002-analyze-security-vulnerabilities
├── skill-qa-003-analyze-performance-bottlenecks
└── skill-qa-004-analyze-code-quality

QA/VALIDATE:
├── skill-qa-040-validate-adr-compliance
├── skill-qa-041-validate-coding-standards
├── skill-qa-042-validate-api-contract
└── skill-qa-043-validate-test-coverage

QA/AUDIT:
├── skill-qa-080-audit-dependencies
├── skill-qa-081-audit-technical-debt
├── skill-qa-082-audit-security-posture
└── skill-qa-083-audit-license-compliance
```
