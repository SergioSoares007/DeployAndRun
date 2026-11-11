Please generate the FSL code for the following service based on the catalog mapping rules provided in the system instructions:

### 1. Service Definition & Properties
* **Interface Name:** orders
* **Service Name:** processOrder
* **Description:** Process incoming shopping cart storefront orders by iterating over item arrays to compute totals, applying customer tier discounts, and formatting financial outputs.

### 2. Service Signature
Define the input and output parameters ensuring you map constraint properties exactly as outlined in the constraint blocks:
* **Inputs:**
  - `orderId` (Type: String, Constraints: allowNull = false)
  - `customerId` (Type: String, Constraints: allowNull = false)
  - `items` (Type: recordList, Constraints: allowUnspecifiedFields = true)
    * Contains child leaf fields:
      - `productid` (Type: String, Constraints: allowNull = false)
      - `itemName` (Type: String)
      - `quantity` (Type: String, Constraints: allowNull = false)
      - `price` (Type: String, Constraints: allowNull = false)
  - `customerType` (Type: String, Constraints: required = false)
* **Outputs:**
  - `orderTotalBeforeDiscount` (Type: String)
  - `discountApplied` (Type: String)
  - `orderTotal` (Type: String)
  - `orderStatus` (Type: String)
  - `message` (Type: String)

---

### 3. Implementation Steps & Pipeline Logic

Execute the structural steps of the service workflow following these rules:

#### Step 1: Initialize Workspace Accumulators
* Establish an initial calculation baseline using a single `MAP` step.
* Initialize `discountApplied` to `"0.0"`.
* Initialize `orderTotal` to `"0.0"`.

#### Step 2: Process the Line Items Loop
Create a standard sequential execution `LOOP` block to process every item row inside the order.
* **Loop Configuration:** Set `inputArray` to `"/items"`, `maxThreads` to `"1"`, and configure `parallelErrorHandling` to `"reportError"`.
* **Line Item Total Calculation:** Inside the loop, multiply the loop item's price field (path: items/price) by its quantity field (path: items/quantity) and map the resulting value out to a local tracking variable named lineTotal.
* **Running Balance Accumulation:** Directly after calculating the line total, add `lineTotal` to `orderTotal` and save the sum back into `orderTotal`.

#### Step 3: Capture Pre-Discount Gross Baseline
* Use a standalone `MAP` step to copy `orderTotal` into `orderTotalBeforeDiscount`.

#### Step 4: Apply Customer Classification Discounts
* Apply customer-specific discounts to the order total based on the `customerType` and `orderTotal`, and save the result into `orderTotal`.

#### Step 5: Final Formatting and Pipeline Cleanup
In a single `MAP` block, perform the final formatting and clean the pipeline environment:
* **Currency Formatting:** Format the fields `orderTotal`, `discountApplied`, and `orderTotalBeforeDiscount` into currency strings using the pattern `"$#,##0.00"`.
* **Pipeline Cleanup:** Drop all temporary workspace variables from the active pipeline context, specifically removing: `num1`, `num2`, `orderTotalAfterDiscount`, `lineTotal` and `value`.
