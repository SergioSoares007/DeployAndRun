# Service Documentation Configuration

### Instructions
1. Ensure the markdown file matches information in the FSL files, but format it for human legibility using organized Markdown headings, blocks, lists, and bold callouts.
2. Structure the file according to the required template below:
    - **Service Name & Interface Title**
    - **Service Purpose Description** (Extracted from properties block)
    - **Inputs Table/List** (Name, Type, Constraints, and clear business descriptions)
    - **Outputs Table/List** (Name, Type, and multi-line/single-line documentation blocks)
    - **Service Purpose & Field Descriptions (Deduction & Fallback Rules):**
        - **Missing Service Comment:** If the top-level `comment` property is omitted in the FSL `properties` block, dynamically infer the overall business purpose first from the literal **Service Name** itself, and second by analyzing the sequence of internal pipeline modifications, structural mappings, or any invoked services inside the flow logic.
        - **Missing Field Comments:** If any input or output field lacks an explicit inline `comment` string, deduce a clear business description based on the field's variable name, its technical data type, and how it is manipulated, checked, or transformed throughout the service logic (even if no external services are called).
        - **Fallback Text:** If a field's purpose cannot be confidently inferred from its name or logic, do not leave it blank; populate the description with a professional, context-aware placeholder based on its name (e.g., "The target identifier for this operation.").
### Target Markdown Format Reference
Ensure generated `.md` companion files match this exact visual representation:
````markdown
# Service Documentation: Loans:AmortizationCalculator

## Purpose
Calculates the month-by-month repayment schedule of a loan based on the principal amount, interest rate, and loan length.

## Service Signature

### Inputs
* **`loanAmount`** (Type: `String`)  
  *Constraints:* `allowNull: false`  
  *Description:* The total initial sum of money borrowed or the starting balance of the loan before any payments are applied.
* **`interestRate`** (Type: `String`)  
  *Description:* The nominal yearly interest percentage charged by the lender (which the AI-assisted service will dynamically convert to a monthly fractional rate for period calculations).
* **`termYears`** (Type: `String`)  
  *Description:* The overall lifespan of the loan expressed in years, representing the total operational horizon (which the service will translate into total installment months).

### Outputs
* **`AmortizationSchedule`** (Type: `recordList`)  
  *Description:* For every month the loan is active, the engine will dynamically generate a single line item tracking the following five properties:
  - Payment Number
  - Payment Amount
  - Interest Amount
  - Principal Amount
  - Ending Balance
* **`fixedMonthlyPayment`** (Type: `String`)  
  *Description:* The baseline regular amount the borrower must pay during each individual installment period to successfully amortize the debt.
* **`totalInterestPaid`** (Type: `String`)  
  *Description:* The cumulative cost of borrowing over the entire lifespan of the loan, representing the sum total of all interest charges.
* **`totalCost`** (Type: `String`)  
  *Description:* The absolute lifetime cost of the debt, calculated as the original loan amount plus the total interest paid.
* **`interestRatio`** (Type: `String`)  
  *Description:* A financial efficiency metric representing the percentage of the lifetime cost eaten up by interest charges rather than equity.
* **`trueCostFactor`** (Type: `String`)  
  *Description:* A strategic multiplier that compares the total lifetime cost of the loan back to the original principal amount (indicating how many times over the borrower is paying for the asset).
* **`tippingPointMonth`** (Type: `String`)  
  *Description:* The exact calendar month during the lifecycle of the loan where the monthly principal allocation permanently eclipses the monthly interest charge.
* **`fiveYearEquity`** (Type: `String`)  
  *Description:* The total principal paid down by the borrower at the exact 60-month mark, showing real asset ownership after five years.
````
