# routeByOrderStatus

**Purpose:** Demonstrates `SWITCH`-based routing in FSL using a single input status to drive different output assignments.

**Location:** `skills/flow/examples/basic/FlowSteps/SWITCH/routeByOrderStatus.flow`

## Service Signature

**Input:**
- `String orderStatus` - Order lifecycle status used by the `SWITCH` operation

**Output:**
- `String action` - Action selected for the status
- `String message` - Descriptive routing message

## Implementation Details

**Switch Cases:**
- `NEW` → `CREATE`
- `PROCESSING` → `UPDATE`
- `SHIPPED` → `NOTIFY`
- `$default` → `REVIEW`

**Key Patterns:**
- Uses `SWITCH (variableName)` syntax — bare variable name, no `%` signs, no quotes, no path notation
- Uses `CASE "value" :` labels for explicit branches
- Uses `CASE "$default" :` for fallback handling
- Each `CASE` arm owns exactly one direct child step; wrap multiple steps in a `SEQUENCE` block
- Each case contains a single `MAP` block (no `SEQUENCE` needed)
- No semicolon after the closing brace of the `SWITCH` block

## ⚠️ Critical Syntax Rules

| | Correct | Incorrect |
|---|---|---|
| Switch expression | `SWITCH (orderStatus)` | `SWITCH (%orderStatus%)` |
| Switch expression | `SWITCH (orderStatus)` | `SWITCH ("/orderStatus")` |
| Multiple steps in a case | `CASE "X" : SEQUENCE { ... }` | `CASE "X" : INVOKE ... INVOKE ...` |

## SWITCH vs BRANCH

`SWITCH` and `BRANCH` are **different constructs** — do not mix their syntax:

| | `SWITCH` | `BRANCH` |
|---|---|---|
| Switch target | Bare variable name: `SWITCH (var)` | Path string: `switch: "/var"` |
| Case arm | `CASE "value" :` | `SEQUENCE { label: "value" }` |
| Multiple steps | Requires `SEQUENCE` wrapper | Steps go directly inside `SEQUENCE` |

## FSL Syntax Demonstrated

- `SWITCH` structure with bare variable name expression
- `CASE` labels with string literals
- Default case handling with `"$default"`
- `MAP` blocks inside switch cases
- Output assignment with multiple `set` statements
- Proper block termination rules
