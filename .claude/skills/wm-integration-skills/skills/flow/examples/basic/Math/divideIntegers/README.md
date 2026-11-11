# divideIntegers

## Purpose
Demonstrates basic integer division by using the `pub.math:divideInts` service.

## Implementation
- The service accepts two string inputs: `num1` and `num2`
- Invokes `pub.math:divideInts` by using direct parameter mapping
- Returns the division result as a string

## Input and Output
**Input:**
- `num1` (String): Dividend
- `num2` (String): Divisor

**Output:**
- `result` (String): Quotient of `num1` divided by `num2`

## Key Patterns
- Uses string types throughout, following the `pub.math` service conventions
- Direct copy mapping: input variables → service parameters
- Output mapping: service value → result variable
- `mapSource` and `mapTarget` use matching variable names for clarity

## Notes
- `pub.math` services accept string inputs for numeric operations
- Type preservation: String in `mapSource` matches String in `mapTarget`
- Division by zero must be handled by the calling service
