# Custom Catalog and Documentation Generator

## 1. Service Catalog Sync Protocol
You must synchronize the signature metadata for all .flow files in `tutorials/Banking/existing-services-flow-script` into a staging Service Catalog.  

### Execution Instructions
1. Check for the existence of the file: `skills/flow/service-catalogs/staging/BANKING.json`.
   - **If the file does not exist:** Dynamically create `BANKING.json` in that directory. Seed it with the default catalog shell structure containing `"folder": "BANKING"`, `"description"`, and a `"total_elements"` counter set to 0.
   - **If the file exists:** Open and parse it directly.
2. Extract the service structure names, input configurations, output configurations, and comment properties from the FSL files in `tutorials/Banking/existing-services-flow-script`.
3. Perform an **Upsert Mutation** against the `elements` array within `BANKING.json` matching the catalog schema format:
   - **If the service name already exists:** Completely modify/overwrite its inner parameter definitions, types, and descriptions to match the new FSL signatures precisely.
   - **If the service name does not exist:** Append a new element object block to the `elements` array containing the comprehensive signature metadata.
4. Increment or update the value of the top-level `"total_elements"` property in `BANKING.json` to accurately reflect the total number of services in the file.

### JSON Element Target Format Reference
Ensure mutations strictly adhere to this baseline json block structural pattern:
```json
{
  "folder": "Loans",
  "description": [
    "Custom banking domain services generated for managing asset-backed loans and debt schedules."
  ],
  "total_elements": 1,
  "elements": [
    {
      "name": "Loans:AmortizationCalculator",
      "element_type": "service",
      "description": [
        "Calculates the month-by-month repayment schedule of a loan based on the principal amount, interest rate, and loan length."
      ],
      "input_parameters": [
        {
          "name": "loanAmount",
          "type": "String",
          "description": [
            "The total initial sum of money borrowed or the starting balance of the loan before any payments are applied."
          ]
        },
        {
          "name": "interestRate",
          "type": "String",
          "description": [
            "The nominal yearly interest percentage charged by the lender (which the AI-assisted service will dynamically convert to a monthly fractional rate for period calculations)."
          ]
        },
        {
          "name": "termYears",
          "type": "String",
          "description": [
            "The overall lifespan of the loan expressed in years, representing the total operational horizon (which the service will translate into total installment months)."
          ]
        }
      ],
      "output_parameters": [
        {
          "name": "AmortizationSchedule",
          "type": "recordList",
          "description": [
            "For every month the loan is active, the engine will dynamically generate a single line item tracking the following five properties:",
            "Payment Number",
            "Payment Amount",
            "Interest Amount",
            "Principal Amount",
            "Ending Balance"
          ]
        },
        {
          "name": "fixedMonthlyPayment",
          "type": "String",
          "description": [
            "The baseline regular amount the borrower must pay during each individual installment period to successfully amortize the debt."
          ]
        },
        {
          "name": "totalInterestPaid",
          "type": "String",
          "description": [
            "The cumulative cost of borrowing over the entire lifespan of the loan, representing the sum total of all interest charges."
          ]
        },
        {
          "name": "totalCost",
          "type": "String",
          "description": [
            "The absolute lifetime cost of the debt, calculated as the original loan amount plus the total interest paid."
          ]
        },
        {
          "name": "interestRatio",
          "type": "String",
          "description": [
            "A financial efficiency metric representing the percentage of the lifetime cost eaten up by interest charges rather than equity."
          ]
        },
        {
          "name": "trueCostFactor",
          "type": "String",
          "description": [
            "A strategic multiplier that compares the total lifetime cost of the loan back to the original principal amount (indicating how many times over the borrower is paying for the asset)."
          ]
        },
        {
          "name": "tippingPointMonth",
          "type": "String",
          "description": [
            "The exact calendar month during the lifecycle of the loan where the monthly principal allocation permanently eclipses the monthly interest charge."
          ]
        },
        {
          "name": "fiveYearEquity",
          "type": "String",
          "description": [
            "The total principal paid down by the borrower at the exact 60-month mark, showing real asset ownership after five years."
          ]
        }
      ]
    }
  ]
}
```

## 2. Matching Markdown Documentation Protocol (Post-Generation)
**Mandatory Rule**: Every generated script file (e.g., `ServiceName.flow`) MUST have a corresponding Markdown documentation file (ServiceName.md) generated in the directory: `tutorials/Banking/existing-services-flow-script`.
**Naming**: The names of each markdown file should match the service name for the FSL being generated. E.g.: CompoundInterestCalculator.md

### Execution Instructions
1. Ensure the markdown file matches information exported to the JSON catalog exactly, but format it for human legibility using organized Markdown headings, blocks, lists, and bold callouts.
2. Structure the file according to the required template below:
    - **Service Name & Interface Title**
    - **Service Purpose Description** (Extracted from properties block)
    - **Inputs Table/List** (Name, Type, Constraints, and clear business descriptions)
    - **Outputs Table/List** (Name, Type, and multi-line/single-line documentation blocks)
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

## 3. Final Deliverables Checklist
Do not declare the task complete until all required deliverables have been created and saved successfully.

### Required Deliverables
- Markdown documentation files in `tutorials/Banking/existing-services-flow-script`
- Updated `skills/flow/service-catalogs/staging`

### Completion Rule
The task is **NOT** complete until every deliverable listed above exists and has been written successfully.

### Final Verification Requirement
Before declaring completion, verify that:
2. All matching documentation `.md` files exist in `tutorials/Banking/llm-generated-flow-script`
4. `skills/flow/service-catalogs/staging/BANKING.json` has been created or updated successfully
