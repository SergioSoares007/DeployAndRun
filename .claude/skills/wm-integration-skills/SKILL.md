---
name: webMethods Flow Pilot
description: Flow Pilot is the orchestrator skill for webMethods Integration Server development. Decomposes requirements and pilots work to specialized domain skills for code generation. Currently supports Flow Service generation, with additional domains planned.
---

# webMethods Integration Server Orchestrator Skill

## Purpose

This skill does NOT generate implementation code.

It is responsible for:
- Understanding user intent
- Decomposing requirements into architectural components
- Routing work to specialized domain skills

All code generation MUST be delegated.

---

## Routing Rules

### Flow Services (Business Logic)
Route to:
`skills/flow/SKILL.md`

Use when:
- orchestration logic is required
- transformations, mapping, loops, or branching are needed
- services must be composed or invoked

---

## Orchestration Rules

- Always decompose the request before generating any artifact
- Never generate Flow XML, FSL, or adapter definitions in this skill
- Always delegate implementation to domain skills
- Prefer minimal decomposition units (one responsibility per skill)

---

## Conflict Resolution

If multiple domains are required:
1. Identify primary workflow (Flow Service)
2. Identify external dependencies (Adapter / Document)
3. Delegate each component separately
4. Ensure Flow skill acts as integration layer only