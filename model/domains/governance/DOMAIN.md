---
id: governance
name: "GOVERNANCE"
version: 1.0
status: Planned
created: 2025-12-12
updated: 2025-12-12
swarm_alignment: "GOVERNANCE Swarm"
---

# Domain: GOVERNANCE

## Purpose

Documentation generation, compliance verification, and policy management. This domain produces documentation, compliance reports, and enforces organizational policies.

---

## Skill Types

| Type | Purpose | Input | Output |
|------|---------|-------|--------|
| **DOCUMENTATION** | Generate documentation | Code/data | Documentation artifacts |
| **COMPLIANCE** | Verify and apply policies | Code + policies | Compliance report |
| **POLICY** | Manage and enforce policies | Policy definitions | Applied policies |

See `skill-types/` for detailed execution flows.

---

## Module Structure

Modules in the GOVERNANCE domain contain:

| Component | Required | Description |
|-----------|----------|-------------|
| `MODULE.md` | ✅ | Module specification |
| `templates/` | ✅ | Documentation templates |
| `policies/` | ⚠️ Optional | Policy definitions |
| `validation/` | ✅ | Document/compliance validators |

### Policy Structure

```yaml
# policy-definition.yaml
policy:
  id: branch-protection
  version: 1.0
  scope: repository
  rules:
    - name: "Require PR reviews"
      config:
        required_approvals: 2
    - name: "Require status checks"
      config:
        checks: ["build", "test", "lint"]
```

---

## Output Types

| Type | Description | Example |
|------|-------------|---------|
| `documentation` | Generated docs | API docs, changelog, runbook |
| `compliance-report` | Policy compliance status | License compliance report |
| `policy-artifact` | Applied policy | Branch protection rules |

---

## Capabilities

Planned capabilities for GOVERNANCE domain:

| Capability | Description | Status |
|------------|-------------|--------|
| `api_documentation` | OpenAPI, AsyncAPI docs | 🔜 Planned |
| `changelog_generation` | Automated changelogs | 🔜 Planned |
| `license_compliance` | License checking | 🔜 Planned |
| `policy_enforcement` | Repository policies | 🔜 Planned |

---

## Applicable Concerns

| Concern | How it applies to GOVERNANCE |
|---------|------------------------------|
| Security | Security policy enforcement |
| Performance | N/A |
| Observability | Documentation of observability setup |

---

## Naming Conventions

| Asset | Pattern | Example |
|-------|---------|---------|
| ERI | `eri-gov-{NNN}-{doc-type}` | `eri-gov-001-api-documentation` |
| Module | `mod-gov-{NNN}-{doc-type}` | `mod-gov-001-openapi-docs` |
| Skill | `skill-gov-{NNN}-{type}-{target}` | `skill-gov-001-documentation-api` |

---

## Status

This domain is **planned** but not yet implemented.

### Planned Skills

```
GOVERNANCE/DOCUMENTATION:
├── skill-gov-001-documentation-api
├── skill-gov-002-documentation-changelog
├── skill-gov-003-documentation-release-notes
└── skill-gov-004-documentation-runbook

GOVERNANCE/COMPLIANCE:
├── skill-gov-040-compliance-license
├── skill-gov-041-compliance-security-policies
└── skill-gov-042-compliance-data-governance

GOVERNANCE/POLICY:
├── skill-gov-080-policy-branch-protection
├── skill-gov-081-policy-code-owners
└── skill-gov-082-policy-pr-enforcement
```
