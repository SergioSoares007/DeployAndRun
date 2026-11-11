# Service Catalog Configuration

## Instructions
1. Check for the existence of the file: `{{ CATALOG_PATH }}`.
   - **If the file does not exist:** Dynamically create it in that directory. Seed it with the default catalog shell structure containing `"folder": "{{ CATALOG_FOLDER }}"`, `"description"`, and a `"total_elements"` counter set to 0.
   - **If the file exists:** Open and parse it directly.
2. Extract the service structure names, input configurations, output configurations, and comment properties from your newly generated FSL files.
3. Perform an **Upsert Mutation** against the `elements` array within `{{ CATALOG_PATH }}` matching the catalog schema format:
   - **If the service name already exists:** Completely modify/overwrite its inner parameter definitions, types, and descriptions to match the new FSL signatures precisely.
   - **If the service name does not exist:** Append a new element object block to the `elements` array containing the comprehensive signature metadata.
   - **Output Rule:** When executing the Upsert Mutation against `{{ CATALOG_PATH }}`, you must always output the ENTIRE, fully compiled JSON structure containing all existing elements plus your modification. Never emit code blocks containing trailing truncation marks (e.g., `// ... rest of code`).
4. Increment or update the value of the top-level `"total_elements"` property in `{{ CATALOG_PATH }}` to accurately reflect the total number of services in the file.

## JSON Element Target Format Reference
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