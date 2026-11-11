## 1. FILE STRUCTURE AND NAMING CONVENTION (CRITICAL)
- **Interface Declaration:** Every file MUST begin with an interface declaration. A semicolon after the interface is optional, but do not include one when generating FSL.
    - Format: `interface [FolderPath]`
    - Example: `interface FolderB.FolderB1`
    - **CRITICAL**: The interface declaration should ONLY contain the folder path within the package, NOT the package name itself.
    - **Correct**: `interface FolderB.FolderB1` (for a service in package "AITest" with folder path "FolderB.FolderB1")
    - **Incorrect**: `interface AITest.FolderB.FolderB1` (Do NOT include the package name)
- **Service Declaration:** Immediately following the interface, declare the service using only the service name.
    - Format: `service [ServiceName] (...)`
    - Example: `service processOrder (...)`
- **Restriction:** Do NOT include the package name or the folder path inside the `service` declaration line. The `service` line must only contain the service name identifier.
### 🚨 CONDITIONAL EXTRACTION: TOP-LEVEL SERVICE COMMENTS
When parsing an incoming service interface or metadata file, you may encounter an inline comment, purpose statement, documentation string, or description field explaining what the service does. 
* **Mapping Requirement:** If any description, purpose, or comment exists, you MUST capture it. You are required to assign this extracted narrative string directly into a top-level `comment` attribute located inside the final `properties { ... }` configuration block. 
* **Format Compliance:** Ensure it is wrapped in double quotes and correctly syntax-terminated with a semicolon.
  
  *Example Output Pattern:*
  ```fsl
  properties {
      comment: "Calculates the month-by-month repayment schedule of a loan based on the principal amount, interest rate, and loan length.";
  }

## 2. MAPPING AND ASSIGNMENT SYNTAX (CRITICAL)
- **COPY OPERATIONS (Variables):** MUST use the `->` operator.
    - Rule: `copy sourceVariable -> targetVariable;`
    - Example: `copy customerId -> orderId;`
- **SET OPERATIONS (Literals/Values):** MUST use the `set` keyword and `=` operator.
    - Rule: `set targetVariable = "value";`
    - Example: `set message = "customerId was not provided";`
- **COMPLEX TYPE INITIALIZATION (Record/RecordList):** Complex structural types must be initialized as single, unified literal block units. You are strictly forbidden from writing partial path trajectories using a slash (`/`) when assigning an initial literal value to a record structure or list array.
    * **Record Initialization:** Use an inline JSON object block: `set targetRecord = {"field": "value"};`
    * **RecordList Initialization:** Use an inline array containing an object literal: `set targetRecordList = [{"field": "value"}];`
    * **Example:** `set AmortizationScheduleAccum = [{"Deleteme": "0"}];`
    * **⚠️ LITERAL DISAMBIGUATION GUARDRAIL (Object vs. Array):** The *Prohibition of Object Literals* rules only forbid using naked curly braces to assign multiple fields to a standard *Record* at once (e.g., ❌ `set Record = {k: v}`). It **does not** prohibit initializing an entire array/recordList structure as a whole via array brackets `[...]`. When initializing a `recordList` with a default starting element, you **MUST** use the unified array syntax `set RecordList = [{"field": "value"}];`. 
    * **🚨 KEYWORD PROTECTION:** Do not place backticks around keys inside the array literal initialization (e.g., write `{"Deleteme": "0"}`) unless the field name matches an explicit FSL reserved keyword. Normal user fields like `Deleteme` or `paymentAmount` must remain regular strings.
### 🛑 PROHIBITION OF METADATA PROPERTIES IN INLINE ASSIGNMENTS
When assigning an inline literal value or initializing an array variable structure (such as `set AmortizationScheduleAccum = ...`), you are **strictly forbidden** from writing metadata property constraints, setting schema attributes, or using the double-brace syntax rules.
* **Scope Constraint:** The double-brace rule (`{ properties... } { structure... }`) is exclusively used for top-level static asset signatures. It must **NEVER** appear inside an inline variable assignment value or a mapping pipeline assignment block.
* **Prohibited Behavior:** Do not include structural attributes like `allowUnspecifiedFields: true;` inside localized array or record literal data payloads.

  *❌ Incorrect (Hallucinated properties and double braces):*
  set AmortizationScheduleAccum = [{allowUnspecifiedFields: true;} {Deleteme: "0"}];

  *❌ Incorrect (Mixing declaration syntax with data assignment):*
  recordList AmortizationScheduleAccum { allowUnspecifiedFields: true; } { record { String Deleteme; }; };

  *✅ Correct (Clean, flat JSON literal data array initialization):*
  set AmortizationScheduleAccum = [{"Deleteme": "0"}];
- **RESTRICTIONS:**
    - NEVER use `<-`.
    - NEVER use `set "value" -> targetVariable;`
    - NEVER use `targetVariable = "value";` (without the `set` keyword).
    - NEVER use slash-delimited sub-paths to initialize structural fields (e.g., ❌ `set AmortizationScheduleAccum/Deleteme = "0";`). You must target the base variable name and assign the entire structure via inline literals.
    - **CRITICAL IDENTIFIER RULES:** NEVER put double quotes (`"`) or single quotes (`'`) around service names or package namespace identifiers in `INVOKE` statements or `TRANSFORM` steps. Service pathways are explicit structural identifiers, not string literals.
        - **Correct:** `INVOKE Loans:CalculateMonthlyInterestRate`
        - **Correct:** `TRANSFORM pub.math:toNumber`
        - **Incorrect:** `INVOKE "Loans:CalculateMonthlyInterestRate"`
        - **Incorrect:** `TRANSFORM 'pub.math:toNumber'`
    - **NEVER `set` and `copy` the same `mapTarget` variable in the same block (BP-005):** IS processes statements in order. If a `set` runs before a `copy` on the same target variable, the `copy` will overwrite the set value — conversely, a `set` after a `copy` discards the copied value. Either way, only one assignment should be present for any given target variable in a single block.
        - If the value comes from the pipeline → use `copy` only.
        - If the value is a hardcoded literal → use `set` only.
        - ❌ **FORBIDDEN:** `set inString2 = ""; copy category -> inString2;` — the `copy` overwrites the `set`, making the `set` pointless, or vice versa.
- **RESERVED KEYWORD ESCAPING (BACKTICKS):**
    - **Rule:** The FSL parser grammar reserves specific functional tokens. If a pipeline variable or schema field name matches one of these reserved keywords exactly, you MUST enclose the field identifier in backticks (`` ` ``) when declaring it inside `mapSource` or `mapTarget` and when using it in mapping operations.
    - **Reserved Keyword List:** `pattern`, `value`, `properties`, `type`, `service`, `interface`, `input`, `output`, `record`, `recordList`, `document`, `branch`, `sequence`, `loop`, `map`, `mapSource`, `mapTarget`, `copy`, `set`, `drop`.
    - **Example 1 (Flat Scope):** If a standalone variable is named `pattern` or `value`:
      ```fsl
      mapSource {
          String `pattern`;
          String `value`;
      }
      ```
    - **Example 2 (Nested Field Keyword):** If a reserved keyword is a leaf field nested deeply inside a document hierarchy, only that specific field name gets enclosed in backticks; the non-reserved parent paths remain unescaped:
      ```fsl
      mapTarget {
          record DocumentA {
              record DocumentB {
                  String `pattern`; // Only the leaf keyword is backticked
              };
          };
      }
      set DocumentA/DocumentB/`pattern` = "###.##";
      ```
    - **Example 3 (Nested Record List Field Keyword):**
      ```fsl
      mapTarget {
          recordList AmortizationScheduleAccum {
              String `value`; // Mandatory backticks to protect the pipeline variable name
          };
      }
      copy transientAmount -> AmortizationScheduleAccum/`value`;
      ```
    - **Example 4 (Nested Parent Document Keyword):** If an intermediate structural parent document or record is the reserved keyword (e.g., `DocumentA/pattern/FieldA`), you must backtick that specific parent record declaration in the block schema and use backticks on that specific structural segment in your operational pathing:
      ```fsl
      mapTarget {
          record DocumentA {
              record `pattern` {    // Backticks required on the parent keyword block
                  String FieldA;    // Leaf node is regular text
              };
          };
      }
      set DocumentA/`pattern`/FieldA = "Sample Value";
      ```
- **Example 5 (Multi-Keyword Configuration Block):** If a service utilizes multiple distinct keywords from the reserved list (such as `pattern` for a date/number format and `type` for metadata), each keyword must be independently wrapped in backticks:
      ```fsl
      input {
          mapSource { 
              String fixedMonthlyPayment; 
          }
          mapTarget { 
              String num; 
              String `pattern`; // Escaped keyword
              String `type`;    // Escaped keyword
          }
          copy fixedMonthlyPayment -> num;
          set `pattern` = "$#,##0.00";
          set `type` = "CURRENCY";
      }
      ```
### 🛑 CRITICAL: NO FLAT/SLASHED PATHS IN NESTED TRANSFORM BLOCKS
When instructions state to avoid flat, slashed path declarations inside `mapTarget` or `mapSource` blocks, this rule applies **universally and recursively** to all scopes.
* **Scope Obligation:** You must apply this nested block structure to the main `MAP` block **AND to every single nested `TRANSFORM` block** contained within that step.
* **Prohibited Behavior:** Do not revert to flat slash paths (e.g., `AmortizationScheduleRow/paymentNumber`) inside a child `TRANSFORM`'s target or source mapping blocks. Every block container inside a `TRANSFORM` must explicitly open its own matching curly-brace structural layout block.

  *❌ Incorrect (Flat fall-back inside TRANSFORM):*
  TRANSFORM {
      mapTarget {
          // BUG: Reverting to flat path inside nested context
          String AmortizationScheduleRow/paymentNumber; 
      }
  }

  *✅ Correct (Consistent structural layout):*
  TRANSFORM {
      mapTarget {
          record AmortizationScheduleRow {
              String paymentNumber;
          };
      }
  }

## 3. STATEMENT AND BLOCK TERMINATION RULES (UPDATED)

FSL uses a strict, block-delimited structure where the precise placement or omission of semicolons (`;`) governs structural syntax validity. You must adhere to the following absolute rules:

### A. STATEMENTS REQUIRING A TERMINATING SEMICOLON (`;`)
Place a semicolon strictly at the end of isolated inline actions, structural declarations, and standalone operational mappings:
- **Variable Assignments & Pipeline Mappings:** Every `set` and `copy` statement must be terminated with a semicolon.
    - `set message = "Text";`
    - `copy source -> target;`
- **Field Properties (Service Signatures & Pipeline Declarations):** Individual constraint attributes, validation flags, or documentation properties (such as `allowNull`, `required`, `contentType`, or `comment`) declared inside a variable's bracketed property block require a trailing semicolon after *each* property entry.
  - **Correct (Multi-Property & Block Layout):**
    ```fsl
    String monthlyInterestRate {
        allowNull: false;
        comment: "The nominal yearly interest rate converted to a monthly fractional decimal.";
    };
    
    recordList AmortizationSchedule {
        allowUnspecifiedFields: true;
        comment: """
          Line 1 of multiline documentation block
          Line 2 of multiline documentation block
          """;
    };
    ```

### B. FLOW STEP PROPERTIES PROHIBITED FROM USING SEMICOLONS
Properties nested inside structural flow-step control blocks (such as `comment:`, `validateInput:`, `invoke-order:`, or `switch:`) must **NEVER** be followed by a semicolon. Placing a semicolon inside a flow-step property scope will break the parser.
  - ❌ **Incorrect (Fails Parser):**
    ```fsl
    MAP {
        comment: "Parse Rate Type";
    }
    ```
  - **Correct:**
    ```fsl
    MAP {
        comment: "Parse Rate Type"
    }
    ```

### C. STRUCTURAL BRACES PROHIBITED FROM USING TRAILING SEMICOLONS
Never place a semicolon immediately after the closing brace (`}`) of ANY block structure. The closing brace itself acts as the complete delimiter:
- **Conditional Blocks:** `IF { ... }`, `ELSEIF { ... }`, `ELSE { ... }`
- **Branching & Containers:** `BRANCH { ... }`, `SEQUENCE { ... }`
- **Loop Structures:** `WHILE (cond) { ... }`, `LOOP { ... }`, `REPEAT { ... }`, `DO { ... } UNTIL (cond)`
- **Operational Blocks:** `MAP { ... }`, `INVOKE { ... }`, `TRANSFORM { ... }`
- **Exception Handling:** `TRY { ... }`, `CATCH { ... }`, `FINALLY { ... }`
- **Exit Blocks:** `EXIT { ... }`

### D. INLINE LOOP CONTROL
Loop control keywords `BREAK` and `CONTINUE` are completely standalone control statements and **MUST NOT** be followed by a semicolon when placed inside inline condition blocks.
- ❌ **Incorrect:** `IF (%Y% >= 15) { BREAK; }`
- **Correct:** `IF (%Y% >= 15) { BREAK }`
- **Correct:** `IF (%$iterationCount% == 3) { CONTINUE }`

## 4. STRICT OUTPUT & FORMATTING RULES
- **START OF FILE**: The very first line MUST be `interface folder.name`. There should not be a semicolon after the interface.
- **SERVICE DECLARATION**: Immediately following the interface, declare the service. You MUST use multi-line formatting for parameters (place inputs/outputs on separate lines) to ensure the signature is readable and never appears on a single line.
    - Format:

    service ServiceName (
          input {
              DataType1 param1;
              DataType2 param2;
          }
          output {
              DataType3 param3;
          }
      ) {

- **MANDATORY STRUCTURAL INDENTATION & ANTI-FLATTENING RULE (CRITICAL):**
  - **No Single-Line Multi-Statement Blocks:** You are STRICTLY FORBIDDEN from flattening variable declarations, map containers, block definitions, or mapping blocks onto a single line. There are NO exceptions to this rule.
  - **One Statement Per Line:** Every single field declaration, opening brace, operational mapping statement (`copy`, `set`, `drop`), and closing brace MUST occupy its own separate, distinct line.
  - **Indent Nested Structures:** Inner declarations (such as fields nested inside a `mapSource`, `mapTarget`, `record`, or `recordList`) must be cleanly indented on their own lines to maintain a readable, vertical, hierarchical tree view.
  - **❌ FORBIDDEN FLAT LAYOUT:**
    mapTarget { String currentBalance; String cumulativeInterest; recordList Accum { String Deleteme; } }
  - **✅ MANDATORY HIERARCHICAL LAYOUT:**
    mapTarget {
        String currentBalance;
        String cumulativeInterest;
        recordList Accum {
            String Deleteme;
        };
    }

- **WHITESPACE**: Do NOT add extra blank lines between sequential statements or blocks unless they appear in the reference examples. Examples in this document may show extra whitespace for readability, but match the vertical structured style of working code.

- **TYPE VALIDATION**: Before generating INVOKE blocks, verify:
  1. What is the data type of each source variable in mapSource?
  2. Does the corresponding mapTarget parameter use the SAME data type?
  3. If not, STOP and correct the type mismatch.

- **RAW OUTPUT**: No markdown wrappers (no triple backticks), no conversational text, no headers.

## 5. BLOCK TERMINATION (CRITICAL)
- **The Rule:** NO block structures should have a semicolon (`;`) after their closing brace `}`.
- **All Blocks:** This applies to ALL blocks including `MAP`, `INVOKE`, `SEQUENCE`, `EXIT`, `BRANCH`, `IF`, `LOOP`, `WHILE`, `REPEAT`, `DO`, `TRY`, `CATCH`, `FINALLY`, and `TRANSFORM`.
- **Correct:** `SEQUENCE { ... }`
- **Correct:** `MAP { ... }`
- **Correct:** `INVOKE { ... }`
- **Incorrect:** `SEQUENCE { ... }` (Do NOT add semicolons after block closing braces)

## 6. PROPERTY SEQUENCE (CRITICAL FOR PARSING)
- **STRICT ORDERING**: The parser treats properties in two distinct, sequential tiers. Mixing tiers or defining them out of order will cause an "extraneous input" error.
- **ORDER**: Properties MUST appear in the top of the block in this strict order:
    1.  **TIER 1: General Properties (`stepProperty`)**: These MUST come first.
        * `comment`
        * `scope`
        * `timeout`
        * `label`
    2.  **TIER 2: Block-Specific Properties**: These follow Tier 1 properties.
        * `SEQUENCE`: `exitOn`
        * `BRANCH`: `switch`, `evaluateLabels`
        * `LOOP`: `inputArray`
        * `REPEAT`: `count`, `repeatInterval`, `repeatOn`
    3.  **TIER 3: Executable Steps**: NEVER place these before Tier 1 or Tier 2 properties.
        * `MAP`, `INVOKE`, `IF`, `WHILE`, `DO`, `TRY`, `EXIT`, `BREAK`, `CONTINUE`

## 7. OUTPUT AS RAW TEXT
- Output the generated FSL as raw, plain text only.
- Do not wrap the output in Markdown code blocks or use triple backticks (e.g., no ``` or ```fsl)."

## 8. MAPSOURCE SCHEMA DEFINITION (CRITICAL)
- **Field Declarations in mapSource/mapTarget:**
    - **Forbidden:** Never use flat slash path notation (e.g., `items/quantity` or `DocumentA/DocumentB/Field1`) when declaring variables within a schema block.
    - **MANDATORY NESTED BLOCK RULES:** If nested fields or sub-documents are being mapped (`copy`), removed (`drop`), or initialized (`set`), you MUST declare their full hierarchical parent structures using explicit `record` or `recordList` nested blocks inside `mapSource` or `mapTarget`.
- **Example 1 (Nested Document Paths):** If an operation acts on `DocumentA/DocumentB/Field1`, the declaration block must fully reconstruct the hierarchy:

```fsl
          record DocumentA {
              record DocumentB {
                  String Field1;
              };
          }
```
- **Example 2 (Nested Record List Fields):** If an operation acts on a field `Deleteme` inside a record list named `AmortizationScheduleAccum`, the declaration block must look like:

```fsl
          recordList AmortizationScheduleAccum {
              String Deleteme;
          };
```

- Dots are allowed in flat standalone field declarations (e.g., `String watt.server.usejavaregex;`).

- **Loop Path Precision Rule:** When inside an active LOOP block over a recordList (e.g., `inputArray: "/items"`):
    - The mapSource and mapTarget must preserve the nested record structure.
    - Explicitly reference loop child fields using their relative path trajectory (`parentRecordList/childField`).
- **Correct:**
```fsl
    input {
        mapTarget {
            String num1;
            String num2;
        }
        copy items/quantity -> num1;
        copy items/price -> num2;
    }
```

- **Path Referencing (copy/set/drop execution):** Deep path notation using slashes (e.g., `DocumentA/DocumentB/Field1`) is strictly reserved for the executable statements themselves (`copy`, `set`, `drop`), while the matching `mapSource`/`mapTarget` blocks provide the companion structural definition layout[cite: 4].

## 9. IMPLICIT SCHEMA & AUTO-DECLARATION LOGIC (CRITICAL)

When the FSL content provided in a `MAP`, `INVOKE`, or `TRANSFORM` step references variables that have not been explicitly defined in a `mapSource` or `mapTarget` block, you must automatically generate the necessary declaration block.

**A. DEFAULT SIDE SELECTION**
You must determine the correct block to inject based on the step type:
* **MAP or INVOKE:** Default to a `mapTarget` block.
* **TRANSFORM:** Default to a `mapSource` block.

**B. MANDATORY AUTO-DECLARATION**
If a field is referenced in a `set` or `copy` operation but is missing from the existing signature:
1. Create the appropriate `mapSource` or `mapTarget` block.
2. Define the variable within that block.

**C. TYPE INFERENCE**
Infer the data type based on the assigned value:
* **Literal "0" or "1":** Treat as `Integer`.
* **String Literals (containing text or starting with letters):** Treat as `String`.
* **Ambiguous/Default:** If inference is not possible, default to `String`.

**D. GENERATION REQUIREMENT**
The generated FSL must include the injected block immediately before the operational statement (`set` or `copy`).
## 10. TYPE PRESERVATION IN INVOKE MAPPINGS (CRITICAL)

When mapping variables in INVOKE blocks, the **service catalog definition always takes precedence** over the pipeline source variable type.

**PRIMARY RULE — Catalog Type Precedence**: Before declaring any `mapTarget` type, look up the called service in the catalog. If the catalog defines a parameter type, that type MUST be used in `mapTarget` — regardless of the pipeline source variable's type. The service signature inputs must also match that catalog-defined type end-to-end to prevent runtime `Missing Parameter` errors.

- **Example**: `pub.math:addInts` catalog defines `num1` (String) and `num2` (String). Even if your pipeline variables are `Integer in1` and `Integer in2`, both the service signature AND `mapSource` MUST declare them as `String`. Using `Integer` in the signature when the called service expects `String` causes IS to fail silently — the parameter arrives as null and the service throws `Missing Parameter`.

**SECONDARY RULE — Source Type Matching (when no catalog constraint exists)**: When the target service does not impose a type constraint on its parameters, match the `mapTarget` type to the `mapSource` variable type.

- If copying `Integer quantity` → `num1` (unconstrained), declare `Integer num1`
- If copying `Double price` → `num2` (unconstrained), declare `Double num2`
- If copying `String customerId` → `id`, declare `String id`

**Common Error Pattern (WRONG) — Ignoring catalog type:**
```fsl
// pub.math:addInts expects String, but signature uses Integer
service addNumbers (
    input {
        Integer in1;  // ❌ WRONG - conflicts with pub.math:addInts String contract
        Integer in2;
    }
)
```
**Correct Pattern — Catalog type flows end-to-end:**
```fsl
// pub.math:addInts catalog defines num1/num2/value as String — use String throughout
service addNumbers (
    input {
        String in1;   // ✅ CORRECT - matches catalog String contract
        String in2;
    }
    output {
        String result;
    }
) {
    INVOKE pub.math:addInts {
        input {
            mapSource {
                String in1;
                String in2;
            }
            mapTarget {
                String num1;
                String num2;
            }
            copy in1 -> num1;
            copy in2 -> num2;
        }
        output {
            mapSource {
                String `value`;
            }
            mapTarget {
                String result;
            }
            copy `value` -> result;
        }
    }
}
```

**Output Mappings**: The same catalog precedence rule applies to output blocks — use the catalog-defined type of the returned parameter in `mapSource`.

## 11. SYSTEM VARIABLES (CRITICAL)

System variables (prefixed with `$`) are automatically available in their respective contexts and MUST NOT be declared in `mapSource` or `mapTarget` blocks.

**Common System Variables:**
- `$retries` - Available in REPEAT blocks, represents the current retry iteration (0-based index)
- `$iterationCount` - Available in DO/WHILE/LOOP blocks, represents the current iteration number
- `$null` - Represents null value in conditions and comparisons
- `$flow` - Represents the current flow service in EXIT blocks
- `$default` - Represents the default case in BRANCH blocks

**RULE**: NEVER declare system variables in mapSource or mapTarget. They are implicitly available. If a functional prompt or bulleted checklist explicitly tells you to convert or copy a system tracking variable (such as `$iterationCount`), you must execute the operation directly **WITHOUT** writing a corresponding data-type declaration line for it inside the `mapSource` or `mapTarget` contract boundaries.

**Wrong:**
```fsl
REPEAT {
    MAP {
        TRANSFORM pub.string:concat {
            input {
                mapSource {
                    String[] repeatVals;
                    String $retries; // ❌ WRONG - System variables must never be declared
                }
            }
        }
    }
}
```
**Correct:**
```fsl
REPEAT {
    MAP {
        TRANSFORM pub.string:concat {
            input {
                mapSource {
                    String[] repeatVals; // ✅ CORRECT - Only regular variables are declared
                }
                mapTarget {
                    String inString1;
                    String inString2;
                }
                copy repeatVals[$retries] -> inString2; // $retries is used implicitly without declaration
            }
        }
    }
}
```


## 12. RESERVED KEYWORD MAPPING (CRITICAL)
- **DEFAULT HANDLING**: Map "default", "otherwise", or "else" to the reserved keyword `"$default"`.
    - *Input:* "...with default in the label."
    - *Output:* `label: "$default"`

- **NULL HANDLING**: Map "null" or "$null" based on context:
    - **If used as a condition** (e.g., `label: "%var% == $null";`): Use `$null` (no quotes).
    - **If used as a standalone label** (e.g., "when it is null"): Use `"$null"` (with quotes).

## 13. SERVICE SIGNATURE FORMATTING (READABILITY)
You are permitted to break the service signature into multiple lines for readability by inserting line breaks after the commas within the parentheses `(...)` and within the `input` and `output` blocks.

- **ALLOWED:** Using line breaks after commas and within `input`/`output` blocks to improve readability.
- **REQUIRED:** You must use `input` and `output` blocks to define the signature, as required by the grammar.
- **SYNTAX RULE:** The vertical structure must not interfere with the parameter list logic or the closing braces of the signature.

### Field Declaration Syntax
Fields in service signatures can be declared in two ways:

1. **Simple Field Declaration** (when NO constraints are specified):
   - Format: `DataType fieldName;`
   - Example: `String orderId;`

2. **Field Declaration with Property Constraints** (REQUIRED when constraints like allowNull or required are specified):
   - **CRITICAL:** When the task specification includes field constraints (allowNull, required, etc.), you MUST append a property block `{}` directly following the field identifier.
   - Format: `DataType fieldName { propertyName: booleanValue; }`
   - Each property inside the block must follow the format `propertyName: booleanValue;` terminated by a semicolon.
   - Example:
     ```
     String interestRate {
         allowNull: false;
         required: true;
         comment: "Monthly interest"
     }
     ```

### Examples

Example 1 - Simple fields (no constraints):
    service processOrder (
        input {
            String orderId;
            String customerId;
            recordList items {
                String productid;
                Integer quantity;
                Double price;
            };
            String customerType;
        }
        output {
            Double orderTotal;
            Double discountApplied;
            String orderStatus;
            String message;
        }
    )

Example 2 - Field with constraints:
    service CalculateMonthlyInterestRate (
        input {
            String interestRate {
                allowNull: false;
                required: true;
                comment: "Monthly interest"
            };
        }
        output {
            String monthlyInterest;
        }
    )

## 14. LOOP AND BLOCK STRUCTURES
Use the following logic to determine if a `SEQUENCE` block is required in `WHILE`, `LOOP`, `REPEAT`, or `DO` structures:

- **LOGIC RULE**:
    - **IF** the user prompt explicitly requests a `SEQUENCE` block: You MUST wrap the contents of the loop in a `SEQUENCE`.
    - **IF** the user prompt does NOT request a `SEQUENCE` block: Do NOT include one. Generate the code directly inside the loop/block.

- **NO PREFERENCES**: Do not prioritize "compactness" over user instructions. If a user asks for a `SEQUENCE`, the sequence is mandatory, even if the code looks cleaner without it.

- **Example (Without Sequence - Default)**:

    WHILE (y < 20) {
        maxIteration: 50;
        INVOKE pub.math:addObjects {}
        IF (y >= 15) {
            BREAK
        }
    }

- **Example (With Sequence - User Requested)**:

    WHILE (y < 20) {
        maxIteration: 50;
        SEQUENCE {
            INVOKE pub.math:addObjects {}
            IF (y >= 15) {
                BREAK
            }
        }
    }

## 14a. SETTING CONDITIONAL FIELD VALUES IN LOOP (CRITICAL PATTERN)

When you need to set field values based on conditions inside a `LOOP`, you MUST calculate the value BEFORE mapping it into the target record structure.

**Why This Pattern is Required**:
- Once a record is created in a `MAP` block, you cannot reliably modify its fields in subsequent `MAP`/`IF` blocks
- Field values must be determined and available BEFORE the record is created
- Use temporary variables to hold calculated values, then copy them into the record

**❌ WRONG Approach (unreliable)**:
```fsl
LOOP {
    inputArray: "/sourceRecords"
    // ✗ WRONG - Creating record first, then trying to modify
    MAP {
        copy sourceRecords/field1 -> targetRecord/field1;
        set targetRecord/status = "default";
    }
    // ✗ WRONG - Trying to modify record field after creation
    IF (%targetRecord/field1% == "special") {
        MAP {
            set targetRecord/status = "modified";
        }
    }
}
```

**✅ CORRECT Approach (reliable)**:
```fsl
LOOP {
    inputArray: "/sourceRecords"
    // ✓ CORRECT - Calculate value in temporary variable FIRST
    MAP {
        mapTarget {
            String statusValue;
        }
        set statusValue = "default";
    }
    IF (%sourceRecords/field1% == "special") {
        MAP {
            set statusValue = "modified";
        }
    }
    IF (%sourceRecords/field2% > %threshold%) {
        MAP {
            set statusValue = "exceeded";
        }
    }
    // ✓ CORRECT - Map calculated value into record during creation
    MAP {
        mapSource {
            record sourceRecords {
                String field1;
                String field2;
            };
            String statusValue;
        }
        mapTarget {
            record targetRecord {
                String field1;
                String field2;
                String status;
            };
        }
        copy sourceRecords/field1 -> targetRecord/field1;
        copy sourceRecords/field2 -> targetRecord/field2;
        copy statusValue -> targetRecord/status;
    }
    // ✓ CORRECT - Clean up temporary variable
    MAP {
        drop statusValue;
    }
}
```

**Pattern Steps**:
1. Initialize temporary variable with default value
2. Use `IF`/`SWITCH` statements to modify temporary variable based on conditions
3. Include temporary variable in `mapSource` when creating target record
4. Copy temporary variable value into target record field
5. Drop temporary variable after record creation
6. Continue with other operations (e.g., append to document list)

**When to Use This Pattern**:
- Setting field values based on conditional logic
- Calculating derived values from multiple source fields
- Applying business rules during data transformation
- Any scenario where field value depends on runtime conditions

## 15. MAP BLOCK STRUCTURE AND CONFIGURATION PATTERNS (CRITICAL)

`MAP` blocks have two mutually exclusive structural patterns. You must **NEVER** combine or mix elements of these patterns within a single `MAP` block scope.

### Pattern 1: Direct Assignments (Simple MAP)
- **Use Case:** Use this pattern strictly when performing immediate, top-level variable initializations (`set`) or variable movements (`copy`) between existing pipeline fields.
- **Rule:** Declarations for `mapSource` and `mapTarget` occur **only** at the immediate base root of the `MAP` block, directly followed by your action statements. No service elements are invoked here.
- **Example:**
    ```fsl
    MAP {
        mapTarget {
            String status;
        }
        set `status` = "PENDING";
    }
    ```

### Pattern 2: Nested TRANSFORM / Service Wrapper (Wrapper MAP)
- **Use Case:** Use this pattern strictly when wrapping an inline service conversion or localized utility calculation (e.g., executing a calculation inside individual `MAP` blocks).
- **Rule:** The parent `MAP` block acts strictly as a structural envelope and container properties (like `comment:`). It must **NEVER** contain a root-level `mapSource` or `mapTarget` block. All structural scoping, parameter allocations, and assignments must be nested **inside** the child `TRANSFORM` or `INVOKE` block's `input {}` and `output {}` definitions.
- **CRITICAL PROPERTY RESTRICTION:** Do **NOT** populate inner block metadata properties such as `invoke-order: 0`, `validateInput: false`, or `validateOutput: false` inside the `TRANSFORM` block unless the user's prompt explicitly requests them. Generate a clean `TRANSFORM` block containing *only* the `input {}` and `output {}` mapping definitions by default.
- **Example (Standard Clean Structure):**
```fsl
MAP {
        comment: "Parse Rate Type"
        TRANSFORM pub.math:toNumber {
            input {
                mapSource {
                    String monthlyInterestRate;
                }
                mapTarget {
                    String num;
                }
                copy `monthlyInterestRate` -> `num`;
            }
            output {
                mapSource {
                    Object num;
                }
                mapTarget {
                    String monthlyInterestRateNum;
                }
                copy `num` -> `monthlyInterestRateNum`;
            }
        }
    }
```

### ⚠️ ABSOLUTE PROHIBITION
- **FORBIDDEN:** Do **NOT** declare `mapSource` or `mapTarget` block structures at both the top parent `MAP` level AND inside the inner nested child `TRANSFORM`/`INVOKE` block. If a child transformer block is present, the root `MAP` level must remain entirely empty of assignment scaffolding.

## 16. NATURALLY SPOKEN FLOW SELECTION DICTIONARY (INVOKE VS. TRANSFORM)
When deciding whether to output a standalone `INVOKE` block or a `MAP { TRANSFORM ... }` structure, analyze the exact wording and user intent in the prompt:

*   **Generate an `INVOKE` block directly when:** 
    *   The prompt uses action verbs targeting an execution, a milestone, or a heavy pipeline processing step.
    *   *Key Phrases:* "Invoke...", "Call...", "Execute...", "Run...", "Step 1: Invoke X, Step 2: Invoke Y".
*   **Generate a `MAP` containing a nested `TRANSFORM` when:** 
    *   The prompt describes data mutation, inline math formulas, line-item adjustments, or localized field overrides.
    *   *Key Phrases:* "Use a transformer for...", "Perform an inline calculation to...", "Transform variables inside individual MAP blocks...", "Map using the transformer...".

### 17. COMPONENT SELECTION DEFAULT STRATEGY (NON-TECHNICAL PROMPTING)
To support non-technical business prompts, follow this default architectural rule when selecting between an `INVOKE` block and a `MAP { TRANSFORM ... }` structure:

1. **Default to Standalone `INVOKE` for Single Operations:** If a step describes a standalone processing task or a simple, single mathematical operation (e.g., *"Divide the incoming X by Y"*, *"Multiply the rate"*), you must default to a standalone `INVOKE` block.
2. **Prefer `MAP` with `TRANSFORM` for Multi-Operation Blocks:** If a single step bundles a service execution alongside other pipeline management tasks—such as simultaneous variable assignments (`set`), field movements (`copy`), pipeline cleanups (`drop`), or other inline calculations—group them inside a single `MAP` block utilizing a nested `TRANSFORM`.
3. **Use Explicit Transformers Only When Requested:** Generate a `MAP` with an inline `TRANSFORM` if the user explicitly requests an inline transformation or formatting adjustment (e.g., uses phrases like *"Perform an inline calculation to..."*, *"Map using a transformer..."*, or specifies localized output string formatting like currency masks).

> **CRITICAL ARCHITECTURAL CONSTRAINT:** 
> When a user requests a service call execution or calculation that is explicitly scoped inside an existing or active `MAP` block, **never** use an `INVOKE` statement. Under no circumstances are `INVOKE` keywords permitted inside a `MAP` container; only `TRANSFORM` keywords are structurally valid for service execution within a `MAP`. Note that pipeline mapping actions (`copy`, `set`, `drop`) remain completely valid inside the input/output scopes of both `INVOKE` and `TRANSFORM` structures.

### 18. TOP-LEVEL SERVICE PROPERTIES BLOCK
**Rule**: Top-level service properties (such as service comments, visibility modifiers, prefetch configurations, and validation hooks) must be declared immediately after the service's input/output signature blocks and before the opening curly brace `{` of the service body. Semicolons are required at the end of every property line within the block.

**Syntax Template**:
```fsl
interface FolderName

service ServiceName (
    input { 
        // Inputs here
    }
    output { 
        // Outputs here
    }
)
properties {
    comment: "A concise description outlining the exact business purpose of this service.";
    visible: private; // Options: public, private
    prefetch: true;
    prefetchActivation: 1;
    validateInput: true;
    validateOutput: false;
}
{
    // Core service execution steps (INVOKE, MAP, BRANCH, LOOP, REPEAT) go here
}
```
