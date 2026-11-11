# breakOnThreshold

## Purpose
- Demonstrates valid `BREAK` usage in FSL within a DO-UNTIL loop
- Shows workaround for numeric comparison with String types using pub.math services

## Input
- `threshold` (String): the value at which to break the loop

## Output
- `counter` (String): final counter value when loop terminated
- `breakMessage` (String): static message describing loop termination
- `one` (String): increment helper value

## Key Implementation Details
- Initializes `counter`, `breakMessage`, and `one` in a MAP
- Uses DO-UNTIL loop (BREAK is valid in DO/WHILE, not in LOOP)
- Increments counter using `pub.math:addInts`
- **Critical Pattern**: Performs numeric comparison by calculating `diff = counter - threshold` using `pub.math:subtractInts`
- Checks `IF (%diff% >= "0")` to determine when counter has reached or exceeded threshold
- Uses `BREAK` to exit loop early when threshold is met
- Loop continues until counter reaches 100 or BREAK executes

## Notable Patterns
- **String Comparison Workaround**: FSL conditions compare strings lexicographically, not numerically. To perform numeric comparison with String types, use `pub.math:subtractInts` to calculate the difference, then check if result >= "0"
- `BREAK` is valid only inside `DO` or `WHILE` loops, not `LOOP`
- For conditional early exit from loops, prefer `DO`/`WHILE` over `LOOP`
