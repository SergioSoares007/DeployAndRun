---
name: flow
description: Generate webMethods Integration Server Flow Services using the Flow Script Language (FSL). Use this skill whenever the user requests new Flow Services, modifications to existing Flow Services, FSL validation, or translation between FSL and Flow XML.
---

# webMethods Integration Server Flow Service Generation Skill

## Purpose

This skill is responsible for generating and validating Flow Services expressed in Flow Script Language (FSL).

It is strictly a code-generation skill. It does not orchestrate multi-domain solutions. It does not design architectures across adapters or schemas. It focuses only on correct, grammar-compliant FSL generation.

---

## Core Principle

**The FSL grammar is the ultimate authority.**

If any rule conflicts with grammar definitions, the grammar always wins.

---

## Execution Pipeline (MANDATORY)

All requests MUST follow this deterministic pipeline:

### Step 1 — Constraint Loading
Read and apply the following documents in order:

1. `references/mandatory-pregeneration-checklist.md`
2. `references/authoring-guide.md`
3. `references/core-syntax-specifications-and-operational-rules.md`
4. `references/operational-rules-and-code-construction-patterns.md`
5. `references/known-limitations.md`
6. `references/best-practices.md` ⚠️ **MANDATORY — contains the Pipeline Hygiene Gate (BP-002, BP-003) which MUST be applied during Step 5 before any output is emitted. Do not skip this file.**

---

### Step 2 — Grammar Loading
Load and interpret grammar definitions BEFORE planning output:

```
grammar/readme.md
grammar/
```

All generated FSL MUST conform exactly to this grammar.

---

### Step 3 — Example Alignment
Review relevant patterns:

```
examples/
```

Do not copy blindly—use only for structural alignment.

⛔ Do NOT read or reference anything under the `tutorials/` folder during FSL generation. The tutorials directory is strictly off-limits for this skill.

---

### Step 4 — Service Catalog Resolution
Resolve all INVOKE targets using:

```
service-catalogs/
```

Never invent services that are not defined in the catalog.

---

### Step 5 — Internal Construction Phase (NO OUTPUT YET)

Before writing output, construct an internal model:

- Service signature (inputs/outputs)
- Pipeline variables
- Control flow structure
- Mapping strategy
- Error handling strategy

Do NOT emit partial FSL during this phase.

---

### Step 6 — Output Generation

Emit ONLY valid FSL. Unless otherwise instructed, write the output to `{ServiceName}/flow.flow` in the workspace root directory, where `{ServiceName}` is the unqualified service name (e.g. service `MyFolder:MyService` → `MyService/flow.flow`). Create the `{ServiceName}` folder if it does not already exist. Do not print the FSL to the chat.

No explanations.
No markdown.
No backticks.
No commentary.

### ⚠️ REFERENCE READING GUARDRAIL
Never delegate the reading of any reference or rules document listed in this pipeline to a subagent. All files in Steps 1–3 must be read directly into your own context window. A summarised version does not carry the same compliance weight as reading the source directly.

---

## Required Reading (Reference Layer)

These documents define authoritative rules:

- `references/mandatory-pregeneration-checklist.md`
- `references/authoring-guide.md`
- `references/core-syntax-specifications-and-operational-rules.md`
- `references/operational-rules-and-code-construction-patterns.md`
- `references/known-limitations.md`

---

## Grammar Authority

The grammar defines valid syntax.

Always load:

```
grammar/readme.md
grammar/
```

If grammar and any other document disagree:
➡ grammar overrides everything

---

## Service Catalog Rules

When generating INVOKE steps:

- Use only services defined in `service-catalogs/`
- Match parameter names exactly
- Do not infer missing inputs
- Do not rename services

---

## Examples

Use examples only as structural guidance:

```
examples/
```

Never copy literal values unless explicitly requested.

⛔ Do NOT read or reference the `tutorials/` folder. It is off-limits for FSL generation.

---

## Strict Flow Logic Constraints

## Step-Specific Construction Rules

When generating or modifying control flow blocks, you must extract the exact syntax and execution constraints from the `references/` directory based on the step types requested in the prompt:

* **Conditional Logic (`BRANCH`, `SWITCH`, `IF`):** Apply evaluation label rules and routing path syntax from `references/operational-rules-and-code-construction-patterns.md`.
* **Error Handling (`TRY-CATCH`, `TRY-FINALLY`):** Apply block isolation limits and explicit exit sequence constraints from `references/authoring-guide.md`.
* **Iterative Elements (`LOOP`, `WHILE`, `REPEAT`):** Apply explicit parent path tracking (`parent/field`) and dimension resolution boundaries from `references/core-syntax-specifications-and-operational-rules.md`.

---

## Anti-Hallucination Rules

Do NOT:

- Invent Flow syntax or keywords
- Guess undocumented grammar rules
- Fabricate service names
- Invent file paths or example references
- Assume external context exists

If required information is missing:
➡ Stop and request clarification

---

## State Handling

Each request is stateless.

Do NOT assume:

- previous services
- prior pipeline state
- earlier transformations
- hidden context

Only use:
- current request
- referenced documentation

---

## Conflict Resolution Hierarchy

If conflicts exist:

1. `grammar/` (absolute authority)
2. core-syntax-specifications-and-operational-rules.md
3. operational-rules-and-code-construction-patterns.md
4. authoring-guide.md
5. examples/
6. service-catalogs/

---

## Compliance Rule

Partial compliance is invalid.

If full compliance cannot be achieved:
- stop generation
- do not approximate output
- request clarification instead

---

## Supplemental Instructions

Some requests require specialised behaviour beyond standard FSL generation. If the request matches one of the triggers below, load the corresponding supplement file and follow its instructions exclusively for that task.

| Trigger | Supplement |
|---|---|
| User asks to **review**, **audit**, **check**, or **validate** existing FSL or a Flow Service | `supplements/code-review.md` |
| User asks to **generate**, **create**, **write**, **produce**, or **build** unit tests, a test suite, test cases, or test coverage for a service | `supplements/unit-testing-guide.md` |
| User asks to **document**, **describe**, or **write docs** for a service | `supplements/service-documentation.md` |
| User asks to **diagram**, **visualise**, **draw**, or **create a flow diagram** for a service | `supplements/service-diagramming.md` |
| User asks to **upgrade**, **migrate**, or **assess version compatibility** of a Flow Service | `supplements/version-upgrade-guide.md` |

### How to apply a supplement

⚠️ **MANDATORY**: The supplement file MUST be read as the **first action** taken in response to the request — before any analysis, planning, or output. Do not proceed with any task step until the supplement is loaded into context.

1. **Read the supplement file in full** before producing any output, performing any analysis, or planning any steps.
2. Follow the instructions in the supplement **instead of** the standard Step 5 → Step 6 generation pipeline.
3. The supplement defines its own output format — do not apply the standard FSL Output Contract to supplement-driven responses.
4. If a supplement was not loaded first and you are mid-task, stop, read the supplement, and restart the task from the beginning following its instructions.

---

## Output Contract

Final output MUST:

- be valid FSL
- conform to grammar exactly
- contain no explanations or metadata
- contain no formatting or markdown wrappers
- be directly executable in Integration Server context
- be written to `{ServiceName}/flow.flow` in the workspace root directory, where `{ServiceName}` is the unqualified service name (e.g. `MyService/flow.flow`). Create the folder if it does not exist.
- not be printed to the chat unless explicitly instructed

---