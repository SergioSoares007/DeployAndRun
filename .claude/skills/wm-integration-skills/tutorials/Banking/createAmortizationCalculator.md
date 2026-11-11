Please generate the FSL code for the following service based on the catalog mapping rules provided in the system instructions:

### 1. Service Definition & Properties
* **Interface Name:** Loans
* **Service Name:** AmortizationCalculator
* **Description:** Calculates the month-by-month repayment schedule of a loan based on the principal amount, interest rate, and loan length.

### 2. Service Signature
Define the input and output parameters ensuring you map constraint properties exactly as outlined in the constraint blocks:
* **Inputs:**
  - `loanAmount` (Type: String, Constraints: allowNull = false, comment = "The total initial sum of money borrowed or the starting balance of the loan before any payments are applied.")
  - `interestRate` (Type: String, Constraints: comment = "The nominal yearly interest percentage charged by the lender (which the AI-assisted service will dynamically convert to a monthly fractional rate for period calculations).")
  - `termYears` (Type: String, Constraints: comment = "The overall lifespan of the loan expressed in years, representing the total operational horizon (which the service will translate into total installment months).")
* **Outputs:**
  - `AmortizationSchedule` (Type: recordList, Constraints: comment = "For every month the loan is active, the engine will dynamically generate a single line item tracking the following five properties:\nPayment Number\nPayment Amount\nInterest Amount\nPrincipal Amount\nEnding Balance")
  - `fixedMonthlyPayment` (Type: String, Constraints: comment = "The baseline regular amount the borrower must pay during each individual installment period to successfully amortize the debt.")
  - `totalInterestPaid` (Type: String, Constraints: comment = "The cumulative cost of borrowing over the entire lifespan of the loan, representing the sum total of all interest charges.")
  - `totalCost` (Type: String, Constraints: comment = "The absolute lifetime cost of the debt, calculated as the original loan amount plus the total interest paid.")
  - `interestRatio` (Type: String, Constraints: comment = "A financial efficiency metric representing the percentage of the lifetime cost eaten up by interest charges rather than equity.")
  - `trueCostFactor` (Type: String, Constraints: comment = "A strategic multiplier that compares the total lifetime cost of the loan back to the original principal amount (indicating how many times over the borrower is paying for the asset).")
  - `tippingPointMonth` (Type: String, Constraints: comment = "The exact calendar month during the lifecycle of the loan where the monthly principal allocation permanently eclipses the monthly interest charge.")
  - `fiveYearEquity` (Type: String, Constraints: comment = "The total principal paid down by the borrower at the exact 60-month mark, showing real asset ownership after five years.")

### 3. Execution Logic (Sequential Flow & Mappings)
[Discovery Instruction: Evaluate your catalog files to match the intents described below to the proper underlying utility services and variables.]

#### Step 1: Input Validation & Parsing (Inline Transformer Block)
* Create an inline `MAP` step with comment: `"This step is used to validate the inputs and ensure they are numeric."`
* Within the MAP, apply primitive parsing type `TRANSFORMs` to handle the following conversions:
    * Convert `loanAmount` (String) to `nLoanAmount` (Double).
    * Convert `interestRate` (String) to `nInterestRate` (Double).
    * Convert `termYears` (String) to `nTermYears` (Integer), mapping `convertAs` to `"java.lang.Integer"`.

#### Step 2: Establish Loan Terms & Payments
1. **Calculate Monthly Interest Rate:**
   * Invoke `Loans:CalculateMonthlyInterestRate`. Map `interestRate` input to itself, and receive `monthlyInterest` as output.
2. **Calculate Total Number of Payments:**
   * Invoke an integer multiplication utility to multiply `termYears` by hardcoded value `"12"`. Save the result to a transient pipeline string named `totalNumberOfPayments`.
3. **Calculate Fixed Monthly Payment Amount:**
   * Invoke `Loans:CalculateFixedMonthlyPrincipalAndInterestPayment`. Map `loanAmount` to `loanAmount`, `monthlyInterest` to `monthlyInterestRate`, and `totalNumberOfPayments` to `totalMonths`. Map the output `payment` to the signature output parameter `fixedMonthlyPayment`.

#### Step 3: Loop Initialization
* Create a `MAP` step establishing loop variables:
  * Initialize `currentBalance` with `loanAmount`.
  * Set `cumulativeInterest` = `"0"`, `cumulativePrincipal` = `"0"`, and `month` = `"0"`.
  * Establish an accumulation array structure named `AmortizationScheduleAccum` (type recordList) initialized with an initial single element row containing `Deleteme: "0"`.
  * Set tracker variables: `fiveYearEquityHold` mapped from `loanAmount`, `monthlyPrincipalPaidHold` (Double) = `0.0`, `monthlyInterestOwedHold` (Double) = `0.0`, `iterationCountHold` (Integer) = `1`, and `tippingPointMonthHold` (Integer) = `1`.
  * Within the same map, drop transient intermediate inputs: `nLoanAmount`, `nInterestRate`, and `nTermYears`.

#### Step 4: Generate the Amortization Schedule (Loop Block)
Execute a `WHILE` loop tracking condition `(month < totalNumberOfPayments)`:

1. **Row Initialization:** Inside a `MAP` block, target a row structure named `AmortizationScheduleRow` that complies with the schema `Loans:AmortizationSchedule` (allowing unspecified fields). Pre-initialize fields `paymentNumber`, `paymentAmount`, `interestAmount`, `principalAmount`, and `endingBalance` all to `"0"`.
2. **Interest Calculation:** Apply a float multiplication `TRANSFORM` within a structural `MAP` step (with `precision` = `"2"`) to multiply `currentBalance` by `monthlyInterest`. Target the results directly into `monthlyInterestOwed`.
3. **Principal Calculation:** Apply a float subtraction `TRANSFORM` within a structural `MAP` step (with `precision` = `"2"`) to subtract `monthlyInterestOwed` from `fixedMonthlyPayment`. Target the results directly into `monthlyPrincipalPaid`.
4. **Update Balance:** Apply a float subtraction `TRANSFORM` within a structural `MAP` step (with `precision` = `"2"`) to subtract `monthlyPrincipalPaid` from `currentBalance`. Update `currentBalance` with this value.
5. **Update Accumulators (part 1):** Inline within a unified tracking `MAP` step:
   * Apply a float addition `TRANSFORM` (`precision` = `"2"`) to add `monthlyInterestOwed` to `cumulativeInterest`.
6. **Update Accumulators (part 2):** Inline within a unified tracking `MAP` step:
   * Apply a float addition `TRANSFORM` (`precision` = `"2"`) to add `monthlyPrincipalPaid` to `cumulativePrincipal`.
7. **Apply Row Formatting:** Inside a single structural `MAP` step, establish an output definition contract for the row schema. Execute the following actions together:
    * Copy the loop tracking variable `$iterationCount` directly down into the `paymentNumber` field located inside the `AmortizationScheduleRow` parent record.
    * Format the following numeric values as currency strings with the pattern $#,##0.00. When configuring its target output block, **do not write flat, slashed path declarations**. Instead, explicitly open a nested structural block container for the `AmortizationScheduleRow` record, and place the individual target fields inside it before tracing your final mapping paths:
        * `fixedMonthlyPayment` mapping into nested field -> `paymentAmount`
        * `monthlyInterestOwed` mapping into nested field -> `interestAmount`
        * `monthlyPrincipalPaid` mapping into nested field -> `principalAmount`
        * `currentBalance` mapping into nested field -> `endingBalance`
    * Apply primitive parsing type `TRANSFORMs` to handle explicit structural conversions for tracking variables:
        * Convert `monthlyPrincipalPaid` to a `Double` -> `monthlyPrincipalPaidHold`
        * Convert `monthlyInterestOwed` to a `Double` -> `monthlyInterestOwedHold`
        * Convert `$iterationCount` to an `Integer` -> `iterationCountHold`
    * Apply primitive parsing type `TRANSFORMs` to handle explicit structural conversions for tracking variables:
        * Convert `monthlyPrincipalPaid` to a `Double` -> `monthlyPrincipalPaidHold`
        * Convert `monthlyInterestOwed` to a `Double` -> `monthlyInterestOwedHold`
        * Convert `$iterationCount` to an `Integer` -> `iterationCountHold`
8. **Find Interest Tipping Point (Evaluated Label Branching):**
   * Establish a top-level `BRANCH` step configured with `evaluateLabels: true`. 
   * Inside a nested execution `SEQUENCE`, set its conditional execution `label` string precisely to check if `%tippingPointMonthHold% == 1 && %monthlyPrincipalPaidHold% > %monthlyInterestOwedHold%`.
   * When that sequence executes, nest a second `BRANCH` step also configured with `evaluateLabels: true`.
   * Within this second branch, place a structural `MAP` step with a conditional execution `label` string set to evaluate `%iterationCountHold% > 1`.
   * Inside this map block, convert the string iteration variable into a numeric `tippingPointMonthHold` matching a `"java.lang.Integer"` configuration.
9. **Append Row to Accumulator Array:**
   * Inserts a new document, `AmortizationScheduleRow` into `AmortizationScheduleAccum`.
10. **Capture 5-Year Equity State:**
   * Check if loop count `$iterationCount == 60`. If so, save the snapshot of `cumulativePrincipal` directly into `fiveYearEquityHold`.
11. **Loop Step Increments:**
    * Map `$iterationCount` to `month`.

#### Step 5: Post-Loop Calculation & Pipeline Cleanup
Create consecutive standalone processing mapping blocks to finalize output parameters:
1. **Clean Array Baseline & Calculate Total Cost:** Inside a single structural `MAP` step, execute the following inline operations sequentially:
    * Apply an array modification `TRANSFORM` and delete the document at index `["0"]` from `AmortizationScheduleAccum`.
    * Apply a mathematical arithmetic `TRANSFORM` (with `precision` = `"2"`) to add `cumulativeInterest` and `loanAmount` together, targeting the final calculated result into the signature output field `totalCost`.
2. **Calculate Financial Ratios & Final Formatting:** Inside a single structural `MAP` step, execute the following inline operations simultaneously:
    * Apply a mathematical division `TRANSFORM` (with `precision` = `"2"`) to divide `cumulativeInterest` by `totalCost`, targeting the final result into the signature output field `interestRatio`.
    * Apply a mathematical division `TRANSFORM` (with `precision` = `"2"`) to divide `totalCost` by `loanAmount`, targeting the final result into the signature output field `trueCostFactor`.
    * Convert `tippingPointMonthHold` to string and copy to `tippingPointMonth`.
3. **Final Output Field Formatting & Pipeline Cleanup:** Inside a single structural `MAP` step, execute the following final pipeline actions:
   
   * **Array Migration:** Move the structural collection array `AmortizationScheduleAccum` directly into the official signature output field `AmortizationSchedule`.
   
   * **Currency Formatting:** Format the following numeric values as currency strings with the pattern $#,##0.00 to convert the final tracking accumulators into text-based signature outputs:
     * `fiveYearEquityHold` -> `fiveYearEquity`
     * `cumulativeInterest` -> `totalInterestPaid`
     * `fixedMonthlyPayment` -> `fixedMonthlyPayment`
     * `totalCost` -> `totalCost`
     
   * **Pipeline Environment Cleanup:** Drop the following 26 fields:
     
     *Workspace Inputs:*
     1. `loanAmount`
     2. `interestRate`
     3. `termYears`
     4. `monthlyInterestRate`
     5. `totalMonths`
     6. `totalNumberOfPayments`
     
     *Loop & Temporary Variables:*
     7. `monthlyInterest`
     8. `value`
     9. `iterationCountHold`
     10. `monthlyInterestOwedHold`
     11. `monthlyPrincipalPaidHold`
     12. `fiveYearEquityHold`
     13. `monthlyPrincipalPaid`
     14. `cumulativePrincipal`
     15. `cumulativeInterest`
     16. `month`
     17. `payment`
     18. `currentBalance`
     19. `monthlyInterestOwed`
     20. `tippingPointMonthHold`
     
     *Objects, Arrays & Utilities:*
     21. `documents`
     22. `insertDocument`
     23. `AmortizationScheduleAccum`
     24. `AmortizationScheduleRow`
     25. `num1`
     26. `num2`

