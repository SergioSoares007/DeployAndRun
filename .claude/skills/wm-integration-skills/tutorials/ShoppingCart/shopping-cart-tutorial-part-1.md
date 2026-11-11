# Tutorial: Generating a Shopping Cart Flow Service with AI

## Overview

This tutorial demonstrates how to use an AI assistant to generate Flow Script Language (FSL) assets for a shopping cart webMethods Integration Server Flow service.

The service generated in this tutorial is `processOrder`, which depends on a supporting service:

- `orders:applyDiscount`

In addition to generating FSL, the AI assistant:

- Generates Markdown documentation for the service.
- Generates a Mermaid diagram for the service.
- Updates a custom service catalog with the generated service.
- Enables future prompts to reference previously generated service by using natural language instead of fully qualified service names.

The AI assistant has access to a catalog of built-in Integration Server services, which enables users to describe business requirements without knowing specific service names or namespaces. Users can extend this capability by creating custom catalogs that contain their own services. 

## Prerequisites

Before you begin, ensure that you have:

- IBM webMethods Integration Server 12.1 Core Fix 2 or later
- webMethods Designer 12.1 Core Fix 2 or later
- Access to an AI assistant that can scan the local file system, such as IBM Bob


## Tutorial Objectives

By completing this tutorial, you will learn how to:

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

### Step 1. Install the Orders Package

Install the starter package located at:

```text
tutorials/ShoppingCart/package/starter/Orders.zip
```

into your Integration Server instance.

### Step 2. Review the Service Catalogs

The `service-catalogs` directory contains the following catalogs:

#### Built-In Service Catalog

The `wm-service-catalog` contains metadata for built-in Integration Server services. This catalog enables the AI assistant to translate natural language requirements into the appropriate built-in services.

#### Custom Service Catalog

The `custom-catalog` directory contains a JSON-based catalog of custom shopping cart services.

Custom catalogs can be generated automatically by converting existing services to FSL and using the AI assistant to generate the corresponding JSON entries. This process is demonstrated later in the tutorial.

For convenience, the custom catalog is prepopulated with a storefront-related service.

### Step 3. Generate the Service

Provide the following prompt to your AI assistant:

```text
Follow the instructions in tutorials/ShoppingCart/driverPrompt.md
```

### Step 4. Respond to AI Assistant Requests

Approve all requests presented by the AI assistant until processing is complete.

### Step 5. Review the Generated Assets

The generated Flow Script files are written to:

```text
tutorials/ShoppingCart/llm-generated-flow-script
```

Each generated FSL asset is placed in its own directory:

For example:

```text
tutorials/ShoppingCart/llm-generated-flow-script/processOrder/flow.flow
```

Markdown documentation is generated in:

```text
tutorials/ShoppingCart/llm-generated-flow-script
```

A Mermaid diagram is generated in:

```text
tutorials/ShoppingCart/diagrams
```

The custom catalog:

```text
tutorials/service-catalogs/custom-catalog/SHOPPING_CART.json
```

now contains one new entry corresponding to the generated service.

### Step 6. Start Designer

Start webMethods Designer and connect to your Integration Server instance.

Verify that the Orders package is visible.

### Step 7. Deploy the Generated Service

At this point, the AI assistant has generated the Flow Script Language (FSL), documentation, Mermaid diagram, and updated service catalog.

Before you execute the generated service, choose one of the following deployment methods.

#### Option 1. Automatic Deployment

If `WEBMETHODS_HOME` is configured in `tutorials/.config/environment.md` before running the tutorial, the AI assistant automatically deploys the generated service.

If the AI assistant reports that automatic deployment completed successfully, do the following:

1. In Designer, reload the Banking package.
2. Continue with Step 8.

If automatic deployment is unsuccessful, continue with Option 2 or Option 3.

#### Option 2. Manual Deployment by Copying the Generated Folder

1. Open the following directory:

```text
[InstallationDirectory]\IntegrationServer\instances\default\packages\Orders\ns\orders
```

2. Copy the Generated FSL

- `processOrder`

from:

```text
tutorials/ShoppingCart/llm-generated-flow-script
```

to:

```text
[InstallationDirectory]\IntegrationServer\instances\default\packages\Orders\ns\orders
```

3. Reload the Orders package.
4. Continue with Step 8.

#### Option 3. Import FSL by Using the Source Editor

As an alternative to Option 2, you can import the generated FSL directly into a new Flow Service by doing the following:

Detailed procedure:
1. In the `orders` directory, create an empty Flow service `processOrder`.
2. Switch to the **Source** tab.
3. Copy the contents of the `flow.flow` file generated by the AI assistant.
4. Paste the contents into the Source editor.
5. Save the service.
6. Continue with Step 8.

### Step 8. Execute the Service

Execute:

```text
orders:processOrder
```

In the Service Input window, click the **Load** button and select the file:
`tutorials/ShoppingCart/OrderInput`
The input dialog is populated with data from the file.

### Verify the Output

| Output | Expected Value |
|----------|--------|
| orderId | A00500079 |
| customerId | CompanyXYZ |
| customerType | EMPLOYEE |
| discountApplied | $580.98 |
| orderTotal | $7,718.73 |
| orderTotalBeforeDiscount | $8,299.71 |

If the items list is expanded, collapse it and select items.

Verify that the following columns are present:

- productId
- itemName
- quantity
- price

#### items[0]

| Column | Value |
|----------|--------|
| productId | KCH-Q1P-M1-BRN |
| itemName | Keychron Q1 Pro QMK/VIA Wireless Mechanical Keyboard |
| quantity | 2 |
| price | 199.99 |

#### items[1]

| Column | Value |
|----------|--------|
| productId | DEL-U3824DW-2024 |
| itemName | Dell UltraSharp 38 Curved USB-C Hub Monitor (U3824DW) |
| quantity | 7 |
| price | 899.99 |

#### items[2]

| Column | Value |
|----------|--------|
| productId | CDGT-TS4-98WH |
| itemName | CalDigit TS4 Thunderbolt 4 Station |
| quantity | 4 |
| price | 399.95 |

## Summary

In this tutorial, you used an AI assistant to generate a storefront-related Flow Services by using Flow Script Language (FSL). Starting from a high-level description of the functionality, the AI assistant generated the `processOrder` service and its supporting artifacts.

The AI assistant also:

- Generated FSL assets for the service.
- Generated Markdown documentation that describes the purpose, inputs, and outputs of the service.
- Created a Mermaid diagram to visualize the service implementation.
- Updated the custom service catalog so that the new service can be discovered and reused in future prompts.

After importing the generated asset into Integration Server, you executed the `processOrder` service and verified that the results matched the expected results.

### What You Accomplished

You demonstrated how AI can be used to automate the creation and maintenance of Integration Server assets. By completing this tutorial, you:

- Generated a Flow Service from natural language requirements.
- Used built-in service catalogs to translate business requirements into Integration Server operations.
- Generated supporting documentation and a diagram automatically.
- Extended a custom service catalog with newly created services.
- Imported the AI-generated asset into Integration Server and validated its behavior.

This tutorial shows how AI-assisted development can accelerate service creation and also generate the documentation and metadata required to support future development and reuse.


## Next Steps

You used AI to generate a new storefront-related Flow Services, supporting documentation, Mermaid diagrams, and catalog entries.

To learn how to expose your existing Flow Services to an AI assistant and enable natural language discovery and reuse, continue with [Creating a Custom Service Catalog for AI-Assisted Service Discovery](shopping-cart-tutorial-part-2.md).

In the next tutorial, you will learn how to:

- Convert existing Flow Services into Flow Script assets.
- Extract FSL representations from existing services.
- Generate Markdown documentation automatically.
- Create a JSON-based custom service catalog.
- Enable AI-assisted discovery and reuse of existing services through natural language prompts.

