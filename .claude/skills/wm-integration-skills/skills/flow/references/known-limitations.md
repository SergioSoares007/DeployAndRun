# Known Limitations

This file tracks known issues that affect FSL generation, including grammar parsing failures, transpiler problems, and code generation constraints — along with their resolution status and required workarounds.

**Lifecycle states:**
- 🚫 **ACTIVE** — Issue is open. Apply the stated workaround exactly as described.
- ✅ **RESOLVED** — Issue has been fixed. The affected services or patterns are fully supported. Use them normally with no workarounds.

---

## 🚫 ACTIVE — `pub.date` folder (all services) + `date` as a standalone identifier segment

- **Status**: Open. Grammar cannot parse `date` as a standalone word in any identifier — whether as a namespace segment (`pub.date:serviceName`) or as a variable name segment separated by `.` or `-` (e.g. `someRecord.date`, `test-date`).
- **Category**: Grammar parsing failure.
- **Root cause**: The lexer token `W3C_DATE` is defined as the literal string `'date'` in `AssetLexer.g4`. Whenever the parser encounters `date` as a standalone word — i.e. isolated by a `.` or `-` delimiter — it tokenises it as the `W3C_DATE` keyword rather than a plain identifier, producing `mismatched input 'date'` parse errors. **This only applies when `date` appears as its own delimited segment.** Camel-case names that contain the substring `date` (e.g. `testDate`, `dateValue`, `orderDate`) are unaffected because the lexer matches the whole token, not a substring.
- **Affected patterns**:
  - **Service invocations**: all services in the `pub.date` folder (any `pub.date:*` target):
    - `pub.date:calculateDateDifference`
    - `pub.date:compareDates`
    - `pub.date:currentNanoTime`
    - `pub.date:dateBuild`
    - `pub.date:dateTimeBuild`
    - `pub.date:dateTimeFormat`
    - `pub.date:elapsedNanoTime`
    - `pub.date:formatDate`
    - `pub.date:getCurrentDate`
    - `pub.date:getCurrentDateString`
    - `pub.date:getWorkingDays`
    - `pub.date:incrementDate`
    - `pub.date:stringToDate`
  - **Variable / field names**: any name where `date` is a standalone segment separated by `.` or `-`, e.g. `input.date`, `result.date.value`, `test.date`, `test-date`, `order-date`.
- **Action**:
  1. Do NOT generate INVOKE or TRANSFORM steps targeting any `pub.date:*` service. If the user explicitly requires date/time functionality, stop generation and notify the user that `pub.date` services cannot currently be used due to a grammar parsing limitation.
  2. Do NOT attempt to substitute with invented services, system variables (e.g. `$currentDateTime`), or workarounds not documented in the service catalog.
  3. Do NOT silently omit the date operation — always surface the limitation to the user.
  4. Do NOT generate variable or field names that contain `date` as a standalone segment separated by `.` or `-` (e.g. `input.date`, `test.date`, `test-date`). Use a camel-case alternative instead (e.g. `inputDate`, `testDate`).

---

## 🚫 ACTIVE — `byte[]` primitive type in field declarations

- **Status**: Open. Using lowercase `byte[]` as a field type in `mapSource` or `mapTarget` blocks causes a parse error.
- **Category**: Grammar parsing failure.
- **Root cause**: The lexer defines two separate tokens for byte types: `BYTE_PRIMITIVE : 'byte'` (lowercase) and `BYTE_TYPE : 'Byte'` (capitalised). The grammar's `dataType` rule in `Document.g4` only includes `BYTE_TYPE` (`'Byte'`). When the parser encounters lowercase `byte[]` inside a `fieldDeclaration`, it tokenises `byte` as `BYTE_PRIMITIVE` — an unrecognised token in that position — producing errors such as `invalid syntax at input '{byte'`, `unexpected token ';'`, and `mismatched input 'byte'`.
- **Affected pattern**: Any `mapSource` or `mapTarget` block that declares a byte-array field using lowercase `byte[]`, e.g. when mapping inputs or outputs for services like `pub.string:bytesToString` or `pub.client:http` (whose `body/bytes` output is typed `byte[ ]` in the catalog).
- **Action**:
  1. **ALWAYS** use `Byte[]` (capital B, no space before `[]`) when declaring a byte-array field in any `mapSource`, `mapTarget`, or service signature block.
  2. **NEVER** write `byte[]`, `byte[ ]`, or `Byte[ ]` (with a space) — all three forms fail the parser.
  3. When a service catalog entry shows the type as `byte[ ]` (with a space, as displayed in IBM docs), translate it to `Byte[]` in FSL.

  - ❌ **FORBIDDEN:**
    ```fsl
    mapSource {
        record body {
            byte[] bytes;
        };
    }
    mapTarget {
        byte[] bytes;
    }
    ```
  - ✅ **MANDATORY:**
    ```fsl
    mapSource {
        record body {
            Byte[] bytes;
        };
    }
    mapTarget {
        Byte[] bytes;
    }
    ```

---

## 🚫 ACTIVE — `maxLength` / `minLength` variable names

- **Status**: Open. Naming a pipeline variable `maxLength` or `minLength` causes a parse error.
- **Category**: Grammar parsing failure.
- **Root cause**: The lexer tokens `MAX_LENGTH` and `MIN_LENGTH` are defined as the literal strings `'maxLength'` and `'minLength'` in `AssetLexer.g4`. When the parser encounters these words as variable identifiers (e.g. in a `MAP` step or `SEQUENCE` declaration), it tokenises them as reserved keywords rather than plain identifiers, producing `mismatched input 'maxLength'` / `mismatched input 'minLength'` parse errors.
- **Affected pattern**: Any step or block that declares or references a pipeline variable named exactly `maxLength` or `minLength`.
- **Action**:
  1. **NEVER** name a pipeline variable `maxLength` or `minLength`.
  2. Use an unambiguous alternative such as `maximumLength`, `minLen`, `maxLen`, or a context-specific name (e.g. `fieldMaxLength`).
  3. If the user's requirements explicitly reference these names, silently substitute a safe alternative and note the rename in a comment or to the user.

---

## Adding New Entries

Use this template when adding a new issue:

```
## 🚫 ACTIVE — [affected folder or pattern]

- **Status**: Open. [one-line description of the failure]
- **Category**: [Grammar parsing failure | Transpiler problem | Code generation constraint | Other]
- **Root cause**: [technical explanation]
- **Affected services**: [list or description]
- **Action**: [exact instruction for the model — what to do and what NOT to do]
```

When an issue is resolved, update the entry to:

```
## ✅ RESOLVED — [affected folder or pattern]

- **Status**: Fixed. [what was fixed]
- **Category**: [same as above]
- **Fixed in**: [grammar version, transpiler version, or date]
- **Action**: Use normally. No workarounds needed. Refer to the service catalog for correct parameter names and usage examples.
```
