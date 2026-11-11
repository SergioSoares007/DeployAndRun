# REPEAT Step Example

## Overview
This example demonstrates the use of the `REPEAT` step in FSL to implement retry logic with configurable attempts and intervals.

## Flow Service: retryApiCall

### Purpose
Attempts to call an external API with automatic retry logic, tracking the number of attempts and handling failures gracefully.

### Input Parameters
- `apiEndpoint` (String): The URL of the API endpoint to call
- `requestData` (String): The data to send in the API request

### Output Parameters
- `responseData` (String): The response received from the API
- `status` (String): The final status of the operation (SUCCESS/PENDING)
- `attemptCount` (Integer): The number of attempts made

### Logic Flow
1. **Initialize Variables**: Sets `attemptCount` to 0 and `status` to "PENDING"
2. **REPEAT Block**: Configured to retry up to 5 times with 2-second intervals on FAILURE
   - **Increment Attempt Counter**: Adds 1 to `attemptCount` using `pub.math:addInts`
   - **Invoke API**: Calls `pub.client:http` with the endpoint and request data
   - **Set Success Status**: If the call succeeds, sets `status` to "SUCCESS"

### Key FSL Concepts Demonstrated
- **REPEAT Structure**: Using `count`, `repeatInterval`, and `repeatOn` properties
- **Retry Logic**: Automatic retry on FAILURE with configurable intervals
- **Attempt Tracking**: Maintaining a counter across retry attempts
- **System Variables**: The `$retries` system variable is available (0-based index) but not used in this example

### Grammar Rules Applied
- REPEAT block requires `count` property (number of attempts)
- `repeatInterval` specifies wait time between retries (in seconds)
- `repeatOn` determines when to retry ("FAILURE" or "SUCCESS")
- No semicolon after REPEAT closing brace
- Properties inside REPEAT block use colon syntax without semicolons

### Retry Behavior
- **Maximum Attempts**: 5
- **Interval Between Retries**: 2 seconds
- **Retry Condition**: Only retries on FAILURE
- **Success Handling**: Exits immediately on first successful attempt