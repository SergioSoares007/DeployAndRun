# TRY-CATCH-FINALLY Example

## Purpose
Demonstrates exception handling in FSL using TRY-CATCH-FINALLY blocks with `pub.math:divideInts`.

## Implementation Details
- **TRY block**: Attempts integer division by using `pub.math:divideInts`
- **CATCH block**: Captures errors by using `pub.flow:getLastError` and logs error details
- **FINALLY block**: Executes cleanup and logging regardless of success or failure
- **Type consistency**: All variables use String type to match `pub.math:divideInts` requirements

## Input Specification
```
String dividend  - Number to be divided (as string)
String divisor   - Number to divide by (as string)
```

## Output Specification
```
String result        - Quotient of division (populated on success)
String status        - "SUCCESS" or "ERROR"
String errorMessage  - Error details (populated on failure)
```

## Key Patterns
1. **TRY-CATCH-FINALLY chaining**: No semicolons after block closing braces
2. **Error capture**: Use `pub.flow:getLastError` in the CATCH block to access error details
3. **Type preservation**: `mapSource` and `mapTarget` types must match (String → String)
4. **Status tracking**: Set the status variable in both TRY (success) and CATCH (error) paths
5. **Guaranteed execution**: The FINALLY block runs regardless of the TRY/CATCH outcome

## Test Cases
- **Success**: dividend="10", divisor="2" → result="5", status="SUCCESS"
- **Division by zero**: dividend="10", divisor="0" → status="ERROR", errorMessage populated
- **Negative numbers**: dividend="-20", divisor="4" → result="-5", status="SUCCESS"

## Notable Techniques
- Demonstrates the complete exception-handling lifecycle
- Shows how to extract error information from the lastError record
- Uses `pub.flow:debugLog` for operational visibility
- Maintains type consistency throughout by using String types for `pub.math` services
