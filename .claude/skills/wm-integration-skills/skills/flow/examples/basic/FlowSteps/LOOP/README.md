# LOOP Step Example

## Overview
This example demonstrates the use of the `LOOP` step in FSL to iterate over a recordList and perform calculations on each item.

## Flow Service: processOrderItems

### Purpose
Processes a list of order items by calculating line totals and maintaining running totals for the entire order.

### Input Parameters
- `items` (recordList): A list of order items containing:
  - `productId` (String): The product identifier
  - `quantity` (Integer): The quantity ordered
  - `price` (Double): The unit price

### Output Parameters
- `totalAmount` (Double): The sum of all line totals
- `itemCount` (Integer): The total number of items processed

### Logic Flow
1. **Initialize Counters**: Sets `totalAmount` and `itemCount` to 0
2. **LOOP Over Items**: Iterates through each item in the `items` recordList
   - **Calculate Line Total**: Multiplies `quantity` by `price` using `pub.math:multiplyObjects`
   - **Add to Running Total**: Adds the line total to `totalAmount` using `pub.math:addObjects`
   - **Increment Counter**: Increments `itemCount` by 1 using `pub.math:addInts`

### Key FSL Concepts Demonstrated
- **LOOP Structure**: Using `inputArray` property to specify the recordList to iterate over
- **Automatic Field Scoping**: Fields from the loop variable (`quantity`, `price`) are automatically in scope
- **Running Totals**: Maintaining accumulator variables across loop iterations
- **Type Preservation**: Mapping Integer to Integer and Double to Double in TRANSFORM blocks

### Grammar Rules Applied
- LOOP block requires `inputArray` property pointing to the recordList path
- No semicolon after LOOP closing brace
- Fields from the loop variable are declared directly in mapSource without parent record structure
- TRANSFORM blocks used within MAP steps for service invocations

### 🚨 Critical LOOP Constraints
- **BREAK is FORBIDDEN inside LOOP** — using `BREAK` inside a `LOOP` causes a runtime error: *"BREAK statement is not allowed outside of DO or WHILE loops"*. Use `EXIT { exitFrom: "$parent" }` instead for early exit.
- **Slash-path variables are FORBIDDEN in conditions** — `%recordList/field%` is not valid inside `IF`/`WHILE` conditions. Extract the field to a flat variable via a `MAP` block first, then use `%flatVar%` in the condition.
- **Early exit pattern**: Set a `String matched = "false"` flag, use `EXIT { exitFrom: "$parent" }` on match, then check the flag after the LOOP.