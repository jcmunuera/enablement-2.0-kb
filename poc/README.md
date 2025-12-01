# Proofs of Concept (PoC)

This directory contains Enablement 2.0 project proofs of concept.

## Structure

```
poc/
└── code-generation/     # AI code generation PoC
```

## Planned PoCs

### code-generation (Next)

**Objective:** Validate that the Knowledge Base can feed an AI agent to generate compliant code.

**Scope:**
- Input: Microservice JSON configuration
- Process: Skill-code-020 + Knowledge Base
- Output: Complete, validated Java/Spring microservice

**Status:** Pending design

---

## Conventions

Each PoC should include:

```
poc/{name}/
├── README.md        # Description, objectives, results
├── design/          # Design documents
├── input/           # Input data
├── output/          # Generated results
└── results/         # Analysis and conclusions
```
