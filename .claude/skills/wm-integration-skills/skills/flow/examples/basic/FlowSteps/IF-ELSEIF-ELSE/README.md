# validateOrderAmount

**Purpose:** Demonstrates IF/ELSEIF/ELSE conditional logic for order validation based on amount thresholds.

**Location:** `skills/flow/examples/basic/FlowSteps/IF-ELSEIF-ELSE/validateOrderAmount.flow`

## Service Signature

**Input:**
- `Double orderAmount` - The order amount to validate

**Output:**
- `String validationStatus` - Validation result (APPROVED, PENDING, REJECTED)
- `String message` - Descriptive message about the validation result

## Implementation Details

**Conditional Logic:**
- IF orderAmount > 1000: High value order (APPROVED)
- ELSEIF orderAmount > 100: Standard order (APPROVED)
- ELSEIF orderAmount > 0: Low value order (PENDING)
- ELSE: Invalid amount (REJECTED)

**Key Patterns:**
- Uses `%variable%` syntax in conditions for pipeline variable references
- Each conditional branch contains a MAP block to set output variables
- Demonstrates proper IF/ELSEIF/ELSE chaining
- No semicolons after block closing braces
- Proper use of comparison operators in conditions

## FSL Syntax Demonstrated

- IF/ELSEIF/ELSE structure
- Condition syntax with `%orderAmount%`
- MAP blocks for variable assignment
- Multiple `set` operations within single MAP block
- Proper block termination rules
