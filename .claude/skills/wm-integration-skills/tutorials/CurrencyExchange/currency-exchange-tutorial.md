# Tutorial: Generating an Exchange Rate Retrieval Flow Service with AI

## Overview

This tutorial demonstrates how to use an AI assistant to generate Flow Script Language (FSL) assets for an exchange rate retrieval webMethods Integration Server Flow service.

The service generated in this tutorial is `GetExchangeRates`. This service connects to the public **Frankfurter API** (`https://api.frankfurter.dev`), an open-source, lightweight digital service, which provides foreign exchange rate data published by the European Central Bank. The generated service retrieves current global currency data without requiring proprietary access keys.

In addition to generating FSL, the AI assistant:

- Generates Markdown documentation for the service.
- Generates a Mermaid diagram for the service.

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

### Step 1. Install the CurrencyExchange Package

Install the starter package located at:

```text
tutorials/CurrencyExchange/package/starter/CurrencyExchange.zip
```

into your Integration Server instance.

### Step 2. Review the Service Catalog

The `service-catalogs` directory contains the following catalog:

#### Built-In Service Catalog

The `wm-service-catalog` contains metadata for built-in Integration Server services. This catalog enables the AI assistant to translate natural language requirements into the appropriate built-in services.

### Step 3. Generate the Service

Provide the following prompt to your AI assistant:

```text
Follow the instructions in tutorials/CurrencyExchange/driverPrompt.md
```

### Step 4. Respond to AI Assistant Requests

Approve all requests presented by the AI assistant until processing is complete.

### Step 5. Review the Generated Assets

The generated Flow Script files are written to:

```text
tutorials/CurrencyExchange/llm-generated-flow-script
```

Each generated FSL asset is placed in its own directory:

For example:

```text
tutorials/CurrencyExchange/llm-generated-flow-script/GetExchangeRates/flow.flow
```

Markdown documentation is generated in:

```text
tutorials/CurrencyExchange/llm-generated-flow-script
```

A Mermaid diagram is generated in:

```text
tutorials/CurrencyExchange/diagrams
```

### Step 6. Start Designer

Start webMethods Designer and connect to your Integration Server instance.

Verify that the CurrencyExchange package is visible.

### Step 7. Deploy the Generated Service

At this point, the AI assistant has generated the Flow Script Language (FSL), documentation and Mermaid diagram.

Before you execute the generated service, choose one of the following deployment methods.

#### Option 1. Automatic Deployment

If `WEBMETHODS_HOME` is configured in `tutorials/.config/environment.md` before running the tutorial, the AI assistant automatically deploys the generated service.

If the AI assistant reports that automatic deployment completed successfully, do the following:

1. In Designer, reload the CurrencyExchange package.
2. Continue with Step 8.

If automatic deployment is unsuccessful, continue with Option 2 or Option 3.

#### Option 2. Manual Deployment by Copying the Generated Folder

1. Open the following directory:

```text
[InstallationDirectory]\IntegrationServer\instances\default\packages\CurrencyExchange\ns\exchange
```

2. Copy the Generated FSL

- `GetExchangeRates`

from:

```text
tutorials/CurrencyExchange/llm-generated-flow-script
```

to:

```text
[InstallationDirectory]\IntegrationServer\instances\default\packages\CurrencyExchange\ns\exchange
```

3. Reload the CurrencyExchange package.
4. Continue with Step 8.

#### Option 3. Import FSL by Using the Source Editor

As an alternative to Option 2, you can import the generated FSL directly into a new Flow Service by doing the following:

1. In the `exchange` directory, create an empty Flow service `GetExchangeRates`.
2. Switch to the **Source** tab.
3. Copy the contents of the `flow.flow` file generated by the AI assistant.
4. Paste the contents into the Source editor.
5. Save the service.
6. Continue with Step 8.

### Step 8. Execute the Service

Execute:

```text
exchange:GetExchangeRates
```

by using the following input values (Euros to Swiss Francs):

| Input | Value |
|---------|--------|
| baseCurrency | EUR |
| targetCurrency | CHF |

### Verify the Exchange Rate

If the document list is expanded, collapse it and select exchangeRates. 

Verify that the following values are close to the expected values. Exchange rates fluctuate over time.

| Column | Value |
|----------|--------|
| date | Current date |
| base | EUR |
| quote | CHF |
| rate | ~0.92274 |

Leave `baseCurrency` and `targetCurrency` empty and run the service again.

Verify that the following values are close to the expected values. Exchange rates fluctuate over time.

#### First row:
| Column | Value |
|----------|--------|
| date | Current date |
| base | USD |
| quote | AED |
| rate | ~3.6725 |

#### Second row:
| Column | Value |
|----------|--------|
| date | Current date |
| base | USD |
| quote | AFN |
| rate | ~64.826 |

#### Third row:
| Column | Value |
|----------|--------|
| date | Current date |
| base | USD |
| quote | ALL |
| rate | ~82.51 |

Try different combinations of currencies and examine the results.

## Summary

In this tutorial, you used an AI assistant to generate an exchange rate retrieval Flow Services by using Flow Script Language (FSL). Starting from a high-level description of the functionality, the AI assistant generated the `GetExchangeRates` service and its supporting artifacts.

The AI assistant also:

- Generated FSL assets for the service.
- Generated Markdown documentation that describes the purpose, inputs, and outputs the service.
- Created a Mermaid diagram to visualize the service implementation.

After importing the generated asset into Integration Server, you executed the `GetExchangeRates` service and verified that the results matched the expected results.

### What You Accomplished

You demonstrated how AI can be used to automate the creation and maintenance of Integration Server assets. By completing this tutorial, you:

- Generated a Flow Service from natural language requirements.
- Used built-in service catalogs to translate business requirements into Integration Server operations.
- Generated supporting documentation and a diagram automatically.
- Imported the AI-generated asset into Integration Server and validated its behavior.

This tutorial shows how AI-assisted development can accelerate service creation and also generate the documentation and metadata required to support future development and reuse.
