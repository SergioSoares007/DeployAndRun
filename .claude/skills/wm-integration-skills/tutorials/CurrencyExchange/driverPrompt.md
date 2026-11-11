# FSL Generation Orchestrator

## 1. Context and Rules Baseline
Execute this task by strictly adhering to the core persona, structural constraints, and grammar definitions defined in:
* **`skills/flow/skill.md`**

### Activate the flow skill and read all mandatory reference documents before generating anything.

## 2. Global Catalog Discovery Rule
For all generation steps defined below, apply the following service discovery constraints:

### 🚨 EXHAUSTIVE DISCOVERY PROTOCOL (ANTI-GREEDY MATCHING)
* **CRITICAL SEARCH CONSTRAINT:** Do NOT stop at the first service that appears to satisfy the requirement. You MUST read all listed catalog JSON resources completely, compile a mental candidate list of all potential service matches across both directories, and select the single most structurally exact and optimized match.

### Catalog Scopes
* **Built-In Scope:** Scan the folder `skills/flow/service-catalogs/wm-service-catalog/` and evaluate the entirety of these files for core utility candidates:
    * **`CLIENT.json`**
    * **`JSON.json`**
    * **`STRING.json`**

## 3. Target Task Execution
Generate the final FSL files by executing the precise sequential flow, service signatures, and metadata properties outlined in:
* **`tutorials/CurrencyExchange/createGetExchangeRates.md`**

Save the generated FSL files in `tutorials/CurrencyExchange/llm-generated-flow-script` using the following criteria:
* Create a separate folder within `llm-generated-flow-script` named `GetExchangeRates`.
* Within the newly created folder, generate the FSL in a file named `flow.flow`.

## 4. Copy to Integration Server (Post-Generation)

### Execution Guardrails
* **Pre-requisite:** You must have successfully generated `flow.flow` inside the `tutorials/CurrencyExchange/llm-generated-flow-script/GetExchangeRates/` directory.
* **Failure Handling:** If any structural or path condition below fails, you must immediately abort this step, inform the user explicitly of the reason (e.g., "WEBMETHODS_HOME path invalid"), and jump directly to **Step 5**.

### File System Path Validation Sequence
1. **Environment Check:** Parse the file `tutorials/.config/environment.md`. Retrieve the value defined for the property `WEBMETHODS_HOME`.
   * If `WEBMETHODS_HOME` is empty, set to `<PATH_TO_WEBMETHODS_INSTALLATION>`, or points to a non-existent host directory ➡ **Abort to Step 5**.
2. **Integration Server Root Check:** Scan the resolved `WEBMETHODS_HOME` directory for a child directory named `IntegrationServer`.
   * If `IntegrationServer` does not exist ➡ **Abort to Step 5**.
3. **Topology Topology Discovery:** Inspect the `IntegrationServer/` directory structure:
   * **Case A (Multi-Instance Layout):** If a directory named `instances/` exists, locate the active instance directory (default is `instances/default/`). Your target installation root becomes:  
     `[WEBMETHODS_HOME]/IntegrationServer/instances/[instance_name]/packages`
   * **Case B (webMethods Microservices Runtime):** If `instances/` does not exist but a `packages/` directory exists directly under the root, your target installation root becomes:  
     `[WEBMETHODS_HOME]/IntegrationServer/packages`
   * If neither Case A nor Case B can be resolved ➡ **Abort to Step 5**.

### Deployment Target Validation & Injection
1. **Target Package Verification:** Verify that the target package container exists at:  
   `[Target Installation Root]/CurrencyExchange/`
   * If the `CurrencyExchange` directory does not exist ➡ **Abort to Step 5**.
2. **Namespace Path Verification:** Check for the explicit target namespace folder boundary:  
   `[Target Installation Root]/CurrencyExchange/ns/exchange/`
   * If the `ns/exchange/` directory path does not exist ➡ **Abort to Step 5**.
3. **Asset Deployment Execution:** Execute an asset copy/injection operation:
   * **Source Directory:** `tutorials/CurrencyExchange/llm-generated-flow-script/GetExchangeRates/`
   * **Destination Parent:** `[Target Installation Root]/CurrencyExchange/ns/exchange/`
   * **Result:** The entire `GetExchangeRates` folder and its inner `flow.flow` file will be copied directly into the `exchange` namespace, resulting in the clean deployment path: `[Target Installation Root]/CurrencyExchange/ns/exchange/GetExchangeRates/flow.flow`.

## 5. Matching Markdown Documentation Protocol (Post-Generation)
**Mandatory Rule**: The generated script file (e.g., `ServiceName.flow`) MUST have a corresponding Markdown documentation file (ServiceName.md) generated in the directory: `tutorials/Currencyexchange/llm-generated-flow-script`. Do not put the markdown file in the same directories as the .flow file.
**Naming**: The names of the markdown file should match the service name for the FSL being generated. E.g.: GetExchangeRates.md

### Output Formatting
Follow the instructions in `tutorials/.config/service-documentation.md` for formatting service documentation.

## 6. Mermaid Diagram Generation (Mandatory Completion Gate)
Generate clean, highly structured Mermaid.js flowchart configurations representing the FSL `.flow` file you have just created.

### Required Services
You must generate one Mermaid diagram for:
- `GetExchangeRates`

### Output File Requirements
Write exactly this file:
- `tutorials/CurrencyExchange/diagrams/GetExchangeRates.mmd`

The file must contain raw Mermaid syntax only, with no Markdown wrapper, no title heading, and no surrounding prose.

### Diagram Content Requirements
For each service diagram, include:
- Start and end nodes
- Input parsing or initialization nodes
- All major `MAP`, `INVOKE`, `TRANSFORM`, loop, and branch structures
- Labels that reflect the actual generated service logic
- Distinct styling classes for map nodes, invoke/transform nodes, loop nodes, and branch nodes

### Formatting Constraints
1. Use raw Mermaid syntax only.
2. Do not include Markdown code fences, headings, or explanatory prose.
3. Apply structural color themes to distinct FSL components (for example: map nodes blue, invoke/transform nodes orange, loop structures purple, and conditional branches red).
4. Ensure each diagram reflects the generated FSL structure, not a generic summary.

### File Path Requirement
Write your files into:
`tutorials/CurrencyExchange/diagrams`

### Output Formatting
Follow the instructions in tutorials/.config/mermaid-config.md for formatting the Mermaid diagrams.

## 7. Final Deliverables Checklist
Do not declare the task complete until all required deliverables have been created and saved successfully.

### Required Deliverables
- FSL files in `tutorials/CurrencyExchange/llm-generated-flow-script`
- Matching Markdown documentation files in `tutorials/CurrencyExchange/llm-generated-flow-script`
- Mermaid diagram `.mmd` files in `tutorials/CurrencyExchange/diagrams`

### Completion Rule
The task is **NOT** complete until every deliverable listed above exists and has been written successfully.

### Final Verification Requirement
Before declaring completion, verify that:
1. All required `.flow` files exist in `tutorials/CurrencyExchange/llm-generated-flow-script`
2. All matching documentation `.md` files exist in `tutorials/CurrencyExchange/llm-generated-flow-script`
3. All Mermaid diagram `.mmd` files exist in `tutorials/CurrencyExchange/diagrams`
