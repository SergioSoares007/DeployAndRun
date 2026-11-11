# 1. QUICK SYNTAX REFERENCE (STRICT COMPLIANCE)
## 1.1 CORRECT VS. FORBIDDEN SYNTAX
| ✅ CORRECT FSL SYNTAX | ❌ FORBIDDEN (The LLM habit you must break) | Why the LLM fails / What to do instead |
| :--- | :--- | :--- |
| `interface folderName {}` | `FLOW ServiceName` / `ENDFLOW` | FSL does not use `FLOW`. File headers must use `interface`. |
| `service serviceName (input {} output {}) {}` | `SIGNATURE`, `INPUT`, `OUTPUT`, `BODY` | **CRITICAL:** FSL service signatures use parentheses `()` containing lower-case `input` and `output` blocks. |
| `INVOKE path { input {} output {} }` | `ENDINVOKE`, `ENDMAP`, `MAP ... ENDMAP` | FSL uses block curly braces `{}` exclusively for boundaries. Never append `END` to a keyword. |
| `mapSource` / `mapTarget` | `MAPSOURCE`, `MAPFROM` / `MAPTO`, `MAPDESTINATION` | Data structures inside MAP steps are strictly case-sensitive. |
| `copy source -> target;` | `SET source -> target;` | `copy` is exclusively for variable-to-variable assignments using `->`. |
| `set target = "value";` | `SET "value" -> target;` | `set` is exclusively for hardcoded literals using `=`. |
| `set (variable) target = "%doc/array[0]/field%";` | `set target = "%doc/array[0]/field%";` | **CRITICAL:** A plain `set` assigns the literal string — the `%...%` is NOT evaluated. Only `set (variable)` triggers IS runtime substitution, enabling slash-path navigation and `[n]` array indexing inside the quoted string. Use this pattern to extract values from nested JSON documents without a LOOP. |
| `recordList current_condition;` | `record[] current_condition;` | **CRITICAL:** The `[]` array suffix only applies to scalar `fieldDeclaration` types (e.g., `String[]`). The grammar's `recordDeclaration` rule only accepts `record` or `recordList` — `record[]` causes an `unexpected token '[]'` parse error. |
| `Byte[] bytes;` | `byte[] bytes;` / `byte[ ] bytes;` / `Byte[ ] bytes;` | **CRITICAL:** The FSL lexer token `BYTE_PRIMITIVE` (`'byte'`) is NOT a valid `dataType`. The grammar's `dataType` rule only accepts `BYTE_TYPE` (`'Byte'`, capital B). Lowercase `byte` and any form with a space before `[]` cause parse errors. Always use `Byte[]` (capital B, no space). Catalog entries showing `byte[ ]` must be translated to `Byte[]`. |

## 1.2 🚨 SYSTEM VARIABLE MAPPING GUARDRAIL
When a functional prompt or a bulleted checklist demands that you copy, read, or convert an implicit system tracking variable (any variable beginning with `$`, such as `$iterationCount`, `$retries`, or `$default`), you are strictly forbidden from writing a data-type variable declaration statement for it. 
* ❌ **FORBIDDEN Habit:** Writing `String $iterationCount;` or `Integer $retries;` inside a `mapSource` or `mapTarget` contract block.
* ✅ **MANDATORY Syntax:** Omit the system variable completely from the `mapSource` or `mapTarget` declarations. Map or reference the system identifier directly inside your operational statements (e.g., `copy $iterationCount -> localField;`).

## 1.3 🚨 Reserved Keywords Guardrail
If a pipeline variable or schema field name matches one of the 20 official FSL reserved keywords exactly, you MUST enclose that field identifier in backticks (`` ` ``) during declarations or standalone assignments:

```fsl
String `value`;
copy `value` -> target;
```

* **Allowed Reserved Keyword List:** `pattern`, `value`, `properties`, `type`, `service`, `interface`, `input`, `output`, `record`, `recordList`, `document`, `branch`, `sequence`, `loop`, `map`, `mapSource`, `mapTarget`, `copy`, `set`, `drop`.

🚨 **CRITICAL OVER-GENERALIZATION GUARDRAIL:** Do NOT place backticks around normal, custom, or user-defined variable names (e.g., `loanAmount`, `currentBalance`, `month`, `cumulativeInterest`). Doing so creates serious compilation errors. Backticks are exclusively an isolation mechanic for the explicit 20 reserved keywords listed above. If a variable is not on that list, backticks are strictly illegal.

* ❌ **FORBIDDEN Habit:** `copy \`loanAmount\` -> \`currentBalance\`;`
* ❌ **FORBIDDEN Habit:** `set \`month\` = "0";`
* ✅ **MANDATORY Syntax:** `copy loanAmount -> currentBalance;`
* ✅ **MANDATORY Syntax:** `set month = "0";`

## 1.4 Document Type Reference Syntax (Parentheses Guardrail)
* **Rule:** When a `record` or `recordList` references a structured reference asset schema, you must provide the asset namespace identifier directly inside parentheses `()` immediately following the field name.
* **CRITICAL:** Do NOT insert labels, keys, or colon-prefixes like `reference:` or `type:` inside the parentheses. Do NOT wrap the entire inner string in quotes. The value inside the parentheses must be a raw positional namespace identifier literal.
* ❌ **FORBIDDEN Habit:** `record Name (reference: "Folder:Asset") {`
* ✅ **MANDATORY Syntax:** `record Name (Folder:Asset) {`
---

# 2. COMMON LLM MISCONSTRUCTION PATTERNS (DO NOT DO)

### ❌ Flattened Declarations (WRONG)
```fsl
mapTarget { String message; String status; }
```
### ❌ Flattened Structural Layouts (WRONG)
```fsl
input { mapSource { String customerName; } }
```
### ❌ Missing Semicolons in Field Property Blocks (WRONG)
```fsl
service CalculateMonthlyInterestRate (
    input {
        String interestRate {
            allowNull: false   // ❌ CRITICAL COMPLIANCE FAILURE: Missing trailing semicolon
        }                      // ❌ CRITICAL COMPLIANCE FAILURE: Missing trailing semicolon
    }
)
```
### ✅ Mandatory Semicolons on Field Constraints (RIGHT)
```fsl
service CalculateMonthlyInterestRate (
    input {
        String interestRate {
            allowNull: false;  // ✓ Property/Attribute inside declaration requires a semicolon
        };                     // ✓ The property block closure itself requires a semicolon
    }
)
```
### ❌ Cross-Step Variable Re-use Without Local Structure (WRONG)
```fsl
// Even if AmortizationScheduleRow was declared earlier in the service...
output {
    mapSource {
        String `value`;
    }
    mapTarget {
        // ❌ CRITICAL COMPLIANCE FAILURE: Flattened slash paths are illegal in mapTarget blocks
        String AmortizationScheduleRow/paymentAmount; 
    }
    copy `value` -> AmortizationScheduleRow/paymentAmount;
}
```
### ✅ Localized Operation Schema Mapping Contracts (RIGHT)
```fsl
output {
    mapSource {
        String `value`;
    }
    mapTarget {
        // ✓ Mandatory: You MUST explicitly recreate the local block scope hierarchy 
        // for any nested target fields involved in this specific mapping contract.
        record AmortizationScheduleRow {
            String paymentAmount;
        };
    }
    copy `value` -> AmortizationScheduleRow/paymentAmount;
}
```
### 💡 LOCAL SCHEMA CONTRACT GUARDRAIL:
Inner `mapSource` and `mapTarget` blocks inside operational steps (`INVOKE`, `TRANSFORM`, `MAP`) do not care if a variable was declared globally or in a previous step. They are **local structural schema contracts** for that specific operation. You must always explicitly mirror the nested record or recordList hierarchy using curly braces `{}` inside the local block for any child leaves you intend to map, copy, or set.

By framing it as an **"Operational Contract"** rather than a "Variable Declaration," you flip the mental model the LLM uses, forcing it to explicitly build the nesting structures every time.

### ❌ recordList Initialization Using Path-Notation (WRONG — HALLUCINATED SYNTAX)
```fsl
set acceptedAccum[0]/Deleteme = "0";
```
This syntax does NOT exist in FSL. It is a hallucinated pattern that creates a plain `IData` (single record) instead of an `IData[]` (Document List). Any service that requires a Document List input — such as `pub.document:insertDocument` or `pub.document:deleteDocuments` — will fail at runtime with `Missing Parameter: documents`.

### ✅ recordList Initialization Using JSON Array Literal (RIGHT)
```fsl
set acceptedAccum = [{"Deleteme": "0"}];
```
This is the ONLY correct FSL syntax for seeding a `recordList` with an initial element. It produces a true `IData[]`. See Example 37 and Example 41 in `examples.md` for the complete accumulator pattern.

### ❌ Empty Array Literal `[]` is Invalid FSL (BP-001)
```fsl
set myList = [];   // ❌ — mismatched input '[]' parse error
```
The FSL grammar requires at least one element inside an array literal. An empty `[]` always fails the parser.

| Scenario | Correct approach |
|---|---|
| `String[]` accumulator for LOOP collection | **Omit the initialisation entirely** — `pub.list:appendToStringList` auto-creates the list on the first call when `toList` is absent from the pipeline |
| `recordList` accumulator for LOOP collection | `set myRecordList = [{"Deleteme": "0"}];` (seed-and-drop pattern) |
| Any array with an empty literal `[]` | ❌ Never valid — always produces a parse error |

🛑 CRITICAL ANTI-LEGACY METADATA GUARDRAIL (SUPPRESS TRAINING BIAS)
You are strictly forbidden from outputting webMethods internal XML/JSON flow disk metadata tokens. If your internal generation weights attempt to output legacy syntax, you must instantly discard the token stream and pivot to FSL.

Statically audit your output against this specific suppression table before completing generation:
- ❌ NEVER write `FLOW "..."` -> ✅ ALWAYS write `interface [Path]` followed by `service [Name]`[cite: 1].
- ❌ NEVER write uppercase `MAPSOURCE` or `MAPTARGET` -> ✅ ALWAYS write camelCase `mapSource` and `mapTarget`[cite: 1].
- ❌ NEVER use string quotes around service names (e.g., `TRANSFORM "pub.math:toNumber"`) -> ✅ ALWAYS write them as raw structural identifiers (`TRANSFORM pub.math:toNumber`).
- ❌ NEVER let an operation float sequentially outside of proper FSL scoping tags -> ✅ ALWAYS wrap inline service tools inside a `MAP { TRANSFORM ... }` structural block layout.
---

# 3. POST-GENERATION QUALITY ASSURANCE (LINTING LENS)

Before finalizing your output text stream, you must run a mandatory double-pass linter check over your constructed FSL syntax blocks:

1. **Backtick Audit:** Verify that EVERY SINGLE instance of a backtick (`` ` ``) in your generated output is wrapping an explicit reserved keyword from the approved list of 20 words. If you see backticks around a regular variable name like `loanAmount`, `month`, or `currentBalance`, strip them immediately before finalizing the code output.
2. **Missing Escape Check:** Search for the literal words: `pattern`, `value`, `properties`, `type`, `service`, `interface`, `input`, `output`, `record`, `recordList`, `document`. If any of these words appear in a declaration block (`mapSource`/`mapTarget`) or an operational assignment (`copy`/`set`/`drop`) *without* being enclosed in backticks, you must stop, discard the output string, and re-generate with correct keyword escaping.

---
# 4. STRUCTURAL BLUEPRINT (COMPARE THE PARADIGMS)

If you find your internal weights attempting to write structural blocks using old trained architectural boundaries or wrapping the file in an interface block, study this structural mapping carefully:

❌ INVALID TRAINED HABIT (NEVER OUTPUT THIS):
```fsl
FLOW MyService
SIGNATURE
  INPUT var1: String
BODY
  INVOKE pub.math:add
    MAP
      SET var1 -> num1
    ENDMAP
  ENDINVOKE
ENDFLOW
```
❌ INVALID INTERFACE BLOCK WRAPPING (NEVER COUPLING INTERFACE WITH BRACES):
```fsl
interface MyFolder {
    service MyService (
        input { String var1; }
    ) { ... }
}
```
✅ MANDATORY FLAT FSL ARCHITECTURE (ONLY OUTPUT THIS):
```fsl
interface MyFolder

service MyService (
    input {
        String var1;
    }
    output {}
)
{
    INVOKE pub.math:add {
        input {
            mapSource {
                String var1;
            }
            copy var1 -> num1;
        }
    }
}
```
✅ **MANDATORY HIERARCHICAL LAYOUT:**
```fsl
interface MyFolder

service MyService (
    input {
        String var1;
    }
    output {}
)
{
    INVOKE pub.math:add {
        input {
            mapSource {
                String var1;
            }
            copy var1 -> num1;
        }
    }
}
```

# 5. LOOP PATTERNS & EARLY EXIT GUARDRAILS

## 5.1 🚨 BREAK IS FORBIDDEN INSIDE LOOP (CRITICAL)

`BREAK` and `CONTINUE` are ONLY valid inside `DO` and `WHILE` loops. Using `BREAK` inside a `LOOP` block compiles but fails at runtime with:
> *"BREAK statement is not allowed outside of DO or WHILE loops"*

**To exit a `LOOP` early, you MUST use `EXIT { exitFrom: "$parent" }`.**

| Loop Type | Correct Early Exit |
|---|---|
| `LOOP` | `EXIT { exitFrom: "$parent" }` |
| `WHILE` | `BREAK` |
| `DO...UNTIL` | `BREAK` |

❌ **FORBIDDEN — BREAK inside LOOP:**
```fsl
LOOP {
    inputArray: "/customers"
    IF (%matched% == "true") {
        BREAK
    }
}
```

✅ **MANDATORY — EXIT $parent inside LOOP:**
```fsl
LOOP {
    inputArray: "/customers"
    IF (%matched% == "true") {
        EXIT {
            exitFrom: "$parent"
        }
    }
}
```

---

## 5.2 🚨 SLASH-PATH VARIABLES FORBIDDEN IN CONDITIONS (CRITICAL)

The FSL `SUBSTITUTION_VAR` lexer token (`%varName%`) only matches **simple alphanumeric identifiers**. Slash-delimited nested field paths (e.g., `customers/customerName`) are NOT valid inside `%…%` and will cause:
> *"unexpected token '%'"*

This affects ALL conditions: `IF`, `WHILE`, `UNTIL`.

❌ **FORBIDDEN — slash path inside condition:**
```fsl
IF (%customers/customerName% == %customerName%) {
```

✅ **MANDATORY PATTERN — extract to flat variable first:**

Before the `IF`, use a `MAP` block to copy the nested field into a simple pipeline variable, then compare the simple variables:

```fsl
LOOP {
    inputArray: "/customers"
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
        EXIT {
            exitFrom: "$parent"
        }
    }
}
```

---

## 5.3 🚨 ANTI-HALLUCINATION: NEVER INVENT SERVICE NAMES (CRITICAL)

Before generating ANY `INVOKE` or `TRANSFORM` step, you MUST verify the service name exists in the service catalog files under `service-catalogs/`. Inventing plausible-sounding service names (e.g., `pub.flow:getArraySize`, `pub.list:getSize`, `pub.flow:throwException`) that are not in the catalog is a critical compliance failure.

**Common temptation patterns to avoid:**

| ❌ Invented (NEVER USE) | ✅ Correct Catalog Service |
|---|---|
| `pub.flow:getArraySize` | `pub.list:sizeOfList` (input: `fromList`, output: `size`) |
| `pub.flow:throwException` | `EXIT { exitFrom: "$flow" signal: "FAILURE" failureMessage: "..." }` |
| `pub.flow:throwServiceException` | `EXIT { exitFrom: "$flow" signal: "FAILURE" failureMessage: "..." }` |

**Rule**: If you cannot find a service in the catalog that matches the intent, use the appropriate FSL control structure (`EXIT`, `BRANCH`, `IF`) instead of inventing a service name. Raising a service-level failure to the caller is always done via `EXIT { exitFrom: "$flow" signal: "FAILURE" failureMessage: "..." }` — not via an invented throw service.

---

## 5.4 LOOP SEARCH PATTERN (CANONICAL TEMPLATE)

When the requirement is to **search a recordList for a matching record**, always use this canonical pattern:

1. Initialize a `String matched = "false"` flag before the loop
2. Use `LOOP { inputArray: "/listName" }` for automatic iteration
3. Inside the loop, extract comparison fields to flat variables via `MAP` before the `IF`
4. On match: copy fields to output record, set `matched = "true"`, then `EXIT { exitFrom: "$parent" }`
5. After the loop: `IF (%matched% == "false")` → `EXIT { exitFrom: "$flow" signal: "FAILURE" failureMessage: "..." }`

```fsl
MAP {
    mapTarget {
        String matched;
    }
    set matched = "false";
}
LOOP {
    inputArray: "/items"
    MAP {
        mapSource {
            recordList items {
                String fieldToMatch;
            };
        }
        mapTarget {
            String currentValue;
        }
        copy items/fieldToMatch -> currentValue;
    }
    IF (%currentValue% == %searchKey%) {
        MAP {
            mapSource {
                recordList items {
                    String fieldToMatch;
                    String otherField;
                };
            }
            mapTarget {
                record result {
                    String fieldToMatch;
                    String otherField;
                };
            }
            copy items/fieldToMatch -> result/fieldToMatch;
            copy items/otherField -> result/otherField;
        }
        MAP {
            mapTarget {
                String matched;
            }
            set matched = "true";
        }
        EXIT {
            exitFrom: "$parent"
        }
    }
}
IF (%matched% == "false") {
    EXIT {
        exitFrom: "$flow"
        signal: "FAILURE"
        failureMessage: "No matching record found"
    }
}
```
