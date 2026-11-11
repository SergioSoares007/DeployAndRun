# EXIT Step Example

## Overview
This example demonstrates the use of the `EXIT` step in FSL to terminate flow execution based on error severity levels.

## Flow Service: handleCriticalError

### Purpose
Handles errors with different severity levels, using EXIT to immediately terminate the flow for critical errors while allowing continued execution for less severe issues.

### Input Parameters
- `errorCode` (String): The error code identifier
- `errorMessage` (String): The detailed error message
- `severity` (String): The severity level (CRITICAL, HIGH, or other)

### Output Parameters
- `status` (String): The final status of error handling
- `finalMessage` (String): A message describing the outcome

### Logic Flow
1. **Check for CRITICAL Severity**:
   - Logs the error message using `pub.flow:debugLog`
   - **EXIT Block**: Terminates the entire flow with FAILURE signal
   - Uses `exitFrom: "$flow"` to exit at service level
   - Provides a failure message explaining the termination

2. **Check for HIGH Severity**:
   - Logs the error message
   - Sets status to "WARNING" and continues execution
   - Does not terminate the flow

3. **Handle Other Severities**:
   - Sets status to "INFO"
   - Continues normal execution

### Key FSL Concepts Demonstrated
- **EXIT Structure**: Using `exitFrom`, `signal`, and `failureMessage` properties
- **Flow Termination**: Immediate exit from the service using `$flow` scope
- **Signal Types**: Using "FAILURE" signal to indicate abnormal termination
- **Conditional Exit**: EXIT only triggered for specific conditions (CRITICAL errors)
- **Graceful Degradation**: Different handling strategies based on severity

### Grammar Rules Applied
- EXIT block requires `exitFrom` property (not `from`)
- Valid `exitFrom` scopes: `$flow` (service level), `$parent` (container level), `$loop` (loop level)
- `signal` property is optional but recommended for clarity ("SUCCESS" or "FAILURE")
- `failureMessage` provides context for the exit
- No semicolon after EXIT closing brace
- Properties inside EXIT block use colon syntax without semicolons

### Exit Scopes
- **`$flow`**: Exits the entire flow service (used in this example)
- **`$parent`**: Exits the parent container (SEQUENCE, LOOP, etc.)
- **`$loop`**: Exits the current loop iteration (use BREAK instead for this)

### When to Use EXIT vs BREAK/CONTINUE
- **EXIT**: Use to terminate the entire flow or parent container
- **BREAK**: Use to exit a loop early
- **CONTINUE**: Use to skip to the next loop iteration
- **EXIT is NOT for loop control** - use BREAK/CONTINUE for loops