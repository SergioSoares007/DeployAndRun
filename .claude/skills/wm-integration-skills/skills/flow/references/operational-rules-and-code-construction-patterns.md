## 1. **HEADLESS START**: Every script MUST start directly with the `interface` keyword.
## 2. **SIGNATURE STRUCTURE**: The service `input` and `output` blocks MUST be enclosed in parentheses `()` immediately following the service name.
- Ensure all field declarations in the `input` and `output` blocks strictly follow the `Type variableName;` format.
- **Quoted Literals**: Ensure corrected label definitions. 
- `label: "default"` requires the string literal quotes. 
## 3. **SEMICOLONS & BLOCK TERMINATION**:
- **NO Block Semicolons**: ALL block structures (`MAP`, `INVOKE`, `IF`, `BRANCH`, `SEQUENCE`, `LOOP`, `REPEAT`, `WHILE`, `DO`, `TRY`, `CATCH`, `FINALLY`, `EXIT`) must **NOT** have a semicolon `;` after their closing brace `}`.
- **Statement Semicolons**: Individual statements inside blocks (`set`, `copy`, and variable declarations inside signature/map blocks) MUST be terminated with a semicolon `;`.
- **Property Declarations**: Properties inside blocks (like `evaluateLabels: true`, `maxIteration: 50`, `exitFrom: "$flow"`, or `comment: "..."`) do NOT end with semicolons.
- **Loop Control**: `BREAK` does not require a semicolon. `CONTINUE` can optionally have one.
## 4. **NO OMISSIONS & SEQUENTIAL LOGIC**:
- **Completeness**: Include EVERY step and field mentioned by the user.
- **Sequential Ordering**: Every "If", "Switch", and "Invoke" must be rendered as a unique, independent block ending in a `;`.
## 5. **NESTING & DOCUMENTS**:
- **BODY SCOPE**: Use `{}` ONLY to define internal members of a `record` or `recordList`.
- **EMPTY DOCUMENTS**: Define simple structures as `record myDoc;` or `recordList myDoc;`.
- **EXTERNAL REFERENCE**: Use the reference attribute: `record myDoc (reference: "folder.path:DocName");`.
- **FORBIDDEN METADATA**: Do NOT use `{}` for metadata or `subType` unless defined within the constraint brackets `[]`.
## 6. **SETTING VALUES & TYPES (FSL Logic)**:
- **FIELD DECLARATIONS**:
    - Never use path notation (e.g., `items/quantity`) when declaring variables
    - Dots are allowed in field declarations (e.g., `String watt.server.usejavaregex;`).
- **ALLOWED TYPES**: `String`, `Integer`, `Double`, `Boolean`, `Long`, `Byte[]`, etc.
- **🚨 BYTE ARRAY TYPE GUARDRAIL (CRITICAL)**: The FSL lexer defines `'byte'` (lowercase) as `BYTE_PRIMITIVE` — a token that is NOT valid in field declarations. The only valid FSL byte-array type is `Byte[]` (capital B, no space). This applies everywhere a field type is declared: `mapSource`, `mapTarget`, and service signatures.
    - ❌ **FORBIDDEN**: `byte[] bytes;` — lowercase `byte` is not a valid `dataType` and causes `invalid syntax at input '{byte'` parse errors.
    - ❌ **FORBIDDEN**: `byte[ ]` or `Byte[ ]` — space before `[]` is not valid FSL syntax.
    - ✅ **MANDATORY**: `Byte[] bytes;` — capital B, `[]` with no space, terminated with semicolon.
    - **Catalog translation rule**: Service catalogs display the byte-array type as `byte[ ]` (IBM docs format). Always translate this to `Byte[]` when writing FSL declarations.
- **TYPE DECLARATION**: Use direct types (e.g., `Integer myVar;`). Avoid `Object` with `subType` metadata.
- **TYPE INFERENCE FOR MAPPING**: When mapping variables in INVOKE or TRANSFORM blocks, the **catalog definition always takes precedence** over the pipeline source variable type.
    - **Catalog Type Precedence Rule (CRITICAL)**: If the target service's catalog entry defines a parameter type (e.g., `String num1`), the `mapTarget` declaration MUST use that catalog-defined type — even if the pipeline source variable has a different type (e.g., `Integer`).
    - **Example**: `pub.math:addInts` defines `num1` and `num2` as `String` in its catalog. Even if your pipeline variable is `Integer in1`, the `mapTarget` MUST declare `String num1`. Consequently, the service signature input MUST also be `String` to ensure end-to-end type consistency and prevent `Missing Parameter` errors at runtime.
    - **Example**: If no catalog type constraint exists and you are mapping `quantity` (Integer) to a generic `num1`, match the source type: declare `Integer num1`.
    - **Rule**: Always check the catalog entry first. Catalog-defined parameter types override source variable types in `mapTarget` declarations.
- **MAP ASSIGNMENT**: Use `set`. Every entry MUST end with a semicolon.
    - **CORRECT**: `set variableName = "literalValue";`
    - **PATH NOTATION**: Path notation (e.g., `parent/child`) is permitted in `set` and `copy` targets, but **FORBIDDEN** in declarations.
- **VARIABLE LINKING (copy)**: Use `copy sourceVar -> targetVar;`.
- **TRANSFORMER BOUNDARIES (MAPPING STRUCTURE)**:
    - **Structure**: Inside `TRANSFORM`, use `input { ... }` and `output { ... }` blocks.
    - **Pipeline Definition**: Both `input` and `output` blocks should contain `mapSource` and `mapTarget` blocks to define the pipeline interface.
    - **Auto-Declaration Integration**: If a field is referenced in a `set` or `copy` statement but is not present in the current `mapSource` or `mapTarget` block, you **MUST** trigger the **IMPLICIT SCHEMA & AUTO-DECLARATION LOGIC** defined in Section 8.
    - **Declaration Sequence**: Always check for the existence of the field in the signature. If absent, inject the `mapSource` or `mapTarget` declaration block *immediately preceding* the assignment statement.
    - **Termination**: The `TRANSFORM` block must NOT have a semicolon after its closing brace `}`.
## 7. **BRANCH & SEQUENCE PROPERTIES**:
- All properties (like `switch: var` or `label: "val"`) MUST use a colon `:` but do NOT end with semicolons.
- Properties MUST be placed INSIDE the same curly braces as the child steps.
- **CORRECT**: `BRANCH { switch: myVar SEQUENCE { label: "Step1" ... } }`
## 8. **ARRAY INITIALIZATION**:
- Use square brackets for list literals: `set myList = ["A", "B", "C"];`.
- Do NOT wrap the entire array in outer quotes.
- Ensure the target variable is declared as a `recordList` or an array type (e.g., `String[]`).
## 9. **SYNTACTIC VALIDITY (GRAMMAR)**:
- **STRICT ADHERENCE**: Follow the block termination rules explicitly. Every individual assignment, configuration step, or structural variable definition statement inside a block requires a semicolon, but structural code block braces (`}`) themselves must remain completely free of trailing semicolons.
- **STRUCTURAL INTEGRITY**: Follow the `service Name (signature) { body }` pattern. Every opening brace `{` must have a corresponding closing brace `}`.
## 10. **ZERO-INFERENCE & EXPLICIT AUTHORING (CRITICAL)**:
- **NO EMPTY BLOCKS**: NEVER insert empty `MAP`, `INVOKE`, or `SEQUENCE` blocks unless explicitly requested.
- **NO OPTIONAL LINKS**: Only generate `copy` or assignment commands for variables mentioned in the prompt.
- **NO OPTIONAL ELEMENTS**: Do NOT add optional elements (comments, properties, blocks) unless explicitly requested in the user's instructions.
    - **Examples show optional features for demonstration purposes only**
    - **DO NOT include optional properties** like `maxIteration`, `comment`, `timeout`, etc. unless specifically requested
    - **Only include properties that are**:
            1. Explicitly mentioned in the requirements, OR
            2. Required by the grammar (e.g., `inputArray` for LOOP, `count` for REPEAT)
- **STRICT LOGIC MAPPING**: Author only the logic provided. If the user says "If status is OK, call S1," do NOT infer an `ELSE` block.
## 11. **SIGNATURE FIDELITY (INPUTS & OUTPUTS)**:
- **TYPE POLICY**: Use native primitive types (`String`, `Integer`, `Double`, `Boolean`, `Long`, `Object`).
- **PROHIBITED**: NEVER use the `Object { subType: "..." }` pattern.
- **EXTERNAL REFERENCES**: Use the parenthetical reference syntax: `record varName (reference: "folder.path:DocTypeName");`.
- **FINAL SCAN**: Verify no `subType` keywords exist.
## 12. **INVOKE BLOCK STRUCTURE & PROPERTY PROHIBITION (CRITICAL)**:
- **Service Identifier Position:** The service name identifier MUST immediately follow the `INVOKE` keyword. It is a structural identifier, never an internal property string or a key-value assignment.
- **Absolute Prohibition of `service:` Property:** NEVER use a `service:` property or key-value pair inside the block braces (e.g., ❌ `INVOKE { service: pub.math:divideFloats }` is completely invalid).
- **Mandatory Wrapper Blocks:** If mapping is required for an `INVOKE` step, you MUST wrap `mapSource` and `mapTarget` inside explicit `input {}` and `output {}` block containers[cite: 2]. They are never allowed to sit at the immediate root level of the `INVOKE` block[cite: 2].
- **Omission Rule:** If no mapping is requested for an `INVOKE`, omit the `input` and `output` blocks entirely.
- **🚨 INVOKE INPUT BLOCK PIPELINE CONTRACT RULE (CRITICAL):** The `mapTarget` inside an `INVOKE`'s `input {}` block defines the called service's own input parameter names. It does **NOT** create or promote new pipeline variables. Those target names are consumed by the service call and are never added to the pipeline. Consequently, the `mapSource` in a subsequent INVOKE's `input {}` block MUST reflect the true current pipeline state — NOT the `mapTarget` names from the previous INVOKE's `input {}` block. Only `mapTarget` names declared inside an `output {}` block are promoted into the pipeline after the step completes.
    - ❌ **FORBIDDEN reasoning:** "The previous INVOKE's input mapTarget declared `bytes`, therefore `bytes` is now a top-level pipeline variable I can reference next."
    - ✅ **CORRECT reasoning:** "The previous INVOKE's output mapTarget declared `bytes`, therefore `bytes` is now a top-level pipeline variable. The previous INVOKE's input mapTarget declared `bytes` as a service parameter — that name was consumed by the call and does not exist in the pipeline."
    - **Practical example:** If a service outputs a parent Document (e.g., `body`, `automobile`, `response`) containing child fields (e.g., `bytes`, `engine`, `status`), that parent Document is **always present** in the pipeline after the INVOKE completes — regardless of whether you write an `output {}` block. An `output {}` block is **additive**: it promotes additional explicitly named variables alongside the native outputs; it does NOT remove, replace, or consume any native output. Therefore, if you copy `parentDoc/childField` into a flat variable in the output block, the pipeline now contains **both** the original `parentDoc` document **and** the new flat variable. The next INVOKE's `mapSource` may reference either path. If you did NOT write an `output {}` block at all, the next INVOKE's `mapSource` must reference the nested path `parentDoc/childField` directly.
    - 🚨 **ANTI-PATTERN — OUTPUT BLOCK EXTRACTION DOES NOT ELIMINATE THE NATIVE OUTPUT:** Never reason "I extracted `parentDoc/childField` into a flat variable in the output block, therefore `parentDoc` no longer exists in the pipeline and subsequent steps must use the flat variable." This reasoning is false for any service and any field name. The native parent document is always still present in the pipeline. The preferred pattern when the next step needs a nested child field is to **omit the `output {}` block entirely** from the first INVOKE and reference `parentDoc/childField` directly in the subsequent INVOKE's `input {}` mapSource. Introducing an intermediate extraction step solely to rename or flatten a variable adds unnecessary complexity.
    - 🚨 **`pub.client:http` — DO NOT EXTRACT `body/bytes` INTO AN INTERMEDIATE PIPELINE VARIABLE (CRITICAL):** When invoking `pub.client:http` (whether via `INVOKE` or `TRANSFORM`), you MUST NOT write an `output {}` block that copies `body/bytes` into a new intermediate pipeline variable (e.g., `responseBytes`). The `body` Document — including its `bytes` child — is already present in the pipeline natively after the call completes. Any subsequent step that needs the byte array (e.g., `pub.string:bytesToString`) can reference `body/bytes` directly in its own `input {}` `mapSource`. Introducing an intermediate `responseBytes` variable is unnecessary complexity and violates the zero-inference authoring rule.
        - ❌ **FORBIDDEN — extracting body/bytes into an intermediate variable:**
        ```fsl
        INVOKE pub.client:http {
            input { ... }
            output {
                mapSource {
                    record body {
                        Byte[] bytes;
                    };
                }
                mapTarget {
                    Byte[] responseBytes;
                }
                copy body/bytes -> responseBytes;
            }
        }
        INVOKE pub.string:bytesToString {
            input {
                mapSource {
                    Byte[] responseBytes;   // ❌ unnecessary intermediate variable
                }
                mapTarget {
                    Byte[] bytes;
                }
                copy responseBytes -> bytes;
            }
        }
        ```
        - ✅ **CORRECT — omit the output block, reference body/bytes directly in the next step:**
        ```fsl
        INVOKE pub.client:http {
            input {
                mapSource {
                    String fullUrl;
                }
                mapTarget {
                    String url;
                    String method;
                }
                copy fullUrl -> url;
                set method = "get";
            }
        }
        INVOKE pub.string:bytesToString {
            input {
                mapSource {
                    record body {
                        Byte[] bytes;
                    };
                }
                mapTarget {
                    Byte[] bytes;
                }
                copy body/bytes -> bytes;
            }
        }
        ```
    - **CORRECT (No Mapping):** `INVOKE pub.flow:debugLog {}`
    - **CORRECT (With Mapping):**
```fsl
INVOKE pub.math:divideFloats {
    input {
        mapSource {
            String interestRate;
        }
        mapTarget {
            String num1;
        }
        copy interestRate -> num1;
    }
    output {
        mapSource {
            String `value`;
        }
        mapTarget {
            String interestPct;
        }
        copy `value` -> interestPct;
    }
}
```
## 12a. **INVOKE OUTPUT BLOCK MAPSOURCE FIDELITY (CRITICAL)**:
- **Rule:** When writing the `mapSource` inside an `output {}` block of an `INVOKE` step, you MUST declare the exact nested document hierarchy that the called service returns — as documented in the service catalog. You are strictly forbidden from flattening a nested child field to the root level of the `mapSource`.
- **🚨 OUTPUT PARAMETER NAME FIDELITY (ZERO TOLERANCE)**: The `mapSource` in an `output {}` block must use the **exact parameter name** as listed in the catalog's `output_parameters`. You are strictly forbidden from guessing, inferring, or pattern-matching the output parameter name from the service name or its input parameters. Before writing any `output { mapSource { ... } }` block, you MUST read the catalog entry and use the name verbatim.
    - ❌ **FORBIDDEN** — inferring `string` as the output of `pub.string:concat` because the service deals with strings. The catalog defines the output as `value`.
    - ❌ **FORBIDDEN** — reusing an input parameter name (e.g., `jsonString`) as the output name without verifying.
    - ✅ **MANDATORY** — read `output_parameters[].name` from the catalog JSON for every service before writing its `output {}` block.
- **No Child Inference Rule:** If the service catalog defines an output only as a top-level `Document` (for example, `document`) and does not explicitly enumerate its children, you are strictly forbidden from inventing, guessing, or assuming nested fields under that document in `mapSource`. A child path under that document is allowed only when the child structure is explicitly provided by the user prompt or another explicitly referenced source file.
- **Cause of error:** Declaring a child field (e.g., `bytes`) as a flat top-level entry in `mapSource` when the catalog shows it is nested inside a parent document (e.g., `body`) is a structural lie. Likewise, declaring an undocumented nested field (for example, `document/rates`) when the catalog only guarantees `document` is also a structural lie. The `mapSource` must mirror the real shape of the service output.
- ❌ **FORBIDDEN (flat — wrong):**
```fsl
output {
    mapSource {
        byte[] bytes;
    }
    mapTarget {
        byte[] bytes;
    }
    copy bytes -> bytes;
}
```
- ❌ **FORBIDDEN (invented child — wrong):**
```fsl
output {
    mapSource {
        record document {
            recordList rates;
        };
    }
    mapTarget {
        recordList exchangeRates;
    }
    copy document/rates -> exchangeRates;
}
```
- ✅ **CORRECT (nested — mirrors catalog structure):**
```fsl
output {
    mapSource {
        record body {
            byte[] bytes;
        };
    }
    mapTarget {
        byte[] bytes;
    }
    copy body/bytes -> bytes;
}
```
- ✅ **CORRECT (generic catalog output kept generic):**
```fsl
output {
    mapSource {
        record document;
    }
    mapTarget {
        record document;
    }
    copy document -> document;
}
```
- **Protocol:** Before writing the `mapSource` of any `output {}` block: (1) open the catalog entry, (2) read `output_parameters[].name` verbatim, (3) trace the full parent path for every field you intend to map. If it is a child of a Document output parameter, declare the parent `record` in `mapSource` and use slash-path notation in the `copy` statement. If the catalog stops at the parent `Document`, your declaration must also stop at the parent `Document` unless the prompt or another explicitly referenced file provides the child structure.
- **Negative example — wrong output name hallucination:**
```fsl
// pub.string:concat catalog output_parameters: [ { "name": "value", "type": "String" } ]
// The following is WRONG — "string" is not the output parameter name:
INVOKE pub.string:concat {
    output {
        mapSource {
            String `string`;        // ❌ HALLUCINATED — catalog says "value", not "string"
        }
        mapTarget {
            String result;
        }
        copy `string` -> result;    // ❌ HALLUCINATED
    }
}
// The following is CORRECT:
INVOKE pub.string:concat {
    output {
        mapSource {
            String `value`;         // ✅ Exact name from catalog output_parameters
        }
        mapTarget {
            String result;
        }
        copy `value` -> result;     // ✅ Correct
    }
}
```

## 13. **TRANSFORMERS vs. INVOKE (FSL SCOPING)**:
- **TRANSFORM SCOPE**: Use `TRANSFORM` ONLY within a `MAP` block or as a standalone mapping operation.
- **INVOKE SCOPE**: Standard service calls use `INVOKE`. 
- **STRICT PROHIBITION**: Do NOT use the `TRANSFORM` keyword inside an `INVOKE` block.
## 14. **PIPELINE VARIABLE & CONDITION SYNTAX (CRITICAL)**:
- **MANDATORY PARENTHESES**: Conditions for `IF`, `WHILE`, and `UNTIL` **MUST** be enclosed in `()`.
- **PERCENT SYNTAX (CONDITIONS)**: Variables within `IF`, `WHILE`, and `UNTIL` conditions **MUST ALWAYS** be wrapped in `%` symbols.
    - **CORRECT**: `WHILE (%Y% < 20)`, `IF (%status% == "NEW")`, `UNTIL (%X% > 10)`
    - **INCORRECT**: `WHILE (Y < 20)`, `IF (status == "NEW")`, `UNTIL (X > 10)`
    - **Rule applies to**: ALL variables in conditions, including:
        - Pipeline variables (e.g., `%orderId%`, `%status%`)
        - System/internal variables (e.g., `%$iterationCount%`, `%$retries%`)
        - Field references (e.g., `%item/price%`)
- **SYSTEM VARIABLES**: Internal loop variables like `$iterationCount` and `$retries` MUST also be wrapped in `%` when used in conditions
    - **CORRECT**: `IF (%$iterationCount% == 3)`, `IF (%$retries% > 2)`
    - **INCORRECT**: `IF ($iterationCount == 3)`, `IF ($retries > 2)`
- **PERCENT SYNTAX (LABELS)**: Variables within `label` attributes **MUST** be wrapped in `%` to ensure proper evaluation against values (e.g., `label: "%var% == $null"`).
- **NULL HANDLING**: Always use the explicit keyword `$null` (no quotes) for existence checks in both conditions and labels.
## 15. **FLOW CONTROL**:
- **IF / ELSEIF / ELSE**: Condition wrapped in `()`. Chain ends with `;`.
- **BRANCH**:
    - Use `switch: "/path"` when branching on a variable
    - Use `evaluateLabels: true` when labels contain expressions (e.g., `%var% == value`)
    - Use `evaluateLabels: false` when labels are literal values
    - **Always include both properties when specified in requirements**
    - **NATURAL LANGUAGE INTERPRETATION**:
        - "evaluates labels" / "evaluate labels" → `evaluateLabels: true`
        - "does not evaluate labels" / "without evaluating labels" → `evaluateLabels: false`
        - If not mentioned at all → omit the property
- **SWITCH**:
    - Syntax: `SWITCH (variableName) { CASE "value" : ... CASE "$default" : ... }`
    - The switch expression uses a **bare variable name** — NO percent signs, NO quotes, NO path notation.
        - **CORRECT**: `SWITCH (operation)`, `SWITCH (orderStatus)`
        - **INCORRECT**: `SWITCH (%operation%)`, `SWITCH ("/operation")`, `SWITCH ("operation")`
    - Each `CASE` arm owns exactly **one direct child step**. When multiple steps are needed, wrap them in a `SEQUENCE` block.
        - **CORRECT**: `CASE "add" : SEQUENCE { INVOKE ... INVOKE ... }`
        - **INCORRECT**: `CASE "add" : INVOKE ... INVOKE ...` (only first step belongs to the case)
    - Use `CASE "$default" :` for the fallback arm.
    - Do NOT confuse with `BRANCH`: `BRANCH` uses `switch: "/path"` (path string) and `SEQUENCE { label: "value" }`. `SWITCH` uses a bare variable name and `CASE "value" :`.
    - 🚨 **`CASE` IS FORBIDDEN INSIDE `BRANCH`**: The `CASE` keyword is exclusively a `SWITCH` construct. It does NOT exist in the `BRANCH` grammar. Writing `BRANCH { CASE "..." { } }` will produce an immediate FSL compilation error (`mismatched input 'CASE'`). See Rule 20 for the correct `BRANCH` routing pattern.
- **LOOP**: Must include `inputArray: "/path"`.
- **REPEAT**: Requires `count` and `repeatOn` properties.
- **SEQUENCE**: Use `exitOn` to control flow termination (e.g., `"SUCCESS"` or `"FAILURE"` depending on requirement).
## 16. **NO PLACEHOLDERS & LEAN EXECUTION**:
- **STRICT PROHIBITION**: Do NOT insert "dummy" steps.
- **EMPTY CONTAINERS**: Omit if no logic is present.
## 17. **NO AUTOMATIC INITIALIZATION**:
- Do NOT insert `MAP` blocks at the start of loops unless requested.
## 18. **NO HYBRID STEPS**:
- An `INVOKE` block MUST NOT contain a `TRANSFORM` keyword. Use a separate `MAP { TRANSFORM ... }` block before.
## 19.  **ADVANCED BRANCHING**:
- All properties and child steps MUST be inside the same single set of curly braces.
## 20. **LABELING ATTRIBUTES**:
- **🚨 `CASE` IS FORBIDDEN INSIDE `BRANCH` (COMPILATION FAILURE)**: The grammar has NO `CASE` keyword inside a `BRANCH` block. Using `CASE` inside `BRANCH` causes an immediate FSL compilation error: `mismatched input 'CASE'`. This is one of the most common authoring mistakes — do NOT do it.
    - ❌ **FORBIDDEN**:
      ```fsl
      BRANCH {
          CASE "%statusCode% = 404" {
              EXIT { ... }
          }
      }
      ```
    - ✅ **MANDATORY — use `IF / ELSEIF / ELSE` for expression-based conditions**:
      ```fsl
      IF (statusCode == "404") {
          EXIT { ... }
      }
      ELSEIF (statusCode != "200") {
          EXIT { ... }
      }
      ```
    - ✅ **MANDATORY — use `BRANCH` with `SEQUENCE { label: "..." }` only for value-matching on a known variable**:
      ```fsl
      BRANCH {
          switch: "/statusCode"
          evaluateLabels: false
          SEQUENCE {
              label: "404"
              EXIT { ... }
          }
          SEQUENCE {
              label: "$default"
              EXIT { ... }
          }
      }
      ```
- **Routing is defined by the `label` attribute** on child `SEQUENCE` steps, not by `CASE`.
- **MATCH TYPES**: Literal strings, `$default`, `$null`, or expressions (when `evaluateLabels: true`).
- **DECISION GUIDE — when to use which construct**:

  | Need | Use |
  |---|---|
  | Conditional logic based on expressions / comparisons | `IF / ELSEIF / ELSE` |
  | Route on a fixed set of known literal values | `BRANCH` with `SEQUENCE { label: "..." }` |
  | Route on a variable with `CASE`-style arms | `SWITCH (variable) { CASE "value" : ... }` |
## 21. **LOOP CONTROL & EXIT (BREAK / CONTINUE / EXIT)**:
- **BREAK / CONTINUE**: Use the standalone keywords `BREAK` or `CONTINUE`.
    - **🚨 BREAK/CONTINUE SCOPE RESTRICTION (CRITICAL)**: `BREAK` and `CONTINUE` are ONLY valid inside `DO` and `WHILE` loops. They are strictly FORBIDDEN inside a `LOOP` block. Placing `BREAK` inside a `LOOP` will cause a runtime error: *"BREAK statement is not allowed outside of DO or WHILE loops"*.
    - **✅ Early Exit from LOOP**: To exit a `LOOP` block early (e.g., when a match is found), use `EXIT { exitFrom: "$parent" }` inside the `LOOP` body. This exits the enclosing `LOOP` container without requiring `BREAK`.
    - **Decision Table**:

| Loop Type | Early Exit Mechanism |
|---|---|
| `LOOP` | `EXIT { exitFrom: "$parent" }` |
| `WHILE` | `BREAK` |
| `DO...UNTIL` | `BREAK` |

- **EXIT**: Use the `EXIT` keyword followed by a property block `{}`.
    - **Mandatory**: `exitFrom: "$scope"` (Scopes: `$flow`, `$parent`, `$loop`).
    - **Optional**: `signal: "SUCCESS" | "FAILURE"` (Only include if an explicit exit signal is required by the logic).
    - **Constraint**: You MUST use `exitFrom` (not `from`). No semicolon after the EXIT closing brace.
- **🚨 CONDITION VARIABLE SYNTAX IN LOOP (CRITICAL)**: Inside a `LOOP` body, the current iteration record fields (e.g., `customers/customerName`) CANNOT be used directly inside `IF` or `WHILE` conditions wrapped in `%…%`. The `SUBSTITUTION_VAR` lexer token only matches simple alphanumeric identifiers — slash-path expressions like `%customers/customerName%` are NOT valid and will cause a parse error: *"unexpected token '%'"*.
    - **❌ FORBIDDEN**: `IF (%customers/customerName% == %customerName%)`
    - **✅ MANDATORY PATTERN**: Extract the nested field into a flat pipeline variable using a `MAP` block FIRST, then use the flat variable in the condition:
```fsl
MAP {
    mapSource {
        recordList customers {
            String customerName;
        };
    }
    mapTarget {
        String currentName;
    }
    copy customers/customerName -> currentName;
}
IF (%currentName% == %customerName%) {
    ...
}
```
## 22. **DO-UNTIL BLOCKS**:
- **Structure**: `DO { ... } UNTIL (condition) { comment: "text"; }`
- **Properties**: Inside the `DO` block, you may define properties such as `maxIteration`. 
- **Constraint (Braces)**: The `DO` block body is contained within a single set of `{}`. Do **not** split properties and logic into separate braces.
- **Constraint (Semicolons)**: 
    - The closing brace `}` of the `DO` block **MUST NOT** be followed by a semicolon.
- **Condition**: The `UNTIL` condition **MUST** be parenthesized and follow the `DO` block body.
## 23. **WHILE BLOCKS**:
- **Syntax**: `WHILE (%variable% condition %variable% | value) { [Steps]; }`
- **Constraint (Semicolons)**: Every `WHILE` block MUST NOT end with a semicolon `;` after the closing brace.
- **Condition**: 
    - The condition MUST be parenthesized.
    - Variables within the condition MUST be wrapped in `%` (per Rule 14).
    - The `WHILE` loop body is contained within a single set of `{}`.
## 24. **SEQUENCE BLOCKS**:
- **Syntax**: `SEQUENCE { [exitOn: "SUCCESS" | "FAILURE" | "DONE";] logic; }`
- **Attributes**: `exitOn` is optional. Include it only if you need to override the default behavior or if explicit exit logic is required.
## 25. **REPEAT BLOCKS (RETRY LOGIC)**:
- **Syntax**: `REPEAT { count: "5"; repeatOn: "FAILURE"; repeatInterval: "10"; logic; }`
- **Constraint**: Use `repeatInterval`, NOT `retryInterval`. The step MUST end with a `;`.
## 26. **INLINE INDEXING RULES (CRITICAL)**:
- **Syntax:** Indices are defined directly within the variable reference using square brackets `[]` following the variable name.
- **Format:** `variable[index]`
- **Supported Index Types:**
    - **Literal Index:** `items[0]`
    - **Variable Index:** `items[i]`
    - **System Variable Index:** `items[$retries]`
- **STRICT PROHIBITION 1 (Attributes):** Do NOT use external index properties (e.g., `fromRowIndex`, `toRowIndex`). These are no longer supported in the grammar and must be replaced by inline syntax.
- **STRICT PROHIBITION 2 (Formatting):** Do NOT use percent signs `%` inside these brackets.
## 27. **FINAL SYNTAX CHECK**:
- **NO Block Semicolons**: ALL block structures (`MAP`, `INVOKE`, `IF`, `BRANCH`, `SEQUENCE`, `LOOP`, `REPEAT`, `WHILE`, `DO`, `TRY`, `CATCH`, `FINALLY`, `EXIT`, `TRANSFORM`) MUST **NOT** have a semicolon `;` after their closing brace `}`.
- **Statement Semicolons**: Individual statements inside blocks (`set`, `copy`) MUST be terminated with a semicolon `;`.
- **Property Syntax**: All property definitions inside `{}` MUST use a colon `:` but do NOT end with semicolons (e.g., `maxIteration: 50` NOT `maxIteration: 50;`).
- **Loop Control**: `BREAK` does not require a semicolon. `CONTINUE` can optionally have one.
## 28. **TRY-CATCH-FINALLY (BLOCK UNIT RULES)**:
- **SIBLING HIERARCHY**: `TRY`, `CATCH`, and `FINALLY` are peer-level siblings.
- **MANDATORY CHAINING**: A `TRY` block must be immediately followed by `CATCH`, `FINALLY`, or both.
- **NO SEMICOLONS**: Do NOT place semicolons after ANY of the blocks in the chain (`TRY`, `CATCH`, or `FINALLY`).
    - Example: `TRY { ... } CATCH { ... } FINALLY { ... }`
    - Restriction: No semicolons after any block closing braces.
## 29. **ADVANCED BRANCHING (BRANCH)**:
- **SINGLE BLOCK**: All properties and all child steps MUST reside inside **one** single set of curly braces `{}`.
- **SYNTAX**: `switch` and `evaluateLabels` are **optional** properties.
    - **Include when**: Explicitly mentioned in requirements (including negative statements like "does not evaluate")
    - **Omit when**: Not mentioned at all in requirements
    - **Key phrases to watch for**:
        - "switches on [variable]" → include `switch: "/variable"`
        - "evaluates labels" → include `evaluateLabels: true`
        - "does not evaluate labels" → include `evaluateLabels: false`
        - No mention of switching or evaluating → omit both properties
- **LABEL FORMATTING**:
    - Use `%var%` ONLY inside `label` string literals (e.g., `label: "%total% > 100";`).
    - **ALWAYST** quote `$default`, (e.g.: `"$default"`).
    - **DO NOT** quote `$null` when used in a condition (e.g., `label: "%total% == $null";`).
    - **DO** quote `$null` when not used in a condition (e.g.: `"$null"`).
## 30. **RESERVED KEYWORDS ($null and $default)**:
- **NULL HANDLING**: Use `$null` for "no value" or "empty" checks.
- **DEFAULT HANDLING**: Use `$default` for "otherwise" or "else" cases in a `BRANCH`.
- ** QUOTES**: Always wrap `$default` in quotes when it is the only word in the label.
- ** QUOTES**: Always wrap `$null` in quotes when it is the only word in the label.
- **NO QUOTES**: When used in a label within a condition, **DO NOT** wrap `$null` in quotes.
## 31. **EXIT STEPS**:
- **SYNTAX**: `EXIT { exitFrom: "$scope" [signal: "SUCCESS" | "FAILURE"] }`
- **EXIT SCOPE**: Use `$flow` (service level) or `$parent` (container level).
- **STRICT PROHIBITION**: Do NOT use `EXIT` for loop control. Use `BREAK` or `CONTINUE`.
- **Note**: The `signal` property is optional. Only include it if an explicit termination signal (SUCCESS/FAILURE) is required by the business logic.
## 32. **LIST/ARRAY DETECTION**:
- **1D LISTS**: Use `[]` (e.g., `Integer[] prices;`).
- **DOCUMENT LISTS**: Always use the `recordList` keyword.
- **2D TABLES**: Permitted ONLY for `String[][]`.
- **LIST LITERALS**: Use `set myList = ["A", "B"];`.
- **🚨 FORBIDDEN — `record[]` syntax**: The FSL grammar's `recordDeclaration` rule only accepts the keywords `record` or `recordList`. The `[]` array suffix (`ARRAY_SUFFIX` token) is exclusively valid on scalar `fieldDeclaration` types (e.g., `String[]`, `Integer[]`). Writing `record[] fieldName;` causes an `unexpected token '[]'` parse error.
    - ❌ **FORBIDDEN**: `record[] current_condition;`
    - ✅ **MANDATORY**: `recordList current_condition;`
## 33. **PROPERTY BLOCK RULES**:
- Every attribute/property inside a `{}` block MUST follow the format `key: value;`.
- Block closing braces `}` must NOT be followed by semicolons.
## 34. **DYNAMIC SERVICE DISCOVERY AND MAPPING RULES**: When translating natural language mathematical or functional intents into FSL execution logic, you must adhere to the following routing and syntax construction rules:
- Intent-Based Service Routing
    - **Rule:** When a prompt describes a functional operation abstractly (e.g., "raise a base to a power", "divide X by Y", "round a number"), dynamically search the provided catalog files to find the service whose name or description matches that intent. 
    - **Important**: There may be one or more services that perform similar functions but operate with different data types. For example, if a prompt requests that you multiply 2 numbers of String data types, then you can choose from `pub.math:multiplyInts` and pub.math:multiplyFloats. The one you choose will depend on the types of numbers they are providing as inputs to the service.  If you are requested to multiply 2 numbers of Double or Integer or Float data types, then you should choose `pub.math:multiplyObjects` since this operates on Object types other than String as inputs.
    - **Example:** The phrase "raise `baseValue` to the power of `totalMonths`" must dynamically resolve to the matching service signature found in your catalog (e.g., `Loans:raiseToPower`).
- Structural Flow Selection (INVOKE vs. TRANSFORM MAP)
    - **Rule 1 (Top-Level Invocations):** If the prompt explicitly separates steps into independent sequential pipeline operations (e.g., "Step 1: Invoke X. Step 2: Invoke Y."), use a standalone, top-level `INVOKE [ServiceName] { ... }` block.
    - **Rule 2 (Inline Mappings & Transformers):** If the prompt describes a series of localized variable calculations or math formulas within a `MAP` context (e.g., "Execute the following inline variable transformations sequentially inside individual `MAP` blocks..."), you must wrap the discovered catalog service inside a `TRANSFORM` instruction block nested within a parent `MAP` block.
    - **Syntax Format:**
```fsl
MAP {
        comment: "Functional Intent Context"
        TRANSFORM [DiscoveredCatalogServiceName] {
            input {
                mapSource {
                    [PipelineType] [UserVariable];
                }
                mapTarget {
                    [ParameterType] [CatalogParameterName];
                }
                copy `[UserVariable]` -> `[CatalogParameterName]`;
            }
            output {
                mapSource {
                    [ParameterType] [CatalogParameterName];
                }
                mapTarget {
                    [PipelineType] [UserVariable];
                }
                copy `[CatalogParameterName]` -> `[UserVariable]`;
            }
        }
    }
```

- Parameter Variable Stitching
- **Rule:** Once a service is discovered, do not reuse the user's natural language variable names inside the service's direct parameter maps. You must map the user's variables onto the strict `input_parameters` and `output_parameters` names defined in that service's catalog JSON block using `copy` instructions.

## 35. **PIPELINE VARIABLE MANAGEMENT VIA THE DROP KEYWORD**: The `drop` statement is used to remove transient or obsolete variables from the pipeline to maintain optimal memory and pipeline cleanliness.
### 🚨 ZERO-DROP DEFAULT (ABSOLUTE PROHIBITION — READ THIS FIRST)
- **You MUST NOT generate any `drop` statement unless the user prompt EXPLICITLY names the variable to be dropped.** This is a hard, non-negotiable constraint that overrides all other guidance in this section.
- **Stale pipeline variables are NOT a problem to solve.** Do not treat the presence of a catalog service's native output (e.g., `value`, `string`, `document`, `valueList`, `toList`) in the pipeline as something requiring cleanup. Leave it there unless the user says otherwise.
- **"Good housekeeping" is not a valid reason to drop.** The `COPY DOES NOT DROP` note below is informational only — it does NOT authorize spontaneous drop generation.
- **No implicit drops, ever.** Do not infer that because a variable was copied, the original should be removed. Do not add drops because an example shows them. Do not add drops because they "seem right" for pipeline cleanliness.
- ❌ **FORBIDDEN:** Generating `drop` statements based on judgment, best practice, or pattern-matching from examples.
- ✅ **PERMITTED:** Generating `drop` statements only when the prompt contains an explicit instruction such as "drop X", "remove X from the pipeline", or "clean up X".
---
- Core Drop Statement Syntax Rules
    - **Syntax Rule:** The statement follows the pattern `drop \`[variableName]\`;` terminated strictly with a semicolon.
    - **Semicolon Rule:** Because `drop` is a standalone statement (and not a block structure or a control step property), a trailing semicolon is **MANDATORY**.
    - **Block-Level Scoping:** A `drop` action can occur in two distinct context wrappers:
              1. **Inside an INVOKE or TRANSFORM output block:** Used to instantly drop a service's raw native output parameter right after mapping it onto a persistent user pipeline variable.
              2. **Inside a Simple MAP block:** Used to sweep and clear multiple stale intermediate pipeline fields simultaneously.
- Context Pattern Examples
    - Context 1: Dropping Native Outputs inside INVOKE / TRANSFORM
When the user explicitly requests a drop inside an operational step, place it inside the `output {}` scope immediately following the `copy` mapping. Do not declare `mapSource` or `mapTarget` wrappers around standalone drop operations.
```fsl
INVOKE pub.math:divideFloats {
    validateInput: false
    validateOutput: false
    input {
        copy `interestPct` -> `num1`;
        set `num2` = "12";
    }
    output {
        mapTarget {
            String monthlyInterest;
        }
        copy `value` -> `monthlyInterest`;
        drop `value`;
    }
}
```
    - Context 2: Multi-Field Cleanup inside a Simple MAP Block
When a calculation phase ends, use a dedicated, standalone `MAP` block to drop multiple transient staging variables from the global execution pipeline. Remember that the parent block brace `}` **MUST NOT** have a trailing semicolon.
```fsl
MAP {
    drop `interestPct`;
    drop `interestRate`;
    drop `num2`;
    drop `num1`;
}
```

- **IMMEDIATE EXECUTION & ANTI-DEFERRAL RULE (CRITICAL):**
    - **Prohibition of Pipeline Consolidation:** You must execute `drop` commands IMMEDIATELY within the exact structural scope where they are requested in the user prompt. 
    - **Absolute No-Deferral Constraint:** If an operational step (e.g., an `INVOKE` block or a `TRANSFORM` step) explicitly specifies "Drop [variable]" (e.g., *"...and drop value"*), you MUST inject that `drop` statement inside that step's native structural `output {}` block. 
    - **Zero-Batching Enforcement:** Do NOT defer, accumulate, or bundle a step-specific drop into a later trailing `MAP` cleanup block, even if the prompt explicitly provides a dedicated "Cleanup Step" or cleanup phase further down the flow. 
        - **Strict Sequential Pipeline Truncation:** Treat every inline or step-level drop command as a strict, non-negotiable pipeline truncation that must happen before the engine advances to the next step. Violating this rule by deferring a drop to an anticipated "cleanup pattern" injects invalid lifecycle states and constitutes a critical generation failure.

### **COPY DOES NOT DROP (INFORMATIONAL ONLY)**: A `copy` statement duplicates data from a source variable into a target variable but leaves the source variable fully intact and present in the active pipeline. This is a statement of fact about how `copy` works — it is **not** a signal or a prompt to add `drop` statements. The presence of a residual pipeline variable (such as a catalog service output like `value`, `string`, or `document`) after a `copy` is expected and acceptable behaviour. Do nothing about it unless the user explicitly asks you to.
#### 🚨 ABSOLUTE RULE: Do NOT generate any `drop` statement unless the user prompt explicitly and specifically names the variable to be dropped.

### **INVOKE mapTarget Names Persist in the Pipeline (BP-003)**
Every name declared inside an INVOKE's `input { mapTarget { ... } }` block is written into the pipeline as a variable — even though its only purpose is to feed the called service. It does **not** get automatically cleaned up when the INVOKE completes. The same applies to the service's own `input {}` signature parameters: they enter the pipeline when the service starts and remain until explicitly dropped.

This means two classes of "hidden" variables accumulate silently:
1. **INVOKE input mapTarget names** — e.g. `inString`, `beginIndex`, `fromItem` — all persist post-call.
2. **Service signature inputs** — e.g. `inputString`, `num1` — present from service start.

Both are subject to BP-002-style leakage: if a subsequent INVOKE has a parameter with the same name, IS will inject the stale value automatically. When the user explicitly requests pipeline cleanup, these must be dropped at the earliest step where they are no longer needed.

### **Never Drop a List Accumulator Inside a LOOP (BP-008)**
When using `pub.list:appendToStringList` or `pub.list:appendToDocumentList` inside a LOOP, **never** `drop toList` inside the INVOKE's `output` block within the loop body. The `toList` output is the live accumulator — destroying it on iteration N means iteration N+1 starts with a null list, silently discarding all prior entries. Only the last appended item (or nothing) will survive.

✅ Let `toList` persist throughout the entire LOOP. Drop it in a cleanup MAP **outside and after** the loop only if the user explicitly requests it.

```fsl
LOOP {
    inputArray: "/rowList"
    INVOKE pub.list:appendToStringList {
        input { ... }
        output {
            mapSource { String[] toList; }
            mapTarget { String[] accumulator; }
            copy toList -> accumulator;
            // ❌ NEVER drop toList here — it is the accumulator for the next iteration
        }
    }
}
// ✅ Safe to drop here, after the loop has finished (only if explicitly requested)
MAP {
    drop toList;
}
```

## 36. **`set (variable)` — RUNTIME SUBSTITUTION ASSIGNMENT (CRITICAL PATTERN)**:
- **Purpose**: Extracts values from deeply nested documents and arrays (including JSON API responses) without using LOOP blocks. Integration Server evaluates the substitution string at runtime using its own pipeline variable engine, which supports full slash-path navigation and array index notation.
- **Grammar**: `SET setAttributes? target=variableRef EQUALS assignedVal=value SEMI` where `setAttributes` is `LPAR setAttribute RPAR` and `setAttribute` includes the `variable` keyword token.
- **Syntax**:
    ```fsl
    set (variable) targetVar = "%sourcePath[index]/nestedField%";
    ```
- **When to use**: When the source data is a document returned from a service (e.g., `pub.json:jsonStringToDocument`) that contains nested arrays, and you need to extract a specific element by index without iterating.
- **`mapSource` declaration**: Declare the top-level document as a `record` and its array child as a `recordList` (empty — no child field declarations needed). The substitution engine resolves the full path at runtime.
    ```fsl
    mapSource {
        record weatherDoc {
            recordList current_condition;
        };
    }
    ```
- **Substitution string rules**:
    - The entire path expression is enclosed in `%...%` inside a quoted string literal.
    - Array indexing uses `[n]` directly inside the substitution string (e.g., `current_condition[0]`).
    - Slash `/` navigates into nested document fields (e.g., `weatherDesc[0]/value`).
    - **DO NOT** use `%varName%` (the FSL lexer's `SUBSTITUTION_VAR` token) directly as the `set` value — that token only matches simple alphanumeric identifiers and will NOT resolve path expressions. Always use `set (variable)` with the full path in a string literal when array indexing or path navigation is required.
- **Complete example** (extracting from a JSON API response where `weatherDoc` contains `current_condition[]` → `weatherDesc[]` → `value`):
    ```fsl
    MAP {
        comment: "Extract weather data"
        mapSource {
            record weatherDoc {
                recordList current_condition;
            };
        }
        mapTarget {
            String temperature;
            String weatherDescription;
        }
        set (variable) temperature = "%weatherDoc/current_condition[0]/temp_C%";
        set (variable) weatherDescription = "%weatherDoc/current_condition[0]/weatherDesc[0]/value%";
    }
    ```
- **🚨 DO NOT confuse with plain `set`**: A plain `set target = "%varName%"` assigns the literal string `"%varName%"` — it does NOT perform substitution. Only `set (variable)` triggers runtime evaluation of the `%...%` expression.
- **Available `setAttribute` modifiers** (grammar-defined, combinable with comma separation):
    - `variable` — evaluates the RHS as a runtime pipeline substitution expression.
    - `overwrite` / `not overwrite` — controls whether an existing pipeline value is replaced.
    - `globalvariables` — targets global (cross-service) variables instead of pipeline-local ones.

