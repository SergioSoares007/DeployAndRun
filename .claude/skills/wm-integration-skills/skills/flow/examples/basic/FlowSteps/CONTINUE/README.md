# continueSkipZeroPrices

## Purpose
- Demonstrates valid `CONTINUE` usage in FSL.
- Uses a `DO ... UNTIL` loop because `CONTINUE` is not allowed in `LOOP`.

## Input
- `maxCount` (String): upper bound for loop iterations

## Output
- `processedCount` (String): number of iterations processed excluding the skipped one
- `currentCount` (String): current loop counter
- `skippedMessage` (String): static note describing the skipped iteration
- `one` (String): increment helper value

## Key Implementation Details
- Initializes `processedCount`, `currentCount`, `skippedMessage`, and `one` in a `MAP`.
- Increments `currentCount` first inside the `DO` block.
- Uses `IF (%currentCount% == "2") { CONTINUE }` to skip one iteration.
- Increments `processedCount` only when the iteration is not skipped.
- Uses `pub.math:addInts` with `String` pipeline values.

## Notable Patterns
- `CONTINUE` is valid only inside `DO` or `WHILE`.
- For skip-style iteration logic, prefer `DO`/`WHILE` over `LOOP`.
