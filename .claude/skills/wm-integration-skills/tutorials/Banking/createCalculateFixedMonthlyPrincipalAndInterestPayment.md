Please generate the FSL code for the following service based on the catalog mapping rules provided in the system instructions:

### 1. Service Definition & Properties
* **Interface Name:** Loans
* **Service Name:** CalculateFixedMonthlyPrincipalAndInterestPayment
* **Description:** "Calculates the fixed monthly payment amount (principal plus interest) required to fully amortize a loan balance to zero over a specified timeline. Called as a helper routine by AmortizationCalculator."

### 2. Service Signature
Define the input and output parameters ensuring you map constraint properties exactly as outlined in the constraint blocks:
* **Inputs:**
  - `loanAmount` (Type: String, Constraints: allowNull = false, comment = "The total initial sum of money borrowed (the principal balance)")
  - `monthlyInterestRate` (Type: String, Constraints: allowNull = false, comment = "The nominal yearly rate converted down to a monthly fractional decimal.")
  - `totalMonths` (Type: String, Constraints: allowNull = false, comment = "The total lifespan of the loan expressed as individual payment periods.")
* **Outputs:**
  - `payment` (Type: String, Constraints: comment = "The calculated, fixed monthly amount (principal plus interest) required to fully amortize the loan balance down to zero over the specified number of months.")

### 3. Execution Logic (Sequential Flow & Mappings)
[Discovery Instruction: Evaluate the `MATH.json` and `BANKING.json` catalog files to match the intents described below to the proper underlying services and variables.]

#### Step 1: Parse Rate Type (Inline Transformer Block)
* Create an inline `MAP` transformer step with comment "Validate input".
* Convert the string-typed `monthlyInterestRate` parameter into a native numeric representation to track checking conditions. 
* Map the source `monthlyInterestRate` into the utility's source argument, and assign the output object to a transient pipeline field named `monthlyInterestRateNum` of type Double.

#### Step 2: Conditional Pricing Path (IF/ELSE Structure)
* Evaluate if the transient tracking value `monthlyInterestRateNum` is NOT equal to `0.0`.

##### --- Path A: IF interest rate is non-zero (Compounding Growth Calculation) ---
Execute the following inline variable transformations sequentially inside individual `MAP` blocks:

1. **Calculate Base Base Value:** * Comment: "The baseline for the compounding growth calculation"
   * Add 1 to the incoming pipeline variable `monthlyInterestRate`.
   * Save the result to a new pipeline string named `baseValue`.
2. **Calculate Growth Factor:**
   * Comment: "Growth Factor"
   * Look up the power utility in the banking context (`BANKING.json`). Raise the calculated `baseValue` to the power of `totalMonths`.
   * Save the result to a pipeline string named `growthFactor`.
3. **Calculate Compounded Interest Factor:**
   * Comment: "Compounded interest factor"
   * Multiply the original `monthlyInterestRate` by the newly generated `growthFactor`.
   * Save the result to a pipeline string named `compoundedInterestFactor`.
4. **Calculate Compounded Growth Offset:**
   * Comment: "Compounded growth offset"
   * Subtract a hardcoded value of "1" from the `growthFactor`.
   * Save the result to a pipeline string named `compoundedGrowthOffset`.
5. **Calculate Payment Factor Coefficient:**
   * Comment: "Payment factor"
   * Divide the `compoundedInterestFactor` by the `compoundedGrowthOffset`.
   * Save the result to a pipeline string named `primaryInterestCoefficient`.
6. **Calculate Base Cost:**
   * Comment: "The unrounded monthly cost"
   * Multiply the input parameter `loanAmount` by the `primaryInterestCoefficient`.
   * Store this unrounded outcome in a pipeline string named `rawMonthlyPayment`.

##### --- Path B: ELSE path (Simple No-Interest Distribution) ---
Execute if the rate is exactly zero:

1. **Flat Cost Splitting:**
   * Comment: "Simple calculation with no interest"
   * Divide the input parameter `loanAmount` directly by the `totalMonths`.
   * Store this direct outcome in the matching pipeline string named `rawMonthlyPayment`.

#### Step 3: Currency Rounding (Final Outbound Formatting Block)
* Create a final structural inline `MAP` transformer step.
* Comment: "Final rounding and cleanup"
* Look up a number rounding method inside `MATH.json`. Pass the `rawMonthlyPayment` pipeline variable into the action parameter.
* Set the hardcoded scaling limit `numberOfDigits` to "2" and assign a hardcoded `roundingMode` configuration to "roundHalfUp".
* Directly assign the rounded outcome out of the utility method into the official service signature output parameter named `payment`.
* After the transform and within the MAP, Drop the following fields:
    - `monthlyInterestRateNum`
    - `loanAmount`
    - `monthlyInterestRate`
    - `totalMonths`
    - `baseValue`
    - `growthFactor`
    - `compoundedInterestFactor`
    - `compoundedGrowthOffset`
    - `primaryInterestCoefficient`
    - `rawMonthlyPayment`
