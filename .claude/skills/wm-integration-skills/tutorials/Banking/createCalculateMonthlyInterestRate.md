Please generate the FSL code for the following service based on the catalog rules provided in the system instructions:

### 1. Service Definition & Properties
* **Interface Name:** Loans
* **Service Name:** CalculateMonthlyInterestRate
* **Description:** Calculates the flat, recurring monthly payment amount required to fully pay off a loan's principal balance and its accrued interest over a specified duration.

### 2. Define the input and output parameters ensuring you map constraint properties exactly as outlined in the constraint blocks:
* **Inputs:**
  - `interestRate` (Type: String, Constraints: allowNull = false, comment = "The nominal annual interest percentage charged by the lender")
* **Outputs:**
  - `monthlyInterest` (Type: String, Constraints: comment = "The calculated fractional interest rate applied to the remaining principal balance for a single monthly period.")

### 3. Execution Logic (Sequential Flow)
[Note: For the steps below, evaluate the MATH.json catalog file to discover and select the correct built-in service that matches the mathematical intent.]

1. **Step 1 (Convert to Decimal Percentage):** Divide the incoming `interestRate` by a hardcoded value of "100". Map the output of this operation to a transient pipeline variable named `interestPct`.
2. **Step 2 (Convert to Monthly Fraction):** Divide the `interestPct` variable calculated in Step 1 by a hardcoded value of "12". Map the final output of this operation directly to the service output parameter `monthlyInterest`. Drop `value`.
3. **Step 3 (Cleanup):** Add a map and drop `interestPct`, `interestRate`, `num2` and `num1`.