# whileLoop

## Purpose
- WHILE example that returns `Y = 2 * X`.
- Demonstrates a Designer-compatible loop by using an explicit counter.

## Flow File
- `skills/flow/examples/basic/FlowSteps/WHILE/whileLoopDouble.flow`

## Input
- `X` (String): number of loop iterations

## Output
- `Y` (String): result after adding `2`, `X` times

## Key Implementation Details
- Initialize `Y = "0"` and `counter = "0"` before the loop.
- Use `WHILE (%counter% < %X%)`.
- Increment `Y` with `pub.math:addInts`.
- Increment `counter` with a separate `pub.math:addInts`.
- Use direct `copy`/`set` mappings inside `INVOKE pub.math:addInts` input/output blocks.

## Notable Patterns
- Prefer explicit counter variables for runnable WHILE examples.
- Prefer `String` pipeline values for `pub.math:addInts`.
- Avoid nested `mapSource`/`mapTarget` mappings when Designer fails to populate `num1`/`num2`.