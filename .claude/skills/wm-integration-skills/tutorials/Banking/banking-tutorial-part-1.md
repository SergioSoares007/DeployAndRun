# Tutorial: Generating Banking Flow Services with AI

## Overview

This tutorial demonstrates how to use an AI assistant to generate Flow Script Language (FSL) assets for a set of banking-related webMethods Integration Server Flow services.

The primary service generated in this tutorial is `AmortizationCalculator`, which depends on the following supporting services:

- `CalculateMonthlyInterestRate`
- `CalculateFixedMonthlyPrincipalAndInterestPayment`

In addition to generating FSL, the AI assistant:

- Generates Markdown documentation for each service.
- Generates Mermaid diagrams for each service.
- Updates a custom service catalog with the generated services.
- Enables future prompts to reference previously generated services by using natural language instead of fully qualified service names.

The AI assistant has access to a catalog of built-in Integration Server services, which enables users to describe business requirements without knowing specific service names or namespaces. Users can extend this capability by creating custom catalogs that contain their own services.

## Prerequisites

Before you begin, ensure that you have:

- IBM webMethods Integration Server 12.1 Core Fix 3 or later
- webMethods Designer 12.1 Core Fix 3 or later
- Access to an AI assistant that can scan the local file system, such as IBM Bob

## Tutorial Objectives

By completing this tutorial, you will learn how to:

- Generate Flow services by using AI and FSL.
- Generate Markdown documentation automatically.
- Generate Mermaid diagrams automatically.
- Maintain a custom service catalog.
- Import generated FSL assets into Integration Server to create Flow Services.

## Optional: Enable Automatic Deployment

The AI assistant can automatically deploy generated Flow Services to your local Integration Server instance.

To enable automatic deployment, edit the following file:

`tutorials/.config/environment.md`

Specify the location of your webMethods installation. For example:

```text
WEBMETHODS_HOME = C:\IBMwebMethods_12_1_Fix2
```

`WEBMETHODS_HOME` must point to the root webMethods installation directory. The specified directory must contain an `IntegrationServer` subdirectory.

If `WEBMETHODS_HOME` is not configured, or if the AI assistant cannot locate the Integration Server installation, automatic deployment is skipped. You can deploy the generated service manually by using the File copy procedure or the Source editor procedure described later in this tutorial.

## Procedure

### Step 1. Install the Banking Package

Install the starter package located at:

```text
tutorials/Banking/package/starter/Banking.zip
```

into your Integration Server instance.

### Step 2. Review the Service Catalogs

The `service-catalogs` directory contains the following catalogs:

#### Built-In Service Catalog

The `wm-service-catalog` contains metadata for built-in Integration Server services. This catalog enables the AI assistant to translate natural language requirements into the appropriate built-in services.

#### Custom Service Catalog

The `custom-catalog` directory contains a JSON-based catalog of custom banking services.

Custom catalogs can be generated automatically by converting existing services to FSL and using the AI assistant to generate the corresponding JSON entries. This process is demonstrated later in the tutorial.

For convenience, the custom catalog is prepopulated with several banking-related services.

### Step 3. Generate the Services

Provide the following prompt to your AI assistant:

```text
Follow the instructions in tutorials/Banking/driverPrompt.md
```

### Step 4. Approve All Requests

Approve all requests presented by the AI assistant until processing is complete.

### Step 5. Review the Generated Assets

The generated Flow Script files are written to:

```text
tutorials/Banking/llm-generated-flow-script
```

Each generated FSL asset is placed in its own directory:

```text
tutorials/Banking/llm-generated-flow-script/
├── AmortizationCalculator/
│   └── flow.flow
├── CalculateMonthlyInterestRate/
│   └── flow.flow
└── CalculateFixedMonthlyPrincipalAndInterestPayment/
    └── flow.flow
```

The generated FSL forms a complete solution. `AmortizationCalculator` is the primary service and invokes both `CalculateMonthlyInterestRate` and `CalculateFixedMonthlyPrincipalAndInterestPayment`. Deploy all three FSL assets before you  execute `Loans:AmortizationCalculator`.

Markdown documentation is generated in:

```text
tutorials/Banking/llm-generated-flow-script
```

Mermaid diagrams are generated in:

```text
tutorials/Banking/diagrams
```

The custom catalog:

```text
tutorials/service-catalogs/custom-catalog/BANKING.json
```

now contains three new entries corresponding to the generated services.

### Step 6. Start Designer

Start webMethods Designer and connect to your Integration Server instance.

Verify that the Banking package is visible.

### Step 7. Deploy the Generated Services

Before you execute the generated services, choose one of the following deployment methods.

#### Option 1. Automatic Deployment

If `WEBMETHODS_HOME` is configured in `tutorials/.config/environment.md` before running the tutorial, the AI assistant automatically deploys the generated services.

If the AI assistant reports that automatic deployment completed successfully, do the following:

1. In Designer, reload the Banking package.
2. Continue with Step 8.

If automatic deployment is unsuccessful, continue with Option 2 or Option 3.

#### Option 2. Manual Deployment by Copying the Generated Folders

1. Open the following directory:

```text
[InstallationDirectory]\IntegrationServer\instances\default\packages\Banking\ns\Loans
```

2. Copy the Generated FSL:

- `AmortizationCalculator`
- `CalculateMonthlyInterestRate`
- `CalculateFixedMonthlyPrincipalAndInterestPayment`

from:

```text
tutorials/Banking/llm-generated-flow-script
```

to:

```text
[InstallationDirectory]\IntegrationServer\instances\default\packages\Banking\ns\Loans
```

These three services are designed to work together.

`AmortizationCalculator` is the primary service and invokes:

- `CalculateMonthlyInterestRate`
- `CalculateFixedMonthlyPrincipalAndInterestPayment`

Deploy all three services before you execute `Loans:AmortizationCalculator`.

3. Reload the Banking package.

4. Continue with Step 8.

#### Option 3. Import FSL by Using the Source Editor

As an alternative to Option 2, create the following Flow Services in the `Loans` directory:

- AmortizationCalculator
- CalculateMonthlyInterestRate
- CalculateFixedMonthlyPrincipalAndInterestPayment

For each service:

1. Open the service.
2. Switch to the Source tab.
3. Copy the contents of the generated `flow.flow` file.
4. Paste the contents into the Source editor.
5. Save the service.

After importing all three services, continue with Step 8.

### Step 8. Execute the Service

Execute:

```text
Loans:AmortizationCalculator
```

by using the following input values:

| Input | Value |
|---------|--------|
| loanAmount | 400000 |
| interestRate | 6.5 |
| termYears | 30 |

### Verify the Amortization Schedule

If the document list is expanded, collapse it and select the amortization schedule.

Verify that the following columns are present:

- paymentNumber
- paymentAmount
- interestAmount
- principalAmount
- endingBalance

#### Payment 1

| Column | Value |
|----------|--------|
| paymentNumber | 1 |
| paymentAmount | $2,528.27 |
| interestAmount | $2,166.67 |
| principalAmount | $361.60 |
| endingBalance | $399,638.40 |

#### Payment 2

| Column | Value |
|----------|--------|
| paymentNumber | 2 |
| paymentAmount | $2,528.27 |
| interestAmount | $2,164.71 |
| principalAmount | $363.56 |
| endingBalance | $399,274.84 |

#### Payment 360

| Column | Value |
|----------|--------|
| paymentNumber | 360 |
| paymentAmount | $2,528.27 |
| interestAmount | $13.64 |
| principalAmount | $2,514.63 |
| endingBalance | $2.61 |

### Verify the Additional Outputs

| Output | Expected Value |
|----------|--------|
| fiveYearEquity | $25,555.92 |
| totalInterestPaid | $510,179.81 |
| fixedMonthlyPayment | $2,528.27 |
| totalCost | $910,179.81 |
| interestRatio | 0.56 |
| trueCostFactor | 2.28 |
| tippingPointMonth | 233 |

## Summary

In this tutorial, you used an AI assistant to generate a complete set of banking-related Flow Services by using Flow Script Language (FSL). Starting from a high-level description of the functionality, the AI assistant generated the `AmortizationCalculator` service and its supporting services, `CalculateMonthlyInterestRate` and `CalculateFixedMonthlyPrincipalAndInterestPayment`.

The AI assistant also:

- Generated FSL assets for the services.
- Generated Markdown documentation that describes the purpose, inputs, and outputs of each service.
- Created Mermaid diagrams to visualize the service implementations.
- Updated the custom service catalog so that the new services can be discovered and reused in future prompts.

After importing the generated assets into Integration Server, you executed the `AmortizationCalculator` service and verified that the results matched the expected amortization schedule and calculated values.

### What You Accomplished

You demonstrated how AI can be used to automate the creation and maintenance of Integration Server assets. By completing this tutorial, you:

- Generated multiple Flow Services from natural language requirements.
- Used built-in service catalogs to translate business requirements into Integration Server operations.
- Generated supporting documentation and diagrams automatically.
- Extended a custom service catalog with newly created services.
- Imported AI-generated assets into Integration Server and validated their behavior.

This tutorial shows how AI-assisted development can accelerate service creation and also generate the documentation and metadata required to support future development and reuse.

## Next Steps

You used AI to generate new banking-related Flow Services, supporting documentation, Mermaid diagrams, and catalog entries.

To learn how to expose your existing Flow Services to an AI assistant and enable natural language discovery and reuse, continue with [Creating a Custom Service Catalog for AI-Assisted Service Discovery](banking-tutorial-part-2.md).

In the next tutorial, you will learn how to:

- Convert existing Flow Services into Flow Script assets.
- Extract FSL representations from existing services.
- Generate Markdown documentation automatically.
- Create a JSON-based custom service catalog.
- Enable AI-assisted discovery and reuse of existing services through natural language prompts.