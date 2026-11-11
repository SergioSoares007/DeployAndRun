# webMethods Version Upgrade Guide

**Purpose**: Track deprecated, removed, and changed services, flow constructs and other features across webMethods Integration Server versions  
**Use Case**: Version upgrade planning and migration assessment

---

## Version 10.15

### Removed Services

#### `pub.metadata.assets:publishPackages`
- **Status**: Removed
- **Replacement**: None
- **Reason**: WmAssetPublisher package has been removed
- **Action**: Remove all references to this service

---

### Changed Services

#### `pub.alert.notifier:create`
- **Removed Parameter**: `smtpSender/secure/useJSSE`
- **Behavior**: All outbound connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if useJSSE=yes)

#### `pub.alert.notifier:update`
- **Removed Parameter**: `smtpSender/secure/useJSSE`
- **Behavior**: All outbound connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if useJSSE=yes)

#### `pub.alert.notifier:list`
- **Removed Parameter**: `smtpSender/secure/useJSSE` (output parameter)

#### `pub.client:http`
- **Removed Parameter**: `useJSSE`
- **Behavior**: All connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if useJSSE=yes)

#### `pub.client:smtp`
- **Removed Parameter**: `useJSSE`
- **Behavior**: All connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if useJSSE=yes)

#### `pub.client:soapClient`
- **Removed Parameter**: `useJSSE`
- **Behavior**: All connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if useJSSE=yes)

#### `pub.client:ftp`
- **Removed Parameter**: `secure/useJSSE`
- **Behavior**: All connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if secure/useJSSE=yes)

#### `pub.client.ftp:login`
- **Removed Parameter**: `secure/useJSSE`
- **Behavior**: All connections now use JSSE by default
- **Migration Note**: Parameter ignored if present in migrated services (proceeds as if secure/useJSSE=yes)

#### `pub.file:getFile`
- **New Parameter**: `largeFile` (optional)
- **Type**: Boolean
- **Purpose**: Indicates whether the specified file is a large file
- **Migration Impact**: None - optional parameter

#### `pub.json:documentToJSONString`
- **New Parameters**: 
  - `encodeStringAsBoolean` - If true, converts boolean values in string format to boolean by removing quotes
  - `encodeStringAsNumber` - If true, converts numbers in string format to number by removing quotes
- **Migration Impact**: None - optional parameters

#### `pub.security:encrypt`
- **New Parameter**: `publicKeyString` (optional)
- **Purpose**: Provide one or more public keys as strings to encrypt data for multiple recipients
- **New Output**: `string` - Returns encrypted data as ASCII-armored string when input is string
- **Changed Parameter**: `publicKeyBytes` - Type changed from Byte Array to Object List (for multiple public key files)
- **Changed Parameter**: `publicKeyAlias` - Type changed from String to String List (for multiple public key aliases)
- **Migration Impact**: Update parameter types if using publicKeyBytes or publicKeyAlias

#### `pub.security:decrypt`
- **New Parameter**: `secretKeyString` (optional)
- **Purpose**: Provide secret key as string to decrypt data
- **New Output**: `string` - Returns decrypted data as string when input is string
- **Migration Impact**: None - optional parameter

#### `pub.security:decryptAndVerify`
- **New Parameters**: 
  - `secretKeyString` (optional) - Pass secret key as string for decryption
  - `publicKeyString` (optional) - Provide public keys as strings for signature verification
- **New Output**: `string` - Returns decrypted and verified data as string when input is string
- **Changed Parameter**: `publicKeyBytes` - Type changed from Byte Array to Object List
- **Changed Parameter**: `publicKeyAlias` - Type changed from String to String List
- **Migration Impact**: Update parameter types if using publicKeyBytes or publicKeyAlias

#### `pub.security:sign`
- **New Parameter**: `secretKeyString` (optional)
- **Purpose**: Pass secret key as string to sign data
- **New Output**: `string` - Returns signed data as ASCII-armored string when input is string
- **Migration Impact**: None - optional parameter

#### `pub.security:signAndEncrypt`
- **New Parameters**: 
  - `secretKeyString` (optional) - Pass secret key as string for signing
  - `publicKeyString` (optional) - Provide public keys as strings for encryption
- **New Output**: `string` - Returns signed and encrypted data as ASCII-armored string when input is string
- **Changed Parameter**: `publicKeyBytes` - Type changed from Byte Array to Object List
- **Changed Parameter**: `publicKeyAlias` - Type changed from String to String List
- **Migration Impact**: Update parameter types if using publicKeyBytes or publicKeyAlias

#### `pub.security:verify`
- **New Parameter**: `publicKeyString` (optional)
- **Purpose**: Provide public keys as strings to verify signed data
- **New Output**: `string` - Returns verified data as string when input is signed string
- **Changed Parameter**: `publicKeyBytes` - Type changed from Byte Array to Object List
- **Changed Parameter**: `publicKeyAlias` - Type changed from String to String List
- **Migration Impact**: Update parameter types if using publicKeyBytes or publicKeyAlias

#### `pub.xml:queryXMLNode`
- **Removed Support**: String Table as `resultType`
- **Migration Impact**: Update services using String Table resultType to use alternative result types

---

## Version 11.1

### Removed Services

#### `pub.event.eda:event`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

#### `pub.event.eda:eventToDocument`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

#### `pub.event.eda:schema_event`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

#### `pub.event.routing:eventAcknowledgement`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

#### `pub.event.routing:send`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

#### `pub.event.routing:subscribe`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

#### `pub.event.routing:unsubscribe`
- **Status**: Removed
- **Replacement**: None
- **Action**: Re-architect solutions using this service

---

### Deprecated Services

#### `pub.client.oauth:executeRequest`
- **Status**: Deprecated
- **Replacement**: `pub.client:http`
- **Migration**: Set `auth/type = Bearer` and `auth/token` to the client access token

#### `pub.flow:setResponse`
- **Status**: Deprecated
- **Replacement**: `pub.flow:setHTTPResponse`
- **Migration**: Update all invocations to use setHTTPResponse

#### `pub.flow:setResponse2`
- **Status**: Deprecated
- **Replacement**: `pub.flow:setHTTPResponse`
- **Migration**: Update all invocations to use setHTTPResponse

#### `pub.flow:setResponseCode`
- **Status**: Deprecated
- **Replacement**: `pub.flow:setHTTPResponse`
- **Migration**: Update all invocations to use setHTTPResponse

#### `pub.flow:setResponseHeader`
- **Status**: Deprecated
- **Replacement**: `pub.flow:setHTTPResponse`
- **Migration**: Update all invocations to use setHTTPResponse

#### `pub.flow:setReponseHeaders`
- **Status**: Deprecated
- **Replacement**: `pub.flow:setHTTPResponse`
- **Migration**: Update all invocations to use setHTTPResponse

#### `pub.json:documentToJSONString`
- **Status**: Deprecated
- **Replacement**: `pub.json:documentToJSON`
- **Migration**: Update all invocations to use documentToJSON

---

### Changed Services

#### `pub.client:http`
- **New Parameters**: 
  - `keyStoreAlias` - Select key store for client authentication
  - `keyAlias` - Select private key alias for client authentication
  - `hostNameVerification` - Enable/disable hostname verification
  - `cipherSuites` - Specify allowed cipher suites
  - `checkCRL` - Enable/disable certificate revocation list checking
- **Purpose**: Enhanced security in HTTP requests
- **Migration Impact**: None - optional parameters for enhanced security

#### `pub.client.sftp:put`
- **New Parameters**: 
  - `localFileNameEncoding` - Character set encoding for local file
  - `remoteFileNameEncoding` - Character set encoding for remote file
- **Purpose**: Specify character set encoding for file names
- **Migration Impact**: None - optional parameters

#### `pub.flow:transportInfo`
- **Changes**: Document type now includes fields for streaming transportation
- **Migration Impact**: Review services using transportInfo for new fields

#### `pub.json:documentToJSONString`
- **New Parameters**: 
  - `encodeListsAndSetsAsArrays` - Encode java.util.List and java.util.Set as array or String
  - `encodeMapAsString` - Specify how to encode java.util.Map objects
- **Migration Impact**: None - optional parameters
- **Note**: Service is deprecated; migrate to pub.json:documentToJSON

#### `pub.mime:getEnvelopeStream`
- **New Parameter**: `returnMimeMessage`
- **Purpose**: Control whether MIME message is returned as javax.mail.internet.MimeMessage instead of java.io.InputStream when body parts exceed large data threshold
- **Migration Impact**: None - optional parameter

#### `pub.oauth:getToken`
- **New Parameter**: `token_label`
- **Purpose**: Assign a label to the token to specify its purpose
- **Migration Impact**: None - optional parameter

#### `pub.oauth:removeExpiredAccessTokens`
- **Changes**: Now deletes expired tokens in batches instead of single SQL statement
- **Configuration**: Batch size controlled by `watt.server.oauth.token.removal.batchSize`
- **Benefit**: Improved performance for large numbers of expired tokens
- **Migration Impact**: None - internal optimization

#### `pub.security:encrypt`
- **New Parameters**: 
  - `securityProvider` - Select security provider type (PGP or JCE-KBE)
  - `truststoreAlias` - Select trust store containing public key and certificate
  - `certAlias` - Select trusted certificate within trust store
  - `cipher` - Provide cipher for encryption
  - `encryptionAlgorithm` - Select encryption algorithm
- **Purpose**: Support for JCE encryption
- **Migration Impact**: None - optional parameters for JCE support

#### `pub.security:decrypt`
- **New Parameters**: 
  - `securityProvider` - Select security provider type (PGP or JCE-KBE)
  - `keyStoreAlias` - Select key store containing private key
  - `keyAlias` - Select private key alias for decryption
  - `cipher` - Provide cipher for decryption
- **Purpose**: Support for JCE encryption
- **Migration Impact**: None - optional parameters for JCE support

#### `pub.security:decryptAndVerify`
- **New Parameters**: 
  - `securityProvider` - Select security provider type (PGP or JCE-KBE)
  - `keyStoreAlias` - Select key store containing private key
  - `keyAlias` - Select private key alias for decryption
  - `truststoreAlias` - Select trust store containing public key and certificate
  - `certAlias` - Select trusted certificate within trust store
  - `cipher` - Provide cipher for encryption
  - `signingAlgorithm` - Select signing algorithm
- **Purpose**: Support for JCE encryption
- **Migration Impact**: None - optional parameters for JCE support

#### `pub.security:sign`
- **New Parameters**: 
  - `securityProvider` - Select security provider type (PGP or JCE-KBE)
  - `keyStoreAlias` - Select key store containing private key
  - `keyAlias` - Select private key alias
  - `signingAlgorithm` - Select signing algorithm
- **Purpose**: Support for JCE encryption
- **Migration Impact**: None - optional parameters for JCE support

#### `pub.security:signAndEncrypt`
- **New Parameters**: 
  - `securityProvider` - Select security provider type (PGP or JCE-KBE)
  - `keyStoreAlias` - Select key store containing private key
  - `keyAlias` - Select private key alias
  - `signingAlgorithm` - Select signing algorithm
  - `truststoreAlias` - Select trust store containing public key and certificate
  - `certAlias` - Select trusted certificate within trust store
  - `cipher` - Provide cipher for encryption
  - `encryptionAlgorithm` - Select encryption algorithm
- **Purpose**: Support for JCE encryption
- **Migration Impact**: None - optional parameters for JCE support

#### `pub.security:verify`
- **New Parameters**: 
  - `securityProvider` - Select security provider type (PGP or JCE-KBE)
  - `truststoreAlias` - Select trust store containing public key and certificate
  - `certAlias` - Select trusted certificate within trust store
  - `signingAlgorithm` - Select signing algorithm
  - `actualData` - Original data that was signed for verification
- **Purpose**: Support for JCE encryption and verification
- **Migration Impact**: None - optional parameters for JCE support

#### `pub.xml:documentToXMLString`
- **New Parameter**: `prettyPrint` (optional)
- **Purpose**: Perform pretty print formatting for XML String output
- **Migration Impact**: None - optional parameter

#### `pub.xml:xmlNodeToDocument`
- **New Parameter**: `treatXsiNilAsNull` (optional)
- **Purpose**: Consider xsi:nil attribute of empty XML tag as null in resulting XML string
- **Migration Impact**: None - optional parameter

---

## Migration Checklist

### Pre-Upgrade Assessment
- [ ] Identify all deprecated services in use
- [ ] Identify all removed services in use
- [ ] Review changed services for parameter type changes
- [ ] Plan migration for deprecated services
- [ ] Plan re-architecture for removed services

### Version 10.15 Migration
- [ ] Remove references to `pub.metadata.assets:publishPackages`
- [ ] Remove useJSSE parameters from client services (automatically ignored)
- [ ] Update security service parameter types (Byte Array → Object List, String → String List)
- [ ] Update pub.xml:queryXMLNode to avoid String Table resultType

### Version 11.1 Migration
- [ ] Remove all pub.event.eda:* service references
- [ ] Remove all pub.event.routing:* service references
- [ ] Replace pub.flow:setResponse* with pub.flow:setHTTPResponse
- [ ] Replace pub.client.oauth:executeRequest with pub.client:http
- [ ] Replace pub.json:documentToJSONString with pub.json:documentToJSON
- [ ] Review and leverage new security parameters for JCE encryption
- [ ] Review and leverage new HTTP security parameters

### Testing
- [ ] Test all migrated services
- [ ] Verify security service parameter changes
- [ ] Validate HTTP client security enhancements
- [ ] Test re-architected solutions for removed services

---

**Last Updated**: 2026-06-16  
**Source**: webMethods Integration Server Release Notes v10.15 and v11.1

---

## Version 12.1

### New Flow Constructs

Designer now includes additional flow steps to support common programming patterns. These constructs are **only available in v12.1 and later** and will cause compatibility issues if flows using them are deployed to earlier versions.

#### Conditional Flow Steps

##### `IF`, `ELSEIF`, `ELSE`
- **Purpose**: Execute a block of code only when a condition is true
- **Availability**: v12.1+
- **Backward Compatibility**: Not compatible with v10.15 or v11.1
- **Migration Impact**: Flows using these constructs cannot be deployed to earlier versions

#### Loop Flow Steps

##### `DO` and `UNTIL`
- **Purpose**: Repeat a block of code until a condition becomes true
- **Behavior**: Child steps execute at least once before condition is evaluated
- **Availability**: v12.1+
- **Backward Compatibility**: Not compatible with v10.15 or v11.1
- **Migration Impact**: Flows using these constructs cannot be deployed to earlier versions

##### `WHILE`
- **Purpose**: Repeat a block of code while a specified condition evaluates to true
- **Behavior**: Condition is evaluated before each iteration
- **Availability**: v12.1+
- **Backward Compatibility**: Not compatible with v10.15 or v11.1
- **Migration Impact**: Flows using these constructs cannot be deployed to earlier versions

##### `BREAK`
- **Purpose**: Stop the execution of the loop in a `DO` or `WHILE` step
- **Availability**: v12.1+
- **Backward Compatibility**: Not compatible with v10.15 or v11.1
- **Migration Impact**: Flows using these constructs cannot be deployed to earlier versions

##### `CONTINUE`
- **Purpose**: Exit the current iteration of a `DO` or `WHILE` loop and start the next iteration
- **Availability**: v12.1+
- **Backward Compatibility**: Not compatible with v10.15 or v11.1
- **Migration Impact**: Flows using these constructs cannot be deployed to earlier versions

#### Switch Flow Steps

##### `SWITCH` and `CASE`
- **Purpose**: Conditionally execute a child `CASE` step based on the value of a variable
- **Behavior**:
  - `SWITCH` step identifies the variable to check
  - `CASE` steps specify possible values for the switch variable
  - Integration Server executes the child `CASE` step whose value matches the switch variable value at run time
- **Availability**: v12.1+
- **Backward Compatibility**: Not compatible with v10.15 or v11.1
- **Migration Impact**: Flows using these constructs cannot be deployed to earlier versions

---

### Removed Services

#### `pub.client.oauth:executeRequest`
- **Status**: Removed (was deprecated in v11.1)
- **Replacement**: `pub.client:http`
- **Migration**: Set `auth/type = Bearer` and `auth/token` to the client access token

#### Db Folder (WmDB Package)
- **Status**: Removed (was deprecated in v7.1)
- **Services Affected**: All services in the Db folder
- **Replacement**: Use JDBC Adapter services
- **Action**: Migrate all Db folder service references to JDBC Adapter services

---

### Deprecated Services

#### `pub.websocket:getCookies`
- **Status**: Deprecated
- **Replacement**: None
- **Action**: Remove references to this service

#### `pub.streaming:send`
- **Status**: Deprecated
- **Replacement**: `pub.eda:send`
- **Migration**: Update all invocations to use pub.eda:send

---

### Changed Services

#### `pub.utils:deepClone`
- **Changes**: 
  - Prevents deserialization of unsafe Java objects
  - Performs deep clone for standard serializable Java objects
  - Uses whitelist filter for custom Java objects
- **Configuration**: Whitelist filtering enabled when `watt.server.checkWhitelist = true`
- **Migration Impact**: Review custom Java objects for whitelist requirements

#### `pub.client.ftp:login`
- **New Parameter**: `jsseDisabledProtocols` (optional)
- **Purpose**: Specify disabled SSL and TLS protocols for FTPS session
- **Behavior**: Overrides `watt.net.jsse.client.disabledProtocols`
- **Migration Impact**: None - optional parameter

#### `pub.client.ftp` (services with sessionkey parameter)
- **Changed Parameter**: `sessionkey` - Now optional (was required)
- **New Parameter**: `connectionAlias` (optional)
- **Purpose**: Specify FTP connection alias for deploy anywhere flow services in webMethods Hybrid Integration
- **Migration Impact**: sessionkey no longer required when using connectionAlias

#### `pub.client:http`
- **New Parameters**:
  - `compressionEnabled` - Enable automatic compression/decompression based on Content-Encoding header
  - `throwExceptionOnHttp401` - Control exception behavior for 401 Unauthorized responses
  - `throwExceptionOnHttp501-599` - Control exception behavior for 501-599 HTTP responses
  - `$connectionAlias` (optional) - Specify namespace of HTTP connection in webMethods Integration
- **Changed Parameter**: `url` - Now conditional (required for on-premises, optional with $connectionAlias)
- **Purpose**: Enable flow services to reuse preconfigured HTTP connections across Edge runtimes and cloud environments
- **Migration Impact**: None - optional parameters for enhanced functionality

#### `pub.file` (all services in folder)
- **Changes**: Now use server configuration parameters instead of fileAccessControl.cnf file
- **Parameter Mapping**:
  - `watt.server.file.canReadPaths` replaces `allowedReadPaths`
  - `watt.server.file.canWritePaths` replaces `allowedWritePaths`
  - `watt.server.file.canDeletePaths` replaces `allowedDeletePaths`
- **Deprecated**: fileAccessControl.cnf file
- **Migration Impact**: Update server configuration parameters; fileAccessControl.cnf no longer used

#### `pub.cache` (all services in folder)
- **Changes**: Can now use JSR 107 (Java Specification Request 107) cache
- **Limitations**: Only cache operations supported by JSR 107 are available
- **Migration Impact**: Review service parameters for JSR 107 cache compatibility

#### `pub.flow:restorePipelineFromFile`
- **Changes**: Now uses `watt.server.file.canReadPaths` instead of `allowedReadPaths` from fileAccessControl.cnf
- **Deprecated**: fileAccessControl.cnf file
- **Migration Impact**: Update server configuration parameters

#### `pub.flow:savePipelineToFile`
- **Changes**: Now uses `watt.server.file.canWritePaths` instead of `allowedWritePaths` from fileAccessControl.cnf
- **Deprecated**: fileAccessControl.cnf file
- **Migration Impact**: Update server configuration parameters

#### `pub.json:documentToJSON`
- **New Parameter**: `documentTypeName` - Supports all document types
- **Deprecated Parameter**: `jsonDocumentTypeName`
- **Migration**: Replace jsonDocumentTypeName with documentTypeName

#### `pub.json.schema:validate`
- **New Parameter**: `schemaPath` (optional)
- **Purpose**: Specify absolute/relative path or URL to JSON schema file
- **Migration Impact**: None - optional parameter

#### `pub.string:length`
- **New Parameter**: `encoding` (optional)
- **Purpose**: Specify IANA character set for determining string length
- **Migration Impact**: None - optional parameter

#### `pub.string:lookupTable`
- **New Parameter**: `regexTimeout` (optional)
- **Purpose**: Specify maximum execution time in milliseconds for regex matching
- **Migration Impact**: None - optional parameter for performance control

#### `pub.string:trim`
- **New Parameter**: `type` (optional)
- **Purpose**: Indicate whether to trim leading, trailing, or both white spaces
- **Migration Impact**: None - optional parameter

#### `pub.xslt.Transformations:transformSerialXML`
- **Changes**: Now uses `watt.server.file.canWritePaths` instead of `allowedWritePaths` from fileAccessControl.cnf
- **Deprecated**: fileAccessControl.cnf file
- **Migration Impact**: Update server configuration parameters

#### SFTP Client Services (most services in pub.client.sftp folder)
- **New Parameter**: `$connectionAlias` (optional)
- **Purpose**: Specify namespace of SFTP connection in webMethods Integration
- **Changed Parameter**: `sessionKey` - Now conditional (required for on-premises, optional with $connectionAlias)
- **Purpose**: Enable flow services to reuse preconfigured SFTP connections across Edge runtimes and cloud environments
- **Exceptions**: Changes do NOT apply to:
  - `pub.client.sftp:login`
  - `pub.client.sftp.admin:getDefaultAlgorithms`
  - `pub.client.sftp.admin:getHostKey`
  - `pub.client.sftp:logout`
- **Migration Impact**: None - optional parameter for cloud/hybrid deployments

#### `pub.client:smtp`
- **New Parameter**: `$connectionAlias` (optional)
- **Purpose**: Specify namespace of SMTP connection in webMethods Integration
- **Changed Parameter**: `mailhost` - Now conditional (required for on-premises, optional for cloud/edge)
- **Purpose**: Enable flow services to reuse preconfigured SMTP connections across edge runtimes and cloud environments
- **Migration Impact**: None - optional parameter for cloud/hybrid deployments

#### `pub.streamProcessing:combineCalculations`
- **Changes**: Moved from WmStreaming package to WmPublic package
- **Deprecated**: Copy in WmStreaming package (hidden, do not use)
- **Migration**: Update service references to use WmPublic package version
- **Action**: Use WmPublic package version for all new development

---

## Migration Checklist (Updated for v12.1)

### Pre-Upgrade Assessment
- [ ] Identify all deprecated services in use
- [ ] Identify all removed services in use
- [ ] Review changed services for parameter type changes
- [ ] Plan migration for deprecated services
- [ ] Plan re-architecture for removed services
- [ ] Review fileAccessControl.cnf usage (now deprecated)

### Version 10.15 Migration
- [ ] Remove references to `pub.metadata.assets:publishPackages`
- [ ] Remove useJSSE parameters from client services (automatically ignored)
- [ ] Update security service parameter types (Byte Array → Object List, String → String List)
- [ ] Update pub.xml:queryXMLNode to avoid String Table resultType

### Version 11.1 Migration
- [ ] Remove all pub.event.eda:* service references
- [ ] Remove all pub.event.routing:* service references
- [ ] Replace pub.flow:setResponse* with pub.flow:setHTTPResponse
- [ ] Replace pub.client.oauth:executeRequest with pub.client:http
- [ ] Replace pub.json:documentToJSONString with pub.json:documentToJSON
- [ ] Review and leverage new security parameters for JCE encryption
- [ ] Review and leverage new HTTP security parameters

### Version 12.1 Migration
- [ ] Remove pub.client.oauth:executeRequest (now removed, not just deprecated)
- [ ] Migrate all Db folder services to JDBC Adapter services
- [ ] Remove pub.websocket:getCookies references
- [ ] Replace pub.streaming:send with pub.eda:send
- [ ] Update fileAccessControl.cnf to server configuration parameters:
  - [ ] Migrate allowedReadPaths to watt.server.file.canReadPaths
  - [ ] Migrate allowedWritePaths to watt.server.file.canWritePaths
  - [ ] Migrate allowedDeletePaths to watt.server.file.canDeletePaths
- [ ] Replace jsonDocumentTypeName with documentTypeName in pub.json:documentToJSON
- [ ] Update pub.streamProcessing:combineCalculations references to WmPublic package
- [ ] Review custom Java objects for pub.utils:deepClone whitelist requirements
- [ ] Review pub.cache services for JSR 107 compatibility
- [ ] Consider using $connectionAlias for cloud/hybrid deployments:
  - [ ] HTTP connections (pub.client:http)
  - [ ] SFTP connections (pub.client.sftp services)
  - [ ] SMTP connections (pub.client:smtp)
  - [ ] FTP connections (pub.client.ftp services)
- [ ] **New Flow Constructs**: Be aware that flows using v12.1 constructs cannot be deployed to earlier versions:
  - [ ] IF, ELSEIF, ELSE (conditional execution)
  - [ ] DO, UNTIL (post-test loops)
  - [ ] WHILE (pre-test loops)
  - [ ] BREAK, CONTINUE (loop control)
  - [ ] SWITCH, CASE (multi-way branching)

### Testing
- [ ] Test all migrated services
- [ ] Verify security service parameter changes
- [ ] Validate HTTP client security enhancements
- [ ] Test re-architected solutions for removed services
- [ ] Verify file access control with new server parameters
- [ ] Test connection alias functionality for cloud/hybrid deployments
- [ ] Validate JSR 107 cache operations
- [ ] Test deepClone whitelist filtering

---

**Last Updated**: 2026-06-16  
**Source**: webMethods Integration Server Release Notes v10.15, v11.1, and v12.1