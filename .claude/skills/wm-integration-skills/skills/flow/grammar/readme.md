# webMethods Flow Script Language (FSL) Grammar

This directory contains the ANTLR4 grammar definitions for the Flow Script Language (FSL), a domain-specific language (DSL) designed to simplify the declaration, configuration, and structural generation of webMethods Flow Services. 

Instead of creating services manually in webMethods Designer or writing complex, type-decorated XML and JSON files, developers can create a `.flow` text file that represents a Flow Service in a human-readable format. This grammar parses that syntax, validates it against a target Integration Server schema, and translates it programmatically into live server nodes, such as `NSService` and `NSRecord`.

---

## 1. Overall Architectural Concept

The FSL grammar bridges the gap between human-readable configuration files and the metadata structures used by webMethods Integration Server. 

### From FSL to a Flow Service
1. **The FSL File:** The developer writes standard declaration blocks, such as inputs, outputs, auditing, and properties, by using clean logical notation, for example `items/productId`.
2. **ANTLR Lexer and Parser:** The FSL file is processed into an Abstract Syntax Tree (AST).
3. **The Visitor/Transpiler Pipeline:** The compiler traverses the tree, cross-references fields against live structural schemas through server reflection APIs (`NSField.getPath()`), and converts user entries into native metadata formats. For example, resolving `items/productId` into `/items;2;1/productId;1;0`.
4. **Server Materialization:** The compiler populates the runtime Java objects on the Integration Server directly.

---

## 2. Grammar Hierarchy and Inheritance

The grammar uses a modular inheritance model. ANTLR4's `import` mechanism is used to separate distinct domain responsibilities while providing a single parser entry point in `FlowService.g4`. 

Dependencies are organized from specific domain fragments to universal atomic tokens:

                      ┌───────────────────────────────────┐
                      │          FlowService.g4           │
                      │     (Unified Logic and Parser)      │
                      └────┬───────────────┬────────────┬─┘
                           │               │            │
                (imports)  │     (imports) │            │ (imports)
        ┌──────────────────┴─┐   ┌─────────┴─────────┐  │
        │ServiceProperties.g4│   │ServiceAuditing.g4 │  │
        │ (Service Metadata) │   │ (Pipeline Audit)  │  │
        └────────────────────┘   └───────────────────┘  │
                                                        ▼
                                             ┌────────────────────┐
                                             │ ServiceSignature.g4│
                                             │ (Pipeline Schema)  │
                                             └──────────┬─────────┘
                                                        │ (imports)
                                                        ▼
                                             ┌────────────────────┐
                                             │    Document.g4     │
                                             │(Hierarchical Data) │
                                             └──────────┬─────────┘
                                                        │ (imports)
                                                        ▼
                                             ┌────────────────────┐
                                             │CommonProperties.g4 │
                                             │(Primitives & Base) │
                                             └──────────┬─────────┘
                                                        │ (tokenVocab)
                                                        ▼
                                             ┌────────────────────┐
                                             │   AssetLexer.g4    │
                                             │  (Lexical Tokens)  │
                                             └────────────────────┘
    ---

## 3. File Breakdown and Domain Responsibilities

### 📄 `AssetLexer.g4`
* **Role:** The foundational lexer.
* **Responsibility:** Contains atomic lexical token definitions, string literal rules, brackets, separators, whitespaces, and identifier patterns. It strips quotes away from text blocks and handles raw terminal evaluations. 
* **Key Components:** `STRING_LITERAL`, `IDENTIFIER`, `NUMBER`, `LBRACK`, `RBRACK`, `COLON`, `COMMA`.

### 📄 `CommonProperties.g4`
* **Role:** Universal Integration Server Asset Base.
* **Responsibility:** Captures the core structural block configuration shared by all webMethods metadata nodes. Any property that is common to all Integration Server assets, such as asset descriptions, versioning rules, ACL permissions, or lifecycle states, lives here. Both documents and services inherit from this block to ensure global property consistency across the entire ecosystem.
* **Key Components:** `assetDescription`, `assetVersion`, Universal key-value assignments.

### 📄 `Document.g4`
* **Role:** Data Schema Structure and Record Type Modeler.
* **Responsibility:** Handles nested, recursive document definitions. It imports `CommonProperties.g4` so that stand-alone Document Types (Records) instantly gain access to standard asset metadata. It then layers on explicit variable behaviors, distinguishing between fields, records, and record lists (`record { ... }`).
* **Key Components:** Field data types, structural dimensions, field-level constraint rules, and localized document structures.

### 📄 `ServiceSignature.g4`
* **Role:** Pipeline Signature Definer.
* **Responsibility:** Standardizes the input and output signature layout. It maps how a service receives its pipeline and maps its output pipeline, relying extensively on `Document.g4` definitions to construct complex operational wrappers.
* **Key Components:** `inputBlock: 'input' '{' recordField* '}';`, `outputBlock: 'output' '{' recordField* '}';`.

### 📄 `ServiceAuditing.g4`
* **Role:** Service Logging and Pipeline Audit Mapper.
* **Responsibility:** Governs pipeline audit criteria configurations. It allows developers to feed flat string arrays of logical fields to be logged at runtime execution borders. The transpiler translates these definitions against the compiled structural signature to produce the type-decorated internal path grids.
* **Key Components:** `inputLoggedFields`, `outputLoggedFields`, logging level flags, and execution status tracking parameters.

### 📄 `ServiceProperties.g4`
* **Role:** Operational Metadata Module.
* **Responsibility:** Specifies properties unique to services, including timeout properties, retry constraints, transactional controls, and error handling settings.
* **Key Components:** Captures critical service-level configuration categories including **Run time**, **Transient error handling**, **Audit**, **Circuit breaker**, and **Concurrent request limits**.

### 📄 `FlowService.g4`
* **Location:** `com/wm/lang/flow/wmflow/antlr/FlowService.g4`
* **Role:** Root Compiler Orchestrator and Imperative Processing Logic Definer.
* **Responsibility:** The primary main entry point parsed by ANTLR. It links the declarative metadata wrappers, such as signatures, auditing, and properties, directly to the **actual processing steps**. It translates programmatic expressions, control logic structures, pipeline transformations, and loops directly into their native server `FlowElement` implementations.
* **Key Components:** Root execution targets (`flowServiceRule`), which pull definitions from the entire cascade.
