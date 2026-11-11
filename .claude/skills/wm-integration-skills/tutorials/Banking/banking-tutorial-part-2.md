# Tutorial: Creating a Custom Service Catalog for AI-Assisted Service Discovery

## Overview

This tutorial demonstrates how to create a custom service catalog that enables an AI assistant to discover and use your existing Integration Server services through natural language prompts.

A built-in catalog of Integration Server services allows the AI assistant to translate natural language requirements into the appropriate built-in services. For example, if a user requests a service that multiplies two numbers, the AI assistant can identify `pub.math:multiplyFloats` and use it in the generated FSL.

This capability can also be extended to custom services. Instead of requiring users to know fully qualified service names, custom catalogs enable services to be discovered and referenced by using natural language descriptions.

For example, instead of prompting:

```text
Invoke Deposits:CompoundInterestCalculator
```

a user can request:

```text
Project the growth of a retirement fund over time using compound interest.
```

The AI assistant can then identify the appropriate custom service and incorporate it into the generated solution.

In this tutorial, you will create a custom catalog from three existing services in the Banking package and generate documentation that enables the services to be reused in future prompts. 

## Prerequisites

Before beginning this tutorial, ensure that:

- IBM webMethods Integration Server 12.1 Core Fix 3 or later
- webMethods Designer 12.1 Core Fix 3 or later
- An installed Banking tutorial package that is visible in Designer
- Access to an AI assistant that can scan the local file system, such as IBM Bob

## Tutorial Objectives

By completing this tutorial, you will learn how to:

- Convert existing Flow services into Flow Script assets.
- Extract the FSL representation of existing services.
- Generate service documentation automatically.
- Create a JSON-based custom service catalog.
- Enable AI-assisted discovery and reuse of custom services.

## Procedure

### Step 1. Examine the Banking Package

In Designer, verify that the Banking package contains the following folders:

- Cards
- Deposits
- Loans
- Risk

The previous part of the tutorial focused primarily on the Loans folder. This tutorial focuses on creating a custom service catalog by using services located in the Cards, Deposits, and Risk folders.

These folders contain Flow services with input and output signatures and top-level descriptions that are used to generate catalog metadata.

### Step 2. Convert Services to Flow Script

In the `Cards` folder, right-click:

```text
CreditCardRevolvingDebtPayoffOptimizer
```

Select:

```text
Upgrade to Flow Script
```

and click **Yes** when prompted.

Notice that the service icon changes, which indicates that the asset is converted to a Flow Script-based asset.

Repeat this process for:

```text
Deposits:CompoundInterestCalculator
Risk:DebtServiceCoverageRatioCalculator
```

### Step 3. View the FSL Representation

In the Flow Service Editor, open:

```text
CreditCardRevolvingDebtPayoffOptimizer
```

Select the **Source** tab.

The source view displays the Flow Script Language (FSL) representation of the service.

### Step 4. Copy the FSL

Copy the entire text in the Source tab.

### Step 5. Populate the Existing Service Flow Scripts

Navigate to:

```text
tutorials/Banking/existing-services-flow-script
```

Three empty `.flow` files are created:

- `CreditCardRevolvingDebtPayoffOptimizer.flow`
- `CompoundInterestCalculator.flow`
- `DebtServiceCoverageRatioCalculator.flow`

Paste the copied FSL for `CreditCardRevolvingDebtPayoffOptimizer` into:

```text
CreditCardRevolvingDebtPayoffOptimizer.flow
```

To populate all three `.flow` files, repeat the process for:

- `Deposits:CompoundInterestCalculator`
- `Risk:DebtServiceCoverageRatioCalculator`


### Step 6. Generate Documentation and the Custom Catalog

Provide the following prompt to your AI assistant:

```text
Follow the instructions in tutorials/Banking/createDocumentationAndCustomCatalog.md
```

Approve all requests until processing completes.

### Step 7. Review the Generated Catalog

Navigate to:

```text
skills/flow/service-catalogs/staging
```

And verify that the following file is present:

```text
BANKING.json
```

Verify that the staged catalog contains entries for the following services:

- CreditCardRevolvingDebtPayoffOptimizer
- CompoundInterestCalculator
- DebtServiceCoverageRatioCalculator

### Step 8. Review the Generated Documentation

Navigate to:

```text
tutorials/Banking/existing-services-flow-script
```

Verify that a Markdown document for each service is present.

These documents describe:

- The purpose of the service
- Input parameters
- Output parameters
- Service behavior

The generated documentation can be used by both developers and AI assistants to facilitate future service reuse.

## Summary

In this tutorial, you transformed existing Flow services into Flow Script assets and used their FSL representations to create a custom service catalog.

The AI assistant analyzed the Flow Script definitions and generated documentation and JSON metadata describing each service. These artifacts allow existing services to be referenced through natural language prompts instead of requiring users to know their fully qualified service names.

### What You Accomplished

You demonstrated how to extend AI-assisted development beyond built-in Integration Server services by creating a custom service catalog.

By completing this tutorial, you:

- Converted existing services into Flow Script assets.
- Extracted the FSL representation of those services.
- Generated Markdown documentation automatically.
- Created a staged JSON-based service catalog.
- Enabled future AI prompts to discover and reuse your existing services.
- Reduced the need for users to memorize fully qualified service names.

By maintaining custom catalogs, organizations can expose existing service libraries to AI assistants. This enables developers to discover and use enterprise services through natural language prompts, reuse services and improve their productivity.