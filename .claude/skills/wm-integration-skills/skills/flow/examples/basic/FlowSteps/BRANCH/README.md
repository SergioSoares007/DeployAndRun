# routeByCustomerType

**Purpose:** Demonstrates BRANCH step with switch-based routing using literal value matching and special case handling ($null, $default).

**Location:** `skills/flow/examples/basic/FlowSteps/BRANCH/routeByCustomerType.flow`

## Service Signature

**Input:**
- `String customerType` - Customer classification used for routing
- `Double orderAmount` - Order amount (included in signature but not used in logic)

**Output:**
- `String discountLevel` - Assigned discount tier
- `String message` - Descriptive routing message

## Implementation Details

**BRANCH Configuration:**
- `switch: "/customerType"` - Routes based on customerType variable
- `evaluateLabels: false` - Uses literal string matching (not expressions)

**Routing Cases:**
- `VIP` → PREMIUM discount
- `CORPORATE` → BUSINESS discount
- `STANDARD` → REGULAR discount
- `$null` → NONE (handles missing/empty customerType)
- `$default` → BASIC (handles unknown customer types)

**Key Patterns:**
- Each SEQUENCE contains a MAP block for output assignment
- Special handling for null and default cases
- Case-sensitive literal matching (e.g., "VIP" ≠ "vip")
- No semicolon after BRANCH closing brace

## Test Cases

| Input customerType | Expected discountLevel | Expected message |
|-------------------|----------------------|------------------|
| VIP | PREMIUM | VIP customer receives premium discount |
| CORPORATE | BUSINESS | Corporate customer receives business discount |
| STANDARD | REGULAR | Standard customer receives regular discount |
| (null/missing) | NONE | Customer type not provided |
| GUEST (or any unknown) | BASIC | Unknown customer type receives basic discount |
| vip (lowercase) | BASIC | Unknown customer type receives basic discount |

## FSL Syntax Demonstrated

- BRANCH structure with switch property
- evaluateLabels: false for literal matching
- Multiple SEQUENCE blocks as routing targets
- $null handling for missing values
- $default handling for fallback cases
- MAP blocks for output assignment
- Proper block termination (no semicolons after closing braces)
