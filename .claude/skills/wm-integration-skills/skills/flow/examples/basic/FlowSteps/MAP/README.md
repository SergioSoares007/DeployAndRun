# calculateDiscount

## Purpose
Calculates the discount amount and final price for a product given its original price and discount percentage.

## Interface
- **Package**: testFlows
- **Service Name**: calculateDiscount

## Input Parameters
- `originalPrice` (String): The original price of the product
- `discountPercent` (String): The discount percentage to apply (e.g., "20" for 20%)

## Output Parameters
- `discountAmount` (String): The calculated discount amount
- `finalPrice` (String): The final price after applying the discount

## Implementation Details

### Step 1: Convert Discount Percentage to Rate
**Service**: `pub.math:divideFloats`
- Divides the discount percentage by 100 to get the discount rate
- Input: `discountPercent` → `num1`, constant "100" → `num2`
- Output: `value` → `discountRate`

### Step 2: Calculate Discount Amount
**Service**: `pub.math:multiplyFloats`
- Multiplies the original price by the discount rate
- Input: `originalPrice` → `num1`, `discountRate` → `num2`
- Output: `value` → `discountAmount`

### Step 3: Calculate Final Price
**Service**: `pub.math:subtractFloats`
- Subtracts the discount amount from the original price
- Input: `originalPrice` → `num1`, `discountAmount` → `num2`
- Output: `value` → `finalPrice`

## Example Usage

### Input
```
originalPrice: "100.00"
discountPercent: "20"
```

### Output
```
discountAmount: "20.00"
finalPrice: "80.00"
```

## Key Patterns
- **Sequential Math Operations**: Demonstrates chaining multiple math operations where the output of one becomes the input to the next
- **Constant Values**: Shows how to set constant values in mapping (e.g., "100" for percentage conversion)
- **Float Arithmetic**: Uses float-based math services for precise decimal calculations
- **Pipeline Data Flow**: Each step builds on the previous step's output, creating a clear data transformation pipeline

## Notes
- All numeric values are handled as strings, which is standard for webMethods Integration Server
- The discount percentage is expected as a whole number (e.g., "20" for 20%, not "0.20")
- The service uses float operations to maintain precision for monetary calculations
