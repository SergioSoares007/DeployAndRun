# Service Diagramming Supplement

## When to Generate Diagrams

Generate a `.mmd` diagram file:
- ✅ When the user explicitly requests a diagram
- ✅ When the user asks to "diagram", "visualise", "draw", or "create a flow diagram for" a service
- ❌ NOT automatically with every FSL generation unless requested

---

## Output File

- **Format:** Raw Mermaid syntax only — no Markdown wrapper, no title heading, no surrounding prose
- **Location:** Same folder as the `.flow` file
- **File name:** `{ServiceName}.mmd` (e.g., `getJoke/getJoke.mmd`)

---

## Diagram Content Requirements

Every generated diagram MUST include:
- Start and end nodes
- Input parsing or initialisation nodes
- All major `MAP`, `INVOKE`, `TRANSFORM`, loop, and branch structures
- Labels that reflect the actual generated service logic
- Distinct styling classes for map nodes, invoke/transform nodes, loop nodes, and branch nodes

---

## Mermaid Authoring Rules

### Chart Type

Always use `flowchart TD`. Do not use `graph TD`.

---

### Colour Palette (`classDef`)

Always declare the following `classDef` entries at the top of every diagram. Only omit a `classDef` if **no node in the diagram uses that class**.

| Class | Fill | Stroke | Text | Use for |
|---|---|---|---|---|
| `startEnd` | `#e8f5e9` | `#388e3c` | `#1b5e20` | Start/end terminals |
| `mapStep` | `#e3f2fd` | `#1976d2` | `#0d47a1` | MAP steps |
| `invoke` | `#e8eaf6` | `#3949ab` | `#1a237e` | INVOKE and TRANSFORM steps |
| `decision` | `#fff9c4` | `#f9a825` | `#4e342e` | Decision diamonds (IF, ELSEIF, BRANCH, SWITCH, loop conditions) |
| `tryBlock` | `#fce4ec` | `#c62828` | `#b71c1c` | TRY/CATCH block nodes |
| `exitStep` | `#f3e5f5` | `#7b1fa2` | `#4a148c` | EXIT steps |

Apply `:::className` to **every** node.

---

### Node Shapes

| Shape syntax | Use for |
|---|---|
| `([label])` | Start and end terminals (`:::startEnd`) |
| `[label]` | MAP steps, INVOKE steps, TRANSFORM steps, EXIT steps |
| `{label}` | Decision diamonds — IF, BRANCH, SWITCH, loop conditions |

---

### Section Comments

Add `%% Section Name` comments immediately before each logical group of nodes (e.g., `%% Styling`, `%% Start`, `%% Step 1: ...`). These are mandatory navigation markers, not decorative.

---

### ASCII Arrows in Node Labels

Always use ASCII arrows (`->`) inside node label text. Never use the Unicode right-arrow character (`→`). Mermaid connector syntax (`-->`, `--label-->`) is unaffected — only the text content inside node labels must use `->`.

---

### Subgraph Rules

#### TRY/CATCH/FINALLY
Always render TRY, CATCH, and FINALLY as three **separate sibling subgraphs** — never as a single combined subgraph. Steps belonging to the TRY body go inside `subgraph TRY`, CATCH body steps go inside `subgraph CATCH`, and FINALLY body steps go inside `subgraph FINALLY`. The cross-subgraph edges (failure arc, success-to-finally, catch-to-finally) are declared outside all three subgraphs.

#### IF/ELSEIF/ELSE
Always render each branch of a conditional as a **separate sibling subgraph** — `subgraph IF_BLOCK`, `subgraph ELSEIF_BLOCK`, `subgraph ELSE_BLOCK`. The condition nodes (`IF: condition?`, `ELSEIF: condition?`) sit outside all subgraphs as decision diamonds. Edges from the condition nodes into the branch subgraphs, and from each branch subgraph to the convergence node, are all declared outside the subgraphs.

#### BRANCH cases
Always render each case of a BRANCH as a **separate sibling subgraph** named after the path (e.g. `subgraph BRANCH_ADD`, `subgraph BRANCH_DEFAULT`). The BRANCH condition diamond sits outside all case subgraphs. All routing edges from the condition into case subgraphs, and from each case to the convergence node, are declared outside the subgraphs.

#### SWITCH cases
Always render each case of a SWITCH as a **separate sibling subgraph** named after the case value (e.g. `subgraph SWITCH_MULTIPLY`, `subgraph SWITCH_DEFAULT`). The SWITCH condition diamond sits outside all case subgraphs. All routing edges are declared outside the subgraphs.

#### Condition text in subgraph titles
For IF/ELSEIF/ELSE, BRANCH, and SWITCH, embed the condition expression directly in the subgraph title label (e.g. `subgraph IF_BLOCK["IF: sum == '0'"]`, `subgraph BRANCH_ADD["BRANCH: branchMode == 'add'"]`, `subgraph SWITCH_MULTIPLY["SWITCH: switchMode == 'multiply'"]`). Always route edges directly to the **first node inside** each subgraph (e.g. `F -->|sum == 0| H`, `L -->|add| M`), never to the subgraph ID itself — Mermaid renders both labelled and unlabelled edges-to-subgraph-IDs as floating gap nodes above the box.

#### ⛔ No intermediary ghost nodes
Never introduce an undeclared node (e.g. `J_SEQ`, `K_SEQ`, `E_SEQ`) as a routing hop between a decision diamond and a subgraph entry point. Every node ID that appears in an edge (`A --> B`) **must** be explicitly declared somewhere in the diagram with a label and shape (e.g. `B[...]`, `B{...}`, `B([...])`). Undeclared node IDs render as unlabelled floating nodes in Mermaid. Route the decision diamond edge directly to the first declared node inside the target subgraph — no intermediaries.

#### Receiver node pattern (LOOP, WHILE, DO/UNTIL, REPEAT, SEQUENCE)
For every iterating or sequencing construct that uses a subgraph, place a labelled **receiver node outside and before** the subgraph. This receiver node describes the construct type and its key parameter (e.g. `LOOP: iterate over items`, `WHILE: count == 0?`, `REPEAT: count=3, repeatOn=FAILURE`). The receiver node links into the subgraph, and the subgraph contains only the body steps.

#### Loop-back dashed arrows
For every iterating construct (LOOP, WHILE, DO/UNTIL, REPEAT), draw a dashed arrow (`-.->|label|`) from the point where a new iteration begins back to the receiver node. Use descriptive labels: `next iteration`, `re-evaluate`, `loop back`, `retry on failure`. This makes it visually clear that execution cycles rather than falls through.

---

### Escaping Special Characters in Node Labels

When Mermaid node text contains reserved characters, escape them using HTML entities:

| Character | Entity |
|---|---|
| `{` | `&#123;` |
| `}` | `&#125;` |
| `[` | `&#91;` |
| `]` | `&#93;` |

This applies especially to REST paths — e.g. `/customers/{id}` must be written as `/customers/&#123;id&#125;` inside a node label.

---

### Edge Labels

Label edges clearly for branching logic: `success`, `error`, `true`, `false`, `default`.

---

## Inline Diagram (Embedded in `.md` Documentation)

When a diagram is embedded inline inside a `.md` documentation file (the `## Flow Diagram` section), wrap the Mermaid content in a fenced ` ```mermaid ` code block and apply exactly the same authoring rules above. The `classDef` block must be present inside the fenced code block. Example structure:

````markdown
## Flow Diagram
```mermaid
flowchart TD
    classDef startEnd  fill:#e8f5e9,stroke:#388e3c,color:#1b5e20
    classDef mapStep   fill:#e3f2fd,stroke:#1976d2,color:#0d47a1
    classDef invoke    fill:#e8eaf6,stroke:#3949ab,color:#1a237e
    classDef decision  fill:#fff9c4,stroke:#f9a825,color:#4e342e
    classDef tryBlock  fill:#fce4ec,stroke:#c62828,color:#b71c1c
    classDef exitStep  fill:#f3e5f5,stroke:#7b1fa2,color:#4a148c

    {nodes and edges}
```
````

---

## Formatting Constraints

1. Use `flowchart TD` — not `graph TD`.
2. Do NOT include Markdown code fences, headings, or explanatory prose in `.mmd` files.
3. Apply `classDef`/`:::className` styling to every node — do not use inline `style` directives.
4. Ensure each diagram reflects the actual FSL structure — not a generic summary.
5. Add `%% Section Name` comments before each logical group.
6. **No unused `classDef` declarations.** Only declare a `classDef` for a class used by at least one node.

---

## Concrete Example — AmortizationCalculator

The following is the reference diagram for the `Loans:AmortizationCalculator` service. It shows the correct way to render a WHILE loop with a receiver node, loop-back dashed arrow, and post-loop steps.

```
flowchart TD
    classDef startEnd  fill:#e8f5e9,stroke:#388e3c,color:#1b5e20
    classDef mapStep   fill:#e3f2fd,stroke:#1976d2,color:#0d47a1
    classDef invoke    fill:#e8eaf6,stroke:#3949ab,color:#1a237e
    classDef decision  fill:#fff9c4,stroke:#f9a825,color:#4e342e

    %% Start
    A([Start]):::startEnd

    %% Initialisation
    A --> B[MAP: Convert annual rate to monthly rate]:::mapStep
    B --> C[MAP: Calculate total payment count]:::mapStep
    C --> D[INVOKE pub.math:toNumber -- loanAmount]:::invoke
    D --> E[INVOKE Loans:CalculateFixedMonthlyPrincipalAndInterestPayment]:::invoke

    %% WHILE loop
    E --> F{WHILE: monthNumber <= totalPayments?}:::decision

    subgraph WHILE_BODY["WHILE body"]
        G[MAP: Calculate interest for period]:::mapStep
        H[MAP: Calculate principal for period]:::mapStep
        I[MAP: Append row to AmortizationSchedule]:::mapStep
        J[MAP: Increment monthNumber]:::mapStep
        G --> H --> I --> J
    end

    F -->|true| G
    J -.->|next iteration| F
    F -->|false| K[MAP: Calculate totalInterestPaid]:::mapStep

    %% Post-loop summary
    K --> L[MAP: Calculate totalCost]:::mapStep
    L --> M[MAP: Calculate interestRatio and trueCostFactor]:::mapStep
    M --> N[MAP: Calculate tippingPointMonth]:::mapStep
    N --> O[MAP: Calculate fiveYearEquity]:::mapStep
    O --> P[MAP: Format currency outputs]:::mapStep

    %% End
    P --> Q([End -- return AmortizationSchedule and summary fields]):::startEnd
```

---

## Mandatory Output Template

Every generated `.mmd` file MUST conform to this structural pattern:

```
flowchart TD
    %% Styling
    classDef startEnd  fill:#e8f5e9,stroke:#388e3c,color:#1b5e20
    classDef mapStep   fill:#e3f2fd,stroke:#1976d2,color:#0d47a1
    classDef invoke    fill:#e8eaf6,stroke:#3949ab,color:#1a237e
    classDef decision  fill:#fff9c4,stroke:#f9a825,color:#4e342e
    classDef tryBlock  fill:#fce4ec,stroke:#c62828,color:#b71c1c
    classDef exitStep  fill:#f3e5f5,stroke:#7b1fa2,color:#4a148c

    %% Start
    A([Start: {ServiceName}]):::startEnd

    %% Step 1: ...
    A --> B[{StepDescription}]:::invoke

    %% ... additional steps ...

    %% End
    Z([End: {ServiceName}]):::startEnd
    {LastStep} --> Z
```
