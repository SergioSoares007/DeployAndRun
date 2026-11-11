# Tutorial: Creating a Custom Service Catalog for AI-Assisted Service Discovery

## Overview

This tutorial demonstrates how to create a custom service catalog that enables an AI assistant to discover and use your existing Integration Server services through natural language prompts.

A built-in catalog of Integration Server services allows the AI assistant to translate natural language requirements into the appropriate built-in services. For example, if a user requests a service that multiplies two numbers, the AI assistant can identify `pub.math:multiplyFloats` and use it in the generated FSL.

This capability can also be extended to custom services. Instead of requiring users to know fully qualified service names, custom catalogs enable services to be discovered and referenced by using natural language descriptions. 

For example, instead of prompting:

```text
Invoke the service: orders:applyDiscount
```

a user can request:

```text
Apply a discount to the total cost of the order based on the customerType.
```

The AI assistant can then identify the appropriate custom service and incorporate it into the generated solution.

In this tutorial, you will create a custom catalog from an existing service in the Orders package and generate documentation that enables the service to be reused in future prompts.

## Prerequisites

Before you begin, ensure that you have:

- IBM webMethods Integration Server 12.1 Core Fix 2 or later
- webMethods Designer 12.1 Core Fix 2 or later
- An installed Orders tutorial package that is visible in Designer
- Access to an AI assistant that can scan the local file system, such as IBM Bob

## Tutorial Objectives

By completing this tutorial, you will learn how to:

- Convert existing Flow services into Flow Script assets.
- Extract the FSL representation of existing services.
- Generate service documentation automatically.
- Create a JSON-based custom service catalog.
- Enable AI-assisted discovery and reuse of custom services.

## Procedure

### Step 1. Examine the Orders Package

In Designer, verify that the Orders package contains the following folder:

- orders

This tutorial focuses on creating a custom service catalog by using the service located in the `orders` folder.

This folder contains a Flow service with input and output signatures that are used to generate catalog metadata.

### Step 2. Convert Services to Flow Script

In the `orders` folder, right-click:

```text
orders:applyDiscount
```

Select:

```text
Upgrade to Flow Script
```

and click **Yes** when prompted.

Notice that the service icon changes, which indicates that the asset is converted to a Flow Script-based asset.

### Step 3. View the FSL Representation

In the Flow Service Editor, open:

```text
orders:applyDiscount
```

Select the **Source** tab.

The source view displays the Flow Script Language (FSL) representation of the service.

### Step 4. Copy the FSL

Copy the entire text in the Source tab.

### Step 5. Populate the Existing Service Flow Scripts

Navigate to:

```text
tutorials/ShoppingCart/existing-services-flow-script
```

An empty `.flow` file is created:

- `applyDiscount.flow`

Paste the copied FSL for `applyDiscount` into:

```text
applyDiscount.flow
```

### Step 6. Generate Documentation and the Custom Catalog

Provide the following prompt to your AI assistant:

```text
Follow the instructions in tutorials/ShoppingCart/createDocumentationAndCustomCatalog.md
```

Approve all requests until processing completes.

### Step 7. Review the Generated Catalog

Navigate to:

```text
skills/flow/service-catalogs/staging
```

And verify that the following file is present:

```text
SHOPPING_CART.json
```

Verify that the staged catalog contains an entry for the service:

- applyDiscount

### Step 8. Review the Generated Documentation

Navigate to:

```text
tutorials/ShoppingCart/existing-services-flow-script
```

Verify that a Markdown document for the service is present.

The document describes:

- The purpose of the service
- Input parameters
- Output parameters
- Service behavior

The generated documentation can be used by both developers and AI assistants to facilitate future service reuse.

## Summary

In this tutorial, you converted an existing Flow service into a Flow Script asset and used its FSL representation to create a custom service catalog.

The AI assistant analyzed the Flow Script definition and generated documentation and JSON metadata describing the service. This catalog allows existing services to be referenced through natural language prompts rather instead of requiring users to know their fully qualified service names.

### What You Accomplished

You demonstrated how to extend AI-assisted development beyond built-in Integration Server services by creating a custom service catalog.

By completing this tutorial, you:

- Converted an existing service into a Flow Script asset.
- Extracted the FSL representation of that service.
- Generated Markdown documentation automatically.
- Created a staged JSON-based service catalog.
- Enabled future AI prompts to discover and reuse your existing service.
- Reduced the need for users to memorize fully qualified service names.

By maintaining custom catalogs, organizations can expose existing service libraries to AI assistants. This enables developers to discover and use enterprise services through natural language prompts, reuse services and improve their productivity.
