# addIntegers

## Purpose
Demonstrates basic integer addition by using the `pub.math:addInts` service.

## Implementation
- The service accepts two string inputs: `num1` and `num2`
- Invokes `pub.math:addInts` by using direct parameter mapping
- Returns the addition result as a string

## Input and Output
**Input:**
- `num1` (String): First number
- `num2` (String): Second number

**Output:**
- `result` (String): Sum of `num1` and `num2`

## Key Patterns
- Uses string types throughout, following the `pub.math` service conventions
- Direct copy mapping: input variables → service parameters
- Output mapping: service value → result variable
- `mapSource` and `mapTarget` use matching variable names for clarity

## Notes
- `pub.math` services accept string inputs for numeric operations
- Type preservation: String in `mapSource` matches String in `mapTarget`
