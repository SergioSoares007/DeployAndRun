# FSL Best Practices

This file records confirmed runtime and parse failures encountered during real generation sessions, along with the correct patterns to use instead. Entries here are derived from actual errors — treat every rule as a hard constraint.

---

## Catalog Corrections

Known discrepancies between the service catalog documentation and actual IS runtime behaviour. Always apply these corrections over the catalog.

---

### 🚫 BP-004 — `pub.client:http` body/bytes is `Object`, not `Byte[]`

- **Discovered:** When mapping the HTTP response body out of `pub.client:http` and into `pub.string:bytesToString`.
- **Catalog says:** `body/bytes` type is `byte[ ]`
- **Actual runtime type:** `Object`
- **Action:**
  1. In the `pub.client:http` output `mapSource`, declare `body/bytes` as `Object bytes;` not `Byte[] bytes;`
  2. In the output `mapTarget`, declare the receiving pipeline variable as `Object`, not `Byte[]`
  3. In the subsequent `pub.string:bytesToString` input `mapSource` and `mapTarget`, use `Object` for both the source variable and the `bytes` parameter

#### Correct pattern

```fsl
INVOKE pub.client:http {
    ...
    output {
        mapSource {
            record body {
                Object bytes;
            };
        }
        mapTarget {
            Object responseBytes;
        }
        copy body/bytes -> responseBytes;
        ...
    }
}
INVOKE pub.string:bytesToString {
    input {
        mapSource {
            Object responseBytes;
        }
        mapTarget {
            Object bytes;
        }
        copy responseBytes -> bytes;
    }
    ...
}
```

---

### ✅ BP-006 — Map Output Signature Fields in a Final MAP After the CATCH

- **Pattern:** When a service calls an API, parses a JSON response into a document, and needs to promote those fields to the service output signature, do NOT place the output mapping MAP inside the TRY block. Instead, place a single MAP as the very last statement in the service body — outside the TRY, after the CATCH.
- **Why it works:** After `pub.json:jsonStringToDocument`, the parsed document is in the pipeline as a named record (e.g. `responseDoc`). This record persists in the pipeline after the TRY/CATCH chain completes. A trailing MAP can then extract its fields and promote them to flat pipeline variables matching the output signature names.
- **Benefits:**
  1. Cleaner separation — the TRY handles the HTTP call and parsing; the trailing MAP handles output promotion.
  2. The CATCH EXIT short-circuits the flow on failure, so the trailing MAP only runs on the success path.
  3. Avoids nesting the output mapping inside the TRY where it adds noise.
- **Field extraction strategy — see BP-010:** For extracting fields out of the parsed document record, prefer `set (variable)` over `record`+`copy`. See BP-010 for the decision rule.

#### Structure (single field — preferred `set (variable)` form)

```fsl
service myService (
    input { ... }
    output { String field1; }
)
{
    TRY {
        // HTTP call, bytesToString, jsonStringToDocument
        // Parsed document lands in pipeline as responseDoc
    }
    CATCH {
        EXIT {
            exitFrom: "$flow"
            signal: "FAILURE"
            failureMessage: "..."
        }
    }
    MAP {
        comment: "Extract field from parsed JSON response"
        mapTarget {
            String field1;
        }
        set (variable) field1 = "%responseDoc/field1%";
        drop responseDoc;
    }
}
```

#### Structure (multiple fields — `record`+`copy` form)

```fsl
service myService (
    input { ... }
    output { String field1; String field2; }
)
{
    TRY {
        // HTTP call, bytesToString, jsonStringToDocument
    }
    CATCH {
        EXIT {
            exitFrom: "$flow"
            signal: "FAILURE"
            failureMessage: "..."
        }
    }
    MAP {
        comment: "Map pipeline fields to service output signature"
        mapSource {
            record responseDoc {
                String field1;
                String field2;
            };
        }
        mapTarget {
            String field1;
            String field2;
        }
        copy responseDoc/field1 -> field1;
        copy responseDoc/field2 -> field2;
        drop responseDoc;
    }
}
```

---

### ✅ BP-007 — Initialising a Record with Named Fields Using Backtick-Quoted Keys

- **Context:** When you need to create a pipeline record (e.g. `headers`, a request body document, or any named IData structure) and populate one or more named fields, use a two-MAP pattern:
  1. A first MAP that declares the record structure in `mapTarget` and initialises it with a `set` using backtick-quoted identifiers.
  2. A second MAP that copies pipeline variables into the record's child fields.
- **Why backticks are required in the `set` literal:** Field names that contain hyphens, uppercase letters, or other non-standard identifier characters (e.g. `X-API-Key`) are not valid bare FSL identifiers. Wrapping both the record name and the field key in backticks inside the JSON-style literal instructs the FSL parser to treat them as literal string keys rather than identifier tokens.
- **Rule:** Whenever a record or its child fields contain non-standard characters (hyphens, mixed case, dots outside of IS property names), use the backtick-quoted initialisation pattern for the `set` statement AND declare the child field explicitly in `mapTarget`.

#### Pattern

```fsl
MAP {
    comment: "Initialise the record structure"
    mapTarget {
        record myRecord {
            String my-Field;
        };
    }
    set `myRecord` = {`my-Field`:""};
}
MAP {
    comment: "Populate the record field from pipeline"
    mapSource {
        String sourceVar;
    }
    mapTarget {
        record myRecord {
            String my-Field;
        };
    }
    copy sourceVar -> myRecord/my-Field;
    drop sourceVar;
}
```

#### Applied example — HTTP request headers with X-API-Key

```fsl
MAP {
    comment: "Initialise headers document"
    mapTarget {
        record headers {
            String X-API-Key;
        };
    }
    set `headers` = {`X-API-Key`:""};
}
MAP {
    comment: "Set API key header value"
    mapSource {
        String apiKey;
    }
    mapTarget {
        record headers {
            String X-API-Key;
        };
    }
    copy apiKey -> headers/X-API-Key;
    drop apiKey;
}
```

#### When to use this pattern

| Scenario | Example field names |
|---|---|
| HTTP request headers | `X-API-Key`, `Content-Type`, `Authorization` |
| Nested request body documents | Any field with hyphens or mixed-case keys |
| IS server property documents | Fields with dots e.g. `watt.server.usejavaregex` |
| Any IData record where keys are not plain lowercase identifiers | Any non-standard key |

---

### 🚫 BP-009 — `Document` Type Is Forbidden Inside `mapSource` and `mapTarget` Blocks

- **Discovered:** When mapping the output of `pub.json:jsonStringToDocument` (which returns a `Document` output parameter) and when extracting fields from a parsed document record in a trailing MAP step.
- **Error produced:** `mismatched input 'String'`, `unexpected token ';'`, `unexpected token 'mapTarget'` — parse errors triggered at the line immediately following the illegal `Document` declaration.
- **Root cause:** `Document` is a type keyword valid only in service signature `input {}` and `output {}` blocks (the parenthesised section of a `service` declaration). The grammar's `fieldDeclaration` rule inside `mapSource` and `mapTarget` does not accept `Document` as a data type. When the parser encounters it, it misreads the subsequent lines, producing cascading parse errors.
- **Affected patterns:**
  1. INVOKE `output { mapSource { Document ...; } }` — when capturing the output of a service whose catalog entry types a return value as `Document` (e.g. `pub.json:jsonStringToDocument` output `document`).
  2. INVOKE `output { mapTarget { Document ...; } }` — when declaring the receiving pipeline variable for a document-typed output.
  3. `MAP { mapSource { Document ...; } }` — when referencing a document-typed pipeline variable in a MAP step.
- **Action:**
  1. **NEVER** write `Document varName;` or `Document varName { ... };` inside any `mapSource` or `mapTarget` block.
  2. Always declare document-typed pipeline variables using `record varName { ... };` inside `mapSource` and `mapTarget`.
  3. If the record has no child fields that need to be referenced in that specific block, use an empty body: `record varName { };`.
  4. If child fields of the document need to be accessed (e.g. `varName/fieldA`), declare them explicitly inside the `record` block.

#### Correct pattern — capturing a `Document`-typed INVOKE output

```fsl
INVOKE pub.json:jsonStringToDocument {
    input {
        mapSource {
            String responseString;
        }
        mapTarget {
            String jsonString;
        }
        copy responseString -> jsonString;
    }
    output {
        mapSource {
            record `document` {   // ✅ 'record', not 'Document'; backtick because 'document' is reserved
            };
        }
        mapTarget {
            record jokeDoc {      // ✅ 'record', not 'Document'
            };
        }
        copy `document` -> jokeDoc;
        drop `document`;
    }
}
```

#### Correct pattern — reading child fields from a document-typed pipeline variable in a MAP

```fsl
MAP {
    mapSource {
        record jokeDoc {          // ✅ 'record', not 'Document'
            String `value`;       // declare child fields you intend to copy
        };
    }
    mapTarget {
        String joke;
    }
    copy jokeDoc/`value` -> joke;
    drop jokeDoc;
}
```

#### Summary table

| Context | ❌ Forbidden | ✅ Correct |
|---|---|---|
| INVOKE output `mapSource` for a Document-typed return | `Document \`document\`;` | `record \`document\` { };` |
| INVOKE output `mapTarget` receiving a Document | `Document jokeDoc;` | `record jokeDoc { };` |
| MAP `mapSource` referencing a document pipeline var | `Document jokeDoc { String field; };` | `record jokeDoc { String field; };` |

---

### ✅ BP-010 — Use `set (variable)` to Extract Fields From a Parsed JSON Document

- **Context:** After `pub.json:jsonStringToDocument` places a parsed document record into the pipeline, you need to promote one or more of its leaf fields to flat output signature variables.
- **Two approaches exist — choose based on field count:**

| Scenario | Preferred approach |
|---|---|
| Extracting **one or a few** named leaf fields | `set (variable)` — shorter, no `mapSource` needed, avoids BP-009 entirely |
| Extracting **many** fields or fields into a structured output record | `record`+`copy` in a MAP with explicit `mapSource`/`mapTarget` |

- **Why `set (variable)` is preferred for simple extraction:**
  1. Avoids declaring the parsed document as a `record` in `mapSource` — which is where BP-009 (`Document` type forbidden) can be accidentally triggered.
  2. Requires only a `mapTarget` declaration for the output variable — no `mapSource` block needed.
  3. IS evaluates the `%doc/field%` path at runtime, navigating directly into the parsed IData structure.

- **Syntax reminder** (from authoring-guide §1.1): `set (variable)` triggers IS runtime substitution. A plain `set` without `(variable)` assigns the literal string `"%doc/field%"` — it does NOT navigate the path.

#### Correct pattern

```fsl
MAP {
    comment: "Extract field from parsed JSON response"
    mapTarget {
        String joke;
    }
    set (variable) joke = "%jokeDoc/value%";
    drop jokeDoc;
}
```

#### Incorrect pattern (what NOT to do for simple extraction)

```fsl
// ❌ Verbose and risks BP-009 if Document type is used instead of record
MAP {
    mapSource {
        record jokeDoc {
            String `value`;
        };
    }
    mapTarget {
        String joke;
    }
    copy jokeDoc/`value` -> joke;
    drop jokeDoc;
}
```

#### Notes
- The `%doc/field%` path inside `set (variable)` does NOT require backticks around reserved keyword field names (e.g. `value`). The runtime substitution engine reads it as a plain path string, not an FSL identifier token.
- `drop` the source document record in the same MAP block after extraction to maintain pipeline hygiene (BP-003).
- For deeply nested paths or array indexing, `set (variable)` also supports `%doc/nested/field%` and `%doc/array[0]/field%` syntax.

---

### 🚫 BP-011 — `pub.datetime:build` with offset-bearing patterns requires a timezone source

- **Discovered:** When calling `pub.datetime:build` with pattern `"x"` (epoch milliseconds via Java `DateTimeFormatter`) to capture a timestamp for duration calculation.
- **Error produced:** `Unsupported field: OffsetSeconds` — thrown at runtime by the Java `DateTimeFormatter` when the pattern includes any timezone offset component but no timezone is supplied.
- **Root cause:** Java `DateTimeFormatter` patterns that encode a timezone offset (`x`, `X`, `z`, `Z`, `xxx`, `ZZZ`, etc.) require a timezone to be present when formatting. `pub.datetime:build` has no default timezone — if neither `timezone` nor `useSystemTimeZone: true` is provided, the formatter cannot resolve the offset and throws `Unsupported field: OffsetSeconds`.
- **Affected patterns:** Any `pub.datetime:build` call whose `pattern` input contains one of the following Java `DateTimeFormatter` timezone symbols:

  | Symbol | Meaning |
  |---|---|
  | `x` | Offset ID (e.g. `+0100`, used for epoch ms via `"x"` full pattern) |
  | `X` | Offset ID with `Z` for UTC |
  | `z` | Time zone name (e.g. `PST`) |
  | `Z` | Zone offset / RFC 822 (e.g. `-0800`) |
  | `O` | Localized zone offset (e.g. `GMT-8`) |
  | `V` | Time zone ID (e.g. `America/Los_Angeles`) |

- **Action:**
  1. **ALWAYS** supply `useSystemTimeZone = "true"` in the `mapTarget` of every `pub.datetime:build` `input {}` block whose pattern contains any of the symbols above.
  2. Never rely on the service defaulting to a timezone — it does not.
  3. If a specific timezone is required instead of the server default, set the `timezone` input parameter explicitly (e.g. `set timezone = "UTC";`). Setting `timezone` makes `useSystemTimeZone` irrelevant.
  4. **BP-002 stale variable rule applies:** If `pub.datetime:build` is called more than once in the same service, each subsequent call MUST explicitly re-declare and re-set `useSystemTimeZone` in its own `mapTarget` block to prevent the stale value from the first call silently carrying forward.

#### Correct pattern

```fsl
INVOKE pub.datetime:build {
    input {
        mapTarget {
            String `pattern`;
            String useSystemTimeZone;
        }
        set `pattern` = "x";
        set useSystemTimeZone = "true";
    }
    output {
        mapSource {
            String `value`;
        }
        mapTarget {
            String startedAtMs;
        }
        copy `value` -> startedAtMs;
    }
}
```

#### Incorrect pattern (triggers `Unsupported field: OffsetSeconds`)

```fsl
INVOKE pub.datetime:build {
    input {
        mapTarget {
            String `pattern`;
        }
        set `pattern` = "x";   // ❌ offset symbol with no timezone source
    }
    output {
        mapSource {
            String `value`;
        }
        mapTarget {
            String startedAtMs;
        }
        copy `value` -> startedAtMs;
    }
}
```

#### Multiple calls in the same service — BP-002 override required

```fsl
// Call 1 — sets useSystemTimeZone = "true" into pipeline
INVOKE pub.datetime:build {
    input {
        mapTarget {
            String `pattern`;
            String useSystemTimeZone;
        }
        set `pattern` = "x";
        set useSystemTimeZone = "true";
    }
    output { ... }
}

// Call 2 — MUST re-declare and re-set useSystemTimeZone to override the stale value
INVOKE pub.datetime:build {
    input {
        mapTarget {
            String `pattern`;
            String useSystemTimeZone;        // ✅ explicit override required
        }
        set `pattern` = "yyyy-MM-dd'T'HH:mm:ss.SSS";
        set useSystemTimeZone = "true";     // ✅ re-set, not inherited
    }
    output { ... }
}
```
