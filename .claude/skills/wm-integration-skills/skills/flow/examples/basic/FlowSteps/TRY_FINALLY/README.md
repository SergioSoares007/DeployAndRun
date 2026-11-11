# TRY-FINALLY Example

## Purpose
Demonstrates cleanup and guaranteed post-processing in FSL by using a TRY-FINALLY block with `pub.math:addInts`.

## Implementation Details
- **TRY block**: Invokes `pub.math:addInts`
- **FINALLY block**: Sets `status` to `COMPLETED` and writes a debug log message
- **Type handling**: Uses `String` for `num1`, `num2`, and `result` to match runtime expectations for `pub.math:addInts`
- **Execution guarantee**: The FINALLY block runs after the TRY block completes

## Input Specification
```text
String num1 - First numeric input as string
String num2 - Second numeric input as string
```

## Output Specification
```text
String result - Sum returned by `pub.math:addInts`
String status - Completion marker set in FINALLY
```

## Key Patterns
- TRY-FINALLY blocks are sibling blocks with no trailing semicolons
- Use numeric strings for `pub.math:addInts` inputs
- Put cleanup, status updates, and logging in FINALLY
- Keep pub.math input and output mappings type-consistent as `String`

## Notable Techniques
- Minimal TRY-FINALLY pattern without CATCH
- FINALLY used for deterministic status assignment
- Debug logging used for execution visibility
