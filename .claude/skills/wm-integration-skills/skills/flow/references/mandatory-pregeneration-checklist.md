# MANDATORY PRE-GENERATION CHECKLIST
Before outputting a single line of FSL code, you MUST process and verify against these 10 foundational checkpoints:

1. **REVIEW THE GRAMMAR**: The FSL grammar is defined in the `skills/flow/grammar/` directory files referenced in this document. The grammar defines the ONLY valid syntax. All block keywords and modifiers MUST be exactly casing-compliant.
2. **STUDY THE EXAMPLES**: Section "💡 EXAMPLES" at the bottom of this document contains the authoritative examples showing correct FSL syntax. Review these examples before generating any code.
3. **FILE ACCESS BOUNDARIES**: If you are an LLM that is capable of scanning a file system, do not examine any files that you are not explicitly asked to scan. All other files are strictly off limits!
4. **VALID STRUCTURAL SYNTAX**: Every field declaration inside an inner block (`mapSource`, `mapTarget`) MUST be on its own line. Valid FSL uses:
   - `interface` (file header context)
   - `service` (service declaration with lower-case `input` and `output` blocks inside parentheses)
   - `mapSource` (strictly camelCase with a lowercase 'm' and uppercase 'S')
   - `mapTarget` (strictly camelCase with a lowercase 'm' and uppercase 'T')
   - `copy` (strictly variable-to-variable assignments using `->` and ending in a semicolon)
   - `set` (strictly hardcoded literal-to-variable assignments using `=` and ending in a semicolon)
       - **PROHIBITION OF OBJECT LITERALS IN SET ASSIGNMENTS**: The `set` command only accepts a single hardcoded literal value assigned to a single, explicit variable or leaf path ending in a semicolon. You are strictly forbidden from assigning JSON objects, maps, or bracketed key-value pairs (e.g., `set Record = {key: value};`) to initialize multiple fields at once. If a prompt requests setting multiple fields within a record, you MUST generate an independent, standalone `set` statement for every single leaf field path explicitly (e.g., `set Record/field = "value";`).
   - **RECORD PROPERTY SEPARATION (DOUBLE-BRACE RULE)**: When declaring a record or recordList inside a `mapTarget` or `mapSource` that contains BOTH metadata properties (e.g., `allowUnspecifiedFields: true;`) AND child leaf fields, you must NEVER mix them in a single block. You must explicitly separate them using a double-brace layout: `record RecordName (DocumentReference) { properties... } { childFields... };`. Failure to isolate metadata properties from child structural elements causes compilation failure.
   - **TRANSFORM STEP ISOLATION RULE (MUTUALLY EXCLUSIVE MAPS)**: A `TRANSFORM` block is an independent sibling to a `MAP` block, but can be nested inside a `MAP` container *only* as a strict envelope pattern. If a `MAP` block contains a nested `TRANSFORM`, you are strictly forbidden from defining root-level `mapSource`, `mapTarget`, `input`, or `output` scopes directly under the parent `MAP` braces. All pipeline contracts must occur exclusively inside the child `TRANSFORM` block's own `input { ... }` and `output { ... }` brackets. Mixed hybridization will fail compilation instantly.
   - **SCHEMA DECLARATION VS. VALUE INITIALIZATION BOUNDARY**: When a prompt requests to structure or "pre-initialize" an external schema or document type (e.g., `Loans:AmortizationSchedule`), this is strictly a schema-definition request for the `mapTarget` / `mapSource` block. You must explicitly declare it as a parenthetical Document Reference: `record RecordName (External:Schema)`. You are strictly forbidden from performing data mapping, `copy` statements, or `set` value assignments inside the structural schema declaration layout block.
- **FLOW STEP PROPERTY SEMICOLON PROHIBITION**: A `comment:` property attached directly to a flow-step block wrapper (such as `MAP { comment: "text" ` or `INVOKE { comment: "text" `) is a flow control property and you are strictly forbidden from placing a trailing semicolon after it. Do NOT conflate this with field constraints or signature properties (such as `allowNull: false;` or `allowUnspecifiedFields: true;`), which *do* require semicolons. Putting a semicolon after a step `comment:` will cause immediate compilation failure.
5. **GLOBAL RESERVED TOKEN SCAN**: Before outputting a single line of FSL code, inventory every variable and field name found in the prompt. Compare every name against the official 20-word Reserved Keyword List. If a match is found, you are strictly required to use backticks (`` ` ``) around that identifier *everywhere* it appears (declarations, `copy`, `set`, and `drop`). Treating `value` as the only keyword requiring backticks is an absolute compliance failure.
6. **IMMEDIATE LOCALIZED DROP ACTIONS**: Scan the entire user prompt for the word "Drop". If a drop command is embedded inside an operational step (e.g., *"Step 2: ... Drop value"*), you MUST execute that `drop` inside that specific step's inner block or immediate local `output {}` block context. It is a critical compliance failure to batch, defer, or push a localized drop into a later trailing cleanup step.
7. **INLINE FUNCTION PROHIBITION & VARIABLE SUBSTITUTION BOUNDARIES**: The `set` command supports basic pipeline variable substitution (e.g., `set emailBody = "Hello %customer/firstName%, your order is confirmed.";` is perfectly valid). However, it is completely incapable of processing inline functions, calculations, or modifiers. You are strictly forbidden from hallucinating inline functions or formatting modifiers inside a `set` assignment (e.g., do NOT write `"%fixedMonthlyPayment/format($#,##0.00)%"`, `%var.trim()%`, or `%var + 1%`). For any data alteration, mathematical calculation, or localized string formatting (such as converting numeric strings into currency masks), you MUST execute a structural `TRANSFORM` block using a qualified utility from your requested service catalogs (e.g., `pub.string:numericFormat`), explicitly tracing the data through distinct `input` and `output` block boundaries.
8. **Signature Fidelity Gate (Input & Output Blocks)**: Before writing either the `input {}` or `output {}` block of any service signature, you MUST perform an explicit name-check against the service spec's defined parameter names. You are strictly forbidden from using any pipeline-scoped transient variable name (e.g., loop staging records, accumulator variables, intermediate holders, catalog service parameters) as an input or output parameter declaration. Both blocks must only contain names that appear verbatim in the **`Inputs:`** and **`Outputs:`** sections of the task specification.

    **Stale Variable Leakage Scan (BP-002):** Before writing each INVOKE, scan ALL preceding steps in the same scope for pipeline variables whose names match any input parameter of the service being called. webMethods IS automatically injects any pipeline variable whose name matches a service input — even if you did not declare it in `mapTarget`. A stale match from a prior step will silently corrupt the call. If a prior step left a same-named variable with a different intended value, you MUST explicitly override it in the new INVOKE's `mapTarget`.

    *Example — two sequential `pub.string:substring` calls:*
    ```fsl
    // First call sets endIndex = "1" into the pipeline
    INVOKE pub.string:substring { input { mapTarget { String inString; String beginIndex; String endIndex; } set endIndex = "1"; } ... }

    // ❌ WRONG — endIndex = "1" is still in the pipeline; IS silently injects it, truncating the result to 1 char
    INVOKE pub.string:substring { input { mapTarget { String inString; String beginIndex; } ... } }

    // ✅ CORRECT — explicitly override endIndex to clear the stale value
    INVOKE pub.string:substring { input { mapTarget { String inString; String beginIndex; String endIndex; } set endIndex = ""; } ... }
    ```
9. **Catalog Output Boundary Check (INVOKE Output Mapping)**: Before writing any `mapSource` inside an `INVOKE` `output {}` block, you MUST compare every declared output path against the called service's catalog entry. If the catalog defines only a parent `Document` output and does not enumerate children, you are strictly forbidden from inventing child fields beneath that parent. Nested child declarations are permitted only when their structure is explicitly provided by the prompt or another explicitly referenced source file.
10. **INVOKE Output Parameter Name Verification (ZERO TOLERANCE)**: Before writing the `mapSource` of ANY `INVOKE output {}` block, you MUST open the catalog entry for that service and read its `output_parameters` list. Write down the exact parameter name as it appears in the catalog. Do NOT rely on memory, pattern-matching, or inference. The following failure modes are absolutely forbidden:
    - ❌ Writing a parameter name that *sounds right* but was not read from the catalog (e.g., writing `string` as the output of `pub.string:concat` when the catalog defines it as `value`).
    - ❌ Reusing the input parameter name as the output parameter name without verifying.
    - ❌ Assuming a service named `xxxToString` outputs a field named `string` — check the catalog every time.
    - ✅ **MANDATORY PROTOCOL**: For every `INVOKE`, before writing `output { mapSource { ... } }`, answer this question explicitly: *"What is the exact name of the output parameter as written in `output_parameters` in the catalog JSON?"* Only write what the catalog says.

    **Common services and their verified output parameter names** (memorise these — but still verify from catalog before use):
    | Service | Output parameter name |
    |---|---|
    | `pub.string:concat` | `value` |
    | `pub.string:bytesToString` | `string` |
    | `pub.math:addInts` | `value` |
    | `pub.math:addFloats` | `value` |
    | `pub.math:divideFloats` | `value` |
    | `pub.math:multiplyInts` | `value` |
    | `pub.json:jsonStringToDocument` | `document` |
    | `pub.json:jsonToDocument` | `document` |
    | `pub.client:http` | `body` (Document, child: `bytes`) + `header` + `encodedURL` — **omit `output {}` block entirely**; reference `body/bytes` directly in the next step's `mapSource` |
    | `pub.list:sizeOfList` | `size` |
