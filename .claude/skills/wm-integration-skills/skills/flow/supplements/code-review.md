# webMethods Code Review Rules

**Source**: ISCCR (Integration Server Continuous Code Review)  
**Purpose**: Automated code quality checks for webMethods Integration Server packages

---

## Flow Quality Checks

### FQ1: Pipeline Services
**Severity**: Error  
**Description**: No Save/Restore/Trace Pipeline services should exist within the flow service. These result in unnecessary I/O and reduced performance.

**Prohibited Services**:
- `pub.flow:savePipeline`
- `pub.flow:savePipelineToFile`
- `pub.flow:restorePipeline`
- `pub.flow:restorePipelineFromFile`
- `pub.flow:tracePipeline`

**Recommendation**: Delete these services from flows before deployment to non-development environments.

---

### FQ2: Clear Pipeline
**Severity**: Error  
**Description**: The ClearPipeline service should not be used as pipeline variables should be dropped immediately as soon as they are no longer required.

**Prohibited Services**:
- `pub.flow:clearPipeline`

**Checks**: Ensure pipeline variables are dropped immediately after use. ClearPipeline leads to unnecessary overhead when the pipeline is walked to determine whether to preserve or drop variables.

**Recommendation**: Remove any use of clearPipeline and drop variables once they are no longer needed. ClearPipeline leads to unnecessary overhead when the pipeline is walked to determine whether to preserve or drop variables.

---

### FQ3: Deprecated Services

#### FQ3_v9: Deprecated Services (v9)
**Severity**: Error  
**Description**: Use of deprecated services is not recommended as these will be dropped from the product in a future release.

**Deprecated Services (v9)**:
- `pub.flow:setResponse`
- `pub.client:soapHTTP`
- `pub.client:soapRPC`
- `pub.event.eda:eventToDocument`
- `pub.event.eda:send`
- `pub.publish:syncToBroker`
- `pub.security:setKeyAndChain`
- `pub.security.pkcs7:sign`
- `pub.smime:createSignedAndEncryptedData`
- `pub.smime:createSignedData`
- `pub.smime:processEncryptedData`
- `pub.soap.handler:*` (all services)
- `pub.soap.processor:*` (all services)
- `pub.pki.*` (all services)
- `wm.server.pki.*` (all services)
- `pub.vcs.*` (all services)
- `wm.server.vcs.*` (all services)
- `wm.vcs.*` (all services)

#### FQ3_v10.0: Deprecated Services (v10.0)
**Deprecated Services (v10.0)**:
- `pub.event.nerv:eventToDocument`
- `pub.event.nerv:send`
- `pub.event.nerv:subscribe`
- `pub.event.nerv:unsubscribe`

#### FQ3_v10.1: Deprecated Services (v10.1)
**Deprecated Services (v10.1)**:
- `pub.restV2:listAllRESTResources`

#### FQ3_v10.2: Deprecated Services (v10.2)
**Deprecated Services (v10.2)**:
- `pub.jms.wmjms:receiveStream`
- `pub.jms.wmjms:sendStream`
- `pub.oauth:getAccessToken`
- `pub.oauth:refreshAccessToken`

#### FQ3_v10.5: Deprecated Services (v10.5)
**Deprecated Services (v10.5)**:
- `pub.date:dateBuild`
- `pub.date:dateTimeBuild`
- `pub.date:incrementDate`

#### FQ3_v10.15: Deprecated Services (v10.15)
**Deprecated Services (v10.15)**:
- `pub.metadata.assets:publishPackages`

#### FQ3_v11.1: Deprecated Services (v11.1)
**Deprecated Services (v11.1)**:
- `pub.client.oauth:executeRequest` → Use `pub.client:http` with `auth/type = Bearer` and `auth/token` set to client access token
- `pub.flow:setResponse` → Use `pub.flow:setHTTPResponse`
- `pub.flow:setResponse2` → Use `pub.flow:setHTTPResponse`
- `pub.flow:setResponseCode` → Use `pub.flow:setHTTPResponse`
- `pub.flow:setResponseHeader` → Use `pub.flow:setHTTPResponse`
- `pub.flow:setReponseHeaders` → Use `pub.flow:setHTTPResponse`
- `pub.json:documentToJSONString` → Use `pub.json:documentToJSON`

#### FQ3_v12.1: Deprecated Services (v12.1)
**Deprecated Services (v12.1)**:
- `pub.websocket:getCookies` - No replacement
- `pub.streaming:send` → Use `pub.eda:send`


**Recommendation**: Refer to the built-in-services-guide for replacements and modify flows to remove deprecated services.

---

### FQ3_v11.1_REMOVED: Removed Services (v11.1)
**Severity**: Error  
**Description**: These services have been removed in v11.1 and have no replacement.

**Removed Services (v11.1)**:
- `pub.event.eda:event` - No replacement
- `pub.event.eda:eventToDocument` - No replacement
- `pub.event.eda:schema_event` - No replacement
- `pub.event.routing:eventAcknowledgement` - No replacement
- `pub.event.routing:send` - No replacement
- `pub.event.routing:subscribe` - No replacement
- `pub.event.routing:unsubscribe` - No replacement

**Recommendation**: Remove these services from flows. Re-architect solutions that depend on these services.

---

### FQ3_v11.1_CHANGED: Changed Services (v11.1)
**Severity**: Info  
**Description**: These services have been enhanced in v11.1 with new parameters or functionality.

**Changed Services (v11.1)**:

#### `pub.client:http`
- **New Parameters**: `keyStoreAlias`, `keyAlias`, `hostNameVerification`, `cipherSuites`, `checkCRL`
- **Purpose**: Enhanced security in HTTP requests

#### `pub.client.sftp:put`
- **New Parameters**: `localFileNameEncoding`, `remoteFileNameEncoding`
- **Purpose**: Specify character set encoding for local and remote files

#### `pub.flow:transportInfo`
- **Changes**: Document type now includes fields for streaming transportation

#### `pub.json:documentToJSONString`
- **New Parameters**: 
  - `encodeListsAndSetsAsArrays` - Encode java.util.List and java.util.Set as array or String
  - `encodeMapAsString` - Specify how to encode java.util.Map objects

#### `pub.mime:getEnvelopeStream`
- **New Parameters**: `returnMimeMessage`
- **Purpose**: Control whether MIME message is returned as javax.mail.internet.MimeMessage instead of java.io.InputStream when body parts exceed large data threshold

#### `pub.oauth:getToken`
- **New Parameters**: `token_label`
- **Purpose**: Assign a label to the token to specify its purpose

#### `pub.oauth:removeExpiredAccessTokens`
- **Changes**: Now deletes expired tokens in batches instead of single SQL statement
- **Configuration**: Batch size controlled by `watt.server.oauth.token.removal.batchSize`
- **Benefit**: Improved performance for large numbers of expired tokens

#### `pub.security:encrypt`
- **New Parameters**: `securityProvider`, `truststoreAlias`, `certAlias`, `cipher`, `encryptionAlgorithm`
- **Purpose**: Support for JCE encryption

#### `pub.security:decrypt`
- **New Parameters**: `securityProvider`, `keyStoreAlias`, `keyAlias`, `cipher`
- **Purpose**: Support for JCE encryption

#### `pub.security:decryptAndVerify`
- **New Parameters**: `securityProvider`, `keyStoreAlias`, `keyAlias`, `truststoreAlias`, `certAlias`, `cipher`, `signingAlgorithm`
- **Purpose**: Support for JCE encryption

#### `pub.security:sign`
- **New Parameters**: `securityProvider`, `keyStoreAlias`, `keyAlias`, `signingAlgorithm`
- **Purpose**: Support for JCE encryption

#### `pub.security:signAndEncrypt`
- **New Parameters**: `securityProvider`, `keyStoreAlias`, `keyAlias`, `signingAlgorithm`, `truststoreAlias`, `certAlias`, `cipher`, `encryptionAlgorithm`
- **Purpose**: Support for JCE encryption

#### `pub.security:verify`
- **New Parameters**: `securityProvider`, `truststoreAlias`, `certAlias`, `signingAlgorithm`, `actualData`
- **Purpose**: Support for JCE encryption and verification

#### `pub.xml:documentToXMLString`
- **New Parameters**: `prettyPrint`
- **Purpose**: Perform pretty print formatting for XML String output

#### `pub.xml:xmlNodeToDocument`
- **New Parameters**: `treatXsiNilAsNull`
- **Purpose**: Consider xsi:nil attribute of empty XML tag as null in resulting XML string

**Recommendation**: Review usage of these services and consider using new parameters for enhanced functionality.

---

### FQ4: Disabled Services
**Severity**: Error  
**Description**: Disabled services should be removed to avoid performance issues as the flow is interpreted during execution.

**Rule**: No flow steps should have `DISABLED='true'` attribute

**Recommendation**: Delete rather than disable any code no longer needed. This results in smaller, more maintainable flow services.

---

### FQ5: Use of pub.storage
**Severity**: Error  
**Description**: pub.storage services should not be used due to performance issues. These services have an implicit locking model and are not intended to be a high-performance all-purpose database.

**Prohibited Services**:
- `pub.storage.*` (all services)

**Recommendation**: Re-architect these services, particularly in high-throughput scenarios.

---

### FQ6: Debug Log
**Severity**: Error  
**Description**: Debug Log services should be removed to avoid performance issues during execution.

**Prohibited Services**:
- `pub.flow:debugLog`

**Recommendation**: Implement a more general purpose and configurable logging framework to keep logs manageable and separate from product logging.

---

### FQ7: Public Services Try/Catch
**Severity**: Error  
**Description**: Public services must have a try/catch within them to ensure graceful handling of error conditions.

**Rule**: Public services (matching pattern `^%folder-prefix%\.*\S*\.pub[\.\:]\S*`) must contain:
- Either: `SEQUENCE[@FORM="TRY"]` with nested `SEQUENCE[@FORM="CATCH"]`
- Or: `SEQUENCE[@EXIT-ON='SUCCESS']` with child `SEQUENCE[@EXIT-ON='FAILURE']` and `SEQUENCE[@EXIT-ON='DONE']`

**Recommendation**: Use Sequence nodes to wrap execution within a try/catch block. Add comments to sequences to aid understanding.

---

### FQ8: Connections Package
**Severity**: Error  
**Description**: All JDBC Adapter connections should be in separate packages. A package should not contain connections mixed with other assets.

**Rule**: Packages must be either connection packages OR service packages, not both

**Recommendation**: Have adapter connections in packages on their own to aid deployment without affecting database connections.

---

### FQ9: FTP Timeout
**Severity**: Error  
**Description**: Ensure timeout is specified on FTP services. Without timeout, the default is unlimited, potentially consuming threads for long periods.

**Rule**: `pub.client.ftp:login` invocations must include `/timeout` parameter

**Recommendation**: Add a timeout value to FTP service invocations.

---

### FQ10: Service Invoke Comments
**Severity**: Warning  
**Description**: Comments should be provided for each service that is invoked from the main service.

**Rule**: All `INVOKE` steps must have non-empty `COMMENT` elements

**Recommendation**: Add descriptive comments to every service invoke to improve code readability and maintainability.

---

### FQ11: Sequence Comments
**Severity**: Warning  
**Description**: Comments should be provided for each sequence node that is used.

**Rule**: All `SEQUENCE` steps (without `@FORM` attribute) must have non-empty `COMMENT` elements

**Recommendation**: Add descriptive comments to every sequence node to improve code readability and maintainability.

---

### FQ12: Unauthorised Access/Orphaned
**Severity**: Warning  
**Description**: All services within a package should be invoked through a public service.

**Rule**: Identifies assets not used directly or indirectly from a public flow service or DSP file

**Recommendation**: Ensure all services follow the public/private access principle. Remove orphaned services.

---

### FQ13: Branch Without Switch or Evaluate Labels
**Severity**: Error  
**Description**: A BRANCH step must have either a switch value or have evaluate labels set to true.

**Rule**: `BRANCH` steps must have either `@SWITCH` or `@LABELEXPRESSIONS` attribute

**Recommendation**: Specify switch value or enable evaluate labels for all BRANCH steps.

---

### FQ14: Branch on Expression with Invalid Labels
**Severity**: Error  
**Description**: When branching on expressions (Evaluate labels = True), you cannot branch on null or empty values.

**Rule**: `BRANCH[@LABELEXPRESSIONS="true"]` child steps must have non-empty `@NAME` attribute (not `$null`)

**Recommendation**: Provide valid label names for all branch targets when using expression evaluation.

---

### FQ15: Exit Node From Specification
**Severity**: Error  
**Description**: The EXIT step must specify where to exit from.

**Rule**: `EXIT` steps must have non-empty `@FROM` attribute

**Recommendation**: Specify the exit scope (flow, loop, parent step, etc.) for all EXIT steps.

---

### FQ16: Branch Step Must Have Child Nodes
**Severity**: Error  
**Description**: A Branch step must have child nodes to be relevant.

**Rule**: `BRANCH` steps must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty BRANCH steps.

---

### FQ17: Loop Step Must Have Child Nodes
**Severity**: Error  
**Description**: A Loop step must have child nodes to be relevant.

**Rule**: `LOOP` steps must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty LOOP steps.

---

### FQ18: Repeat Step Must Have Child Nodes
**Severity**: Error  
**Description**: A Repeat step must have child nodes to be relevant.

**Rule**: `RETRY` steps must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty REPEAT steps.

---

### FQ19: Sequence Step Must Have Child Nodes
**Severity**: Error  
**Description**: A Sequence step must have child nodes to be relevant.

**Rule**: `SEQUENCE` steps (without `@FORM`) must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty SEQUENCE steps.

---

### FQ20: Map Steps Must Have Mapped Fields
**Severity**: Error  
**Description**: A Map step must have mapped fields.

**Rule**: `MAP[@MODE='STANDALONE']` steps must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty MAP steps.

---

### FQ21: Loop Must Have Input Array
**Severity**: Error  
**Description**: A loop step must have an input array variable provided.

**Rule**: `LOOP` steps must have `@IN-ARRAY` attribute

**Recommendation**: Specify the input array for all LOOP steps.

---

### FQ22: Flow Service Should Not Be Empty
**Severity**: Error  
**Description**: A flow service should contain implementation.

**Rule**: `FLOW` element must have at least one child element (excluding `COMMENT` and disabled steps)

**Recommendation**: Remove empty flow services from the package.

---

### FQ23: Try Step Must Have Child Nodes (v10.3+)
**Severity**: Error  
**Description**: A try step must have child nodes to be relevant.

**Rule**: `SEQUENCE[@FORM='TRY']` must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty TRY steps.

---

### FQ24: Catch Step Must Have Child Nodes (v10.3+)
**Severity**: Error  
**Description**: A catch step must have child nodes to be relevant.

**Rule**: `SEQUENCE[@FORM='CATCH']` must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty CATCH steps.

---

### FQ25: Finally Step Must Have Child Nodes (v10.3+)
**Severity**: Error  
**Description**: A finally step must have child nodes to be relevant.

**Rule**: `SEQUENCE[@FORM='FINALLY']` must have at least one child element (excluding `COMMENT`)

**Recommendation**: Delete empty FINALLY steps.

---

### FQ99: References to Assets Should Exist (Optional)
**Severity**: Warning  
**Description**: References to other assets (invocations, document references) should exist.

**Rule**: All service references in `INVOKE/@SERVICE`, `MAPINVOKE/@SERVICE`, document references, and Java Service.doInvoke calls should resolve to existing assets

**Recommendation**: Ensure all referenced services and documents exist in the package or dependencies.

---

## Naming Standards Checks

### NS1: Root Folder Name
**Severity**: Error  
**Description**: Root folder should not be the same as the package name to avoid namespace issues.

**Rule**: Root folder name must not equal package name

**Recommendation**: Use a separate prefix folder structure (e.g., inverse domain name like "com.softwareag").

---

### NS2: Folder Name
**Severity**: Error  
**Description**: Folders should only contain lowercase ASCII characters and digits.

**Rule**: Folder names must match pattern: `[a-z]{1}[a-z0-9_]*|_{1}[a-z0-9A-Z_]*`

**Recommendation**: Use lowercase letters, digits, and underscores (sparingly) for folder names.

---

### NS3: Folder Prefix
**Severity**: Error  
**Description**: Ensure all assets exist within the specified prefix folders.

**Rule**: All assets must be under the configured folder prefix

**Recommendation**: Use consistent folder prefix across all packages (e.g., "com.softwareag").

---

### NS4: Package Name
**Severity**: Error  
**Description**: Package name must conform to standards.

**Rules**:
1. Must not end with "Package" or "Pkg"
2. Must not be prefixed with "Wm" (reserved for webMethods packages)
3. Must start with uppercase character
4. Must match pattern: `[A-Z]{1}[a-zA-Z0-9_]*`
5. Must start with configured package prefix

**Recommendation**: Use PascalCase for package names with organizational prefix.

---

### NS5: Service Name
**Severity**: Error  
**Description**: Services must conform to naming standards.

**Rule**: Service names must match pattern: `_get|_post|_delete|_put|_head|_default|_insert|_retrieve|_update|[a-z]{1}[a-zA-Z0-9]*`

**Recommendation**: Use camelCase starting with lowercase letter (except for generated REST services).

---

### NS6: Document Name
**Severity**: Error  
**Description**: Document definition names must conform to naming standards.

**Rule**: Document names must match pattern: `[A-Z]{1}[a-zA-Z0-9_]*|docTypeRef_[a-zA-Z0-9]+_[a-zA-Z0-9]*`

**Recommendation**: Use PascalCase starting with uppercase letter. XSD-generated documents may use `docTypeRef_*` pattern.

---

### NS7: Schema Name
**Severity**: Error  
**Description**: Schema definitions must conform to naming standards.

**Rule**: Schema names must match pattern: `schema_[A-Z]{1}[a-zA-Z0-9_]*|[A-Z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use PascalCase starting with uppercase letter. May optionally prefix with `schema_`.

---

### NS8: FlatFile Name
**Severity**: Error  
**Description**: Flat File Dictionaries and Schemas must conform to naming standards.

**Rule**: FlatFile names must match pattern: `[A-Z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use PascalCase starting with uppercase letter.

---

### NS9: Blaze Name
**Severity**: Error  
**Description**: Blaze Rules must conform to naming standards.

**Rule**: Blaze rule names must match pattern: `[a-zA-Z0-9_]*`

**Recommendation**: Use alphanumeric characters and underscores (sparingly).

---

### NS10: XSL Name
**Severity**: Error  
**Description**: XSL Services must conform to naming standards.

**Rule**: XSL service names must match pattern: `[a-z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use camelCase starting with lowercase letter.

---

### NS11: Adapter Name
**Severity**: Error  
**Description**: Adapter Services must conform to naming standards.

**Rule**: Adapter service names must match pattern: `[a-z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use camelCase starting with lowercase letter.

---

### NS12: Trigger Name
**Severity**: Error  
**Description**: Triggers must conform to naming standards.

**Rule**: Trigger names must match pattern: `[a-z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use camelCase starting with lowercase letter.

---

### NS13: WSD Name
**Severity**: Error  
**Description**: WSDs must conform to naming standards.

**Rule**: WSD names must match pattern: `[a-z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use camelCase starting with lowercase letter.

---

### NS14: Connection Name
**Severity**: Error  
**Description**: Connections must conform to naming standards.

**Rule**: Connection names must match pattern: `[A-Z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use PascalCase starting with uppercase letter.

---

### NS15: Document Variable Name
**Severity**: Error  
**Description**: Variable names within document definitions must conform to naming standards.

**Rule**: Document field names must match pattern: `[a-z]{1}[a-zA-Z0-9]*|\@[a-z]{1}[a-zA-Z0-9]*|[a-zA-Z0-9]*\:[a-zA-Z]{1}[a-zA-Z0-9_\-]*|_env`

**Recommendation**: Use camelCase starting with lowercase letter. XSD-generated documents may include namespace prefixes and special characters.

---

### NS16: Service Signature Name
**Severity**: Error  
**Description**: Input/Output variables in service signatures must conform to naming standards.

**Rule**: Signature field names must match pattern: `\$filter|\$select|\$top|\$skip|\$count|\$orderby|\$inlinecount|\$resourceID|\$path|\$httpMethod|flow.inputs|flow.outputs|ProcessData|TaskData|TaskCompletionInfo|TaskQueueInfo|JMSMessage|JMSType|ActionEvent|ChallengeEvent|[a-z]{1}[a-zA-Z0-9]*`

**Recommendation**: Use camelCase starting with lowercase letter (except for system-generated variables).

---

### NS17: REST Resource Name
**Severity**: Error  
**Description**: REST Resources must conform to naming standards.

**Rule**: REST resource names must match pattern: `[a-z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use camelCase starting with lowercase letter.

---

### NS18: REST Descriptor Name
**Severity**: Error  
**Description**: REST Descriptors must conform to naming standards.

**Rule**: REST descriptor names must match pattern: `[a-z]{1}[a-zA-Z0-9_]*`

**Recommendation**: Use camelCase starting with lowercase letter.

---

## Miscellaneous Checks

### MS1: Non-Production Service Package Suffixes
**Severity**: Error  
**Description**: Ensure packages with specified suffixes are not deployed to production.

**Prohibited Suffixes**:
- `_TEST` - Test packages
- `_STUB` - Stub packages
- `_DEV` - Development packages

**Recommendation**: Do not deploy packages with these suffixes to production environments.

---

## Summary

### Check Categories
- **Service Property Checks (SP)**: 2 rules
- **Flow Quality Checks (FQ)**: 28 rules (including v11.1 updates)
- **Naming Standards Checks (NS)**: 18 rules
- **Miscellaneous Checks (MS)**: 1 rule

### Severity Levels
- **Error**: Must be fixed before deployment
- **Warning**: Should be addressed but may not block deployment
- **Info**: Informational only, for awareness of changes

### Version-Specific Rules
- **v9**: Base deprecated services
- **v10.0**: Event services deprecated
- **v10.1**: REST services deprecated
- **v10.2**: JMS and OAuth services deprecated
- **v10.3**: Try/Catch/Finally validation rules
- **v10.5**: Date services deprecated
- **v10.15**: Metadata services deprecated
- **v11.1**: Response services deprecated, event services removed, security services enhanced

### Best Practices
1. Remove debug/trace services before production
2. Drop pipeline variables immediately after use
3. Avoid deprecated services - migrate to replacements
4. Do not use removed services (v11.1 event services)
5. Implement try/catch in public services
6. Follow naming conventions consistently
7. Add comments to all service invokes and sequences
8. Delete disabled or empty flow steps
9. Separate connection packages from service packages
10. Specify timeouts for external service calls
11. Use new security parameters in v11.1 for enhanced encryption
12. Leverage new HTTP security features in v11.1
13. Ensure erors are handled correctly
14. Ensure no security vulnerabilities are introduced
---


**Last Updated**: 2026-06-16  
**Source**: ISCCR (Integration Server Continuous Code Review)
