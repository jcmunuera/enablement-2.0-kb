# Authoring Guide: Execution Flows

**Version:** 3.0  
**Date:** 2026-01-20  
**Model Version:** 3.0

---

## What's New in v3.0

| Change | Description |
|--------|-------------|
| **Skills Eliminated** | Flows are now triggered by discovery, not by skill selection |
| **Two Primary Flows** | `flow-generate` and `flow-transform` replace GENERATE/ADD |
| **Phase-Based Execution** | Features grouped by nature (structural → implementation → cross-cutting) |
| **Flow Selection** | Automatic based on context (existing code or not) |

---

## Overview

Execution Flows define HOW capabilities are applied to generate or transform code. They are located in `runtime/flows/{domain}/`.

### Flow Types in v3.0

| Flow | Purpose | When Used |
|------|---------|-----------|
| **flow-generate** | Create project from scratch | No existing code |
| **flow-transform** | Modify existing project | Existing code provided |
| flow-migrate | *(TBD)* Version/pattern migration | - |
| flow-refactor | *(TBD)* Restructure code | - |
| flow-remove | *(TBD)* Remove capability | - |

---

## Flow Selection

Flow selection is **automatic** based on context:

```python
def select_flow(context):
    if not context.has_existing_code:
        return "flow-generate"
    else:
        return "flow-transform"
```

**Key principle:** The user doesn't choose the flow; the discovery process determines it.

---

## Location

```
runtime/flows/{domain}/flow-{type}.md
```

Examples:
- `runtime/flows/code/flow-generate.md`
- `runtime/flows/code/flow-transform.md`

---

## Required Structure

Every flow document MUST include:

```markdown
# Flow: {Type}

## Overview
[What this flow does and when it's used]

## When to Use
[Conditions that trigger this flow]

## Input
[What the flow receives from discovery]

## Execution
### Phase Planning
[How features are grouped into phases]

### Per-Phase Execution
[Steps executed in each phase]

## Output
[Structure of generated/modified files]

## Validation
[How to validate the output]

## Error Handling
[How to handle common errors]
```

---

## Flow Input (from Discovery)

Every flow receives the **Discovery Result**:

```yaml
flow: flow-generate          # Selected flow
stack: java-spring           # Resolved technology stack
features:                    # Matched features
  - architecture.hexagonal-light
  - api-architecture.domain-api
  - persistence.systemapi
  - resilience.circuit-breaker
modules:                     # Resolved modules
  - mod-code-015
  - mod-code-019
  - mod-code-017
  - mod-code-001
config:                      # Merged feature configs
  hateoas: true
  compensation_available: true
input_spec:                  # Required user input
  serviceName: { type: string, required: true }
  basePackage: { type: string, required: true }
  entities: { type: array, required: true }
```

---

## Phase Planning

Features are grouped into phases based on their **nature**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PHASE PLANNING                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: STRUCTURAL                                                        │
│  Nature: Defines project structure, cannot be modified later                │
│  Features: architecture.*, api-architecture.*                               │
│  Examples: hexagonal-light, domain-api                                      │
│                                                                              │
│  PHASE 2: IMPLEMENTATION                                                    │
│  Nature: Implements ports, connects to backends                             │
│  Features: persistence.*, integration.*                                     │
│  Examples: systemapi, api-rest                                              │
│                                                                              │
│  PHASE 3+: CROSS-CUTTING                                                    │
│  Nature: Adds aspects on top of existing code                               │
│  Features: resilience.*, distributed-transactions.*                         │
│  Examples: circuit-breaker, retry, saga-compensation                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Phase Grouping Rules

```python
def get_feature_nature(feature: str) -> str:
    capability = feature.split('.')[0]
    
    STRUCTURAL = ['architecture', 'api-architecture']
    IMPLEMENTATION = ['persistence', 'integration']
    
    if capability in STRUCTURAL:
        return 'structural'
    elif capability in IMPLEMENTATION:
        return 'implementation'
    else:
        return 'cross-cutting'
```

---

## Per-Phase Execution

Each phase follows this sequence:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PER-PHASE EXECUTION                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. LOAD MODULES                                                            │
│     Load only the modules for features in this phase                        │
│     Keeps context size manageable                                           │
│                                                                              │
│  2. PREPARE CONTEXT                                                         │
│     - User input                                                            │
│     - Feature config                                                        │
│     - Previously generated code (if phase > 1)                              │
│                                                                              │
│  3. GENERATE/TRANSFORM                                                      │
│     Execute code generation using module templates                          │
│                                                                              │
│  4. VALIDATE IMMUTABLES                                                     │
│     Ensure files from previous phases aren't incorrectly modified           │
│                                                                              │
│  5. COMPILE/CHECK                                                           │
│     Verify generated code compiles                                          │
│     If errors, iterate to fix                                               │
│                                                                              │
│  6. UPDATE CONTEXT                                                          │
│     Add generated files to context for next phase                           │
│     Mark files as immutable if appropriate                                  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Output Structure

### Flow Output (flow-generate)

```
{flow-execution}/
├── input/                          # All inputs
│   ├── prompt.md                   # Original user prompt
│   ├── generation-request.json     # Structured request
│   └── {referenced-files}          # API specs, etc.
│
├── output/                         # Generated artifact
│   └── {serviceName}/              # Project directory
│       ├── .enablement/
│       │   └── manifest.json       # Traceability
│       ├── pom.xml
│       ├── src/
│       └── ...
│
├── trace/                          # Execution traceability
│   └── generation-trace.md         # Discovery & generation decisions
│
└── validation/                     # Validation scripts
    ├── compile.sh
    └── test.sh
```

### Flow Output (flow-transform)

```
{flow-execution}/
├── input/                          # Inputs
│   ├── prompt.md
│   └── existing-code/              # Code to modify
│
├── output/                         # Modified files only
│   ├── modified/                   # Files that were changed
│   │   └── {path}/
│   └── created/                    # New files
│       └── {path}/
│
├── trace/
│   └── transformation-trace.md     # What was changed and why
│
└── validation/
    └── compile.sh
```

---

## File Mutability

### Immutable Files (never modified after creation)

```
domain/model/*.java          # Entities, Value Objects
domain/port/*.java           # Repository interfaces
application/dto/*.java       # DTOs
adapter/in/rest/*Controller.java
```

### Modifiable Files (with contract)

```
ApplicationService.java      # Method bodies can be modified
Adapter*.java               # Annotations can be added
pom.xml                     # Dependencies can be added
application.yml             # Sections can be added
```

---

## Determinism Rules

During code generation, the agent MUST follow:

- `model/standards/DETERMINISM-RULES.md` (global patterns)
- Each module's `## Determinism` section (module-specific)

Key rules:
1. Same input → Same output (deterministic)
2. Follow module templates exactly
3. Respect file mutability contracts
4. Use validation to verify output

---

## Validation Requirements

### Per-Phase Validation

After each phase:
1. **Immutable check:** Files from previous phases unchanged
2. **Compilation:** `mvn compile` succeeds
3. **Structure:** Expected files exist

### Final Validation

After all phases:
1. **Full build:** `mvn package` succeeds
2. **Tests:** `mvn test` passes
3. **Traceability:** Manifest complete

---

## Creating a New Flow

### Step 1: Determine Need

Create a new flow when:
- A new execution pattern is needed
- Existing flows don't cover the use case
- The pattern is fundamentally different from generate/transform

### Step 2: Document the Flow

Create `runtime/flows/{domain}/flow-{type}.md` following required structure.

### Step 3: Update References

- Update `runtime/flows/README.md`
- Update `discovery-guidance.md` flow selection logic

---

## Validation Checklist

Before considering a flow complete:

- [ ] Document follows required structure
- [ ] Phase planning is clearly defined
- [ ] Per-phase execution steps documented
- [ ] Output structure defined
- [ ] File mutability rules defined
- [ ] Validation requirements specified
- [ ] Error handling documented
- [ ] Example execution included

---

## Related Documents

- `runtime/discovery/discovery-guidance.md` - Flow selection logic
- `runtime/flows/code/flow-generate.md` - Generation flow
- `runtime/flows/code/flow-transform.md` - Transformation flow
- `model/standards/DETERMINISM-RULES.md` - Code generation rules
- `authoring/MODULE.md` - Module structure

---

**END OF DOCUMENT**
