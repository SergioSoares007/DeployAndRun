# incrementUntilTarget

## Purpose
Demonstrates DO-UNTIL loop pattern with counter increment using pub.math:addInts.

## Implementation Details
- Initializes counter and increment variables before the loop
- Uses DO-UNTIL structure with maxIteration safety limit
- Wraps INVOKE in SEQUENCE block (required for DO-UNTIL context)
- Uses copy for both num1 and num2 parameters (no literal values)
- All variables are String type (required for pub.math services)

## Input
- `targetValue` (String): The target value to reach

## Output
- `counter` (String): Final counter value
- `message` (String): Completion message

## Key Pattern
```fsl
MAP {
    set counter = "0";
    set increment = "1";
}
DO {
    maxIteration: 100
    SEQUENCE {
        INVOKE pub.math:addInts {
            input {
                copy counter -> num1;
                copy increment -> num2;
            }
            output {
                copy value -> counter;
            }
        }
    }
} UNTIL (%counter% >= %targetValue%)
```

## Critical Requirements
1. Initialize ALL variables before the loop
2. Use String types for all numeric variables
3. Use copy for BOTH parameters (never set literals)
4. Wrap INVOKE in SEQUENCE block within DO-UNTIL
5. Variables in UNTIL condition must use %variable% syntax

## Related
- See known-fixes/pub-math-missing-parameter-num1.md for troubleshooting
- See WHILE/whileLoopDouble.flow for similar pattern in WHILE context
