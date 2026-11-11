parser grammar ServiceProperties;

options {
    tokenVocab=AssetLexer;
}

// Pull in metadata from Common and variable structures from Document
import CommonProperties, Document;

/**
 * ENTRY POINT: servicePropertiesBlock
 * Used for service metadata and execution settings.
 */
propertyBlock
    : PROPERTIES LBRACE servicePropertyEntry* RBRACE
    ;

servicePropertiesBlock
    : propertyBlock
    ;

servicePropertyEntry
    : generalProperty          // From Common: comment, tags
    | permissionsBlock         // From Common: ACLs
    | nameProperty             // From Common: namespace, localName
    | runtimeProperty          // Execution: stateless, cache
    | retryProperty            // Error Handling: maxRetry, interval
    | auditProperty            // Logging: enableAudit, logOn
    | circuitBreakerProperty   // Stability: thresholds, reset
    | templateProperty         // Output: html/xml
    | concurrencyProperty      // Scaling: maxConcurrent
    | signatureRelatedProperty // Validation: doc refs, log lists
    | unknownProperty          // Catch-all
    ;

propertyEntry
    : servicePropertyEntry
    ;

// --- Runtime & Execution ---
runtimeProperty
    : STATELESS          COLON BOOLEAN_LITERAL SEMI
    | CACHE_RESULTS      COLON BOOLEAN_LITERAL SEMI
    | CACHE_EXPIRE       COLON INT SEMI
    | PREFETCH           COLON BOOLEAN_LITERAL SEMI
    | PREFETCH_ACT       COLON INT SEMI
    | EXEC_LOCALE        COLON STRING_LITERAL SEMI
    | URL_ALIAS          COLON STRING_LITERAL SEMI
    | PIPELINE_DEBUG     COLON (DEBUG_NONE | DEBUG_SAVE | DEBUG_REST_OVR | DEBUG_REST_MRG) SEMI
    | DEFAULT_XML_FORMAT COLON (XML_BYTES | XML_ENHANCED | XML_NODE | XML_STREAM) SEMI
    | ALLOWED_HTTP       COLON LBRACK (httpMethod (COMMA httpMethod)* | ~RBRACK*) RBRACK SEMI
    ;

httpMethod
    : HTTP_GET | HTTP_POST | HTTP_HEAD | HTTP_PUT 
    | HTTP_DELETE | HTTP_PATCH | HTTP_OPTIONS | HTTP_TRACE
    ;

// --- Transient Error Handling ---
retryProperty
    : MAX_RETRY_ATTEMPTS COLON INT SEMI
    | RETRY_INTERVAL     COLON INT SEMI
    ;

// --- Audit & Logging ---
auditProperty
    : ENABLE_AUDIT COLON (AUDIT_NEVER | EXEC_TOP_ONLY | EXEC_ALWAYS ) SEMI
    | LOG_ON       COLON (LOG_ERR | LOG_ERR_SUC | LOG_ERR_SUC_ST ) SEMI
    | INC_PIPELINE COLON (AUDIT_NEVER | INC_PIPE_ERRS | EXEC_ALWAYS ) SEMI
    ;

// --- Circuit Breaker Settings ---
circuitBreakerProperty
    : CB_ENABLED     COLON BOOLEAN_LITERAL SEMI
    | CB_FAILURE_EVT COLON (EVT_EXC | EVT_TMO | EVT_BOTH) SEMI
    | CB_TIMEOUT     COLON INT SEMI
    | CB_CANCEL_THRD COLON BOOLEAN_LITERAL SEMI
    | CB_THRESHOLD   COLON INT SEMI
    | CB_FAILURE_PER COLON INT SEMI
    | CB_OPEN_ACTION COLON (ACT_THROW | ACT_INVOKE) SEMI
    | CB_OPEN_SVC    COLON STRING_LITERAL SEMI
    | CB_RESET_PER   COLON INT SEMI
    ;

// --- Output Templates & Concurrency ---
templateProperty
    : TEMPLATE_NAME COLON STRING_LITERAL SEMI
    | TEMPLATE_TYPE COLON (HTML | XML) SEMI
    | TEMPLATE_SRC  COLON (STRING_LITERAL | TEXT_BLOCK) SEMI
    ;

concurrencyProperty
    : CONCURRENCY_ENABLED COLON BOOLEAN_LITERAL SEMI
    | MAX_CONCURRENT      COLON INT SEMI
    ;

// --- Signature Metadata ---
signatureRelatedProperty
    : SPEC_REF        COLON STRING_LITERAL SEMI
    | SIG_IN_DOC      COLON STRING_LITERAL SEMI
    | SIG_OUT_DOC     COLON STRING_LITERAL SEMI
    | VALIDATE_INPUT  COLON BOOLEAN_LITERAL SEMI
    | VALIDATE_OUTPUT COLON BOOLEAN_LITERAL SEMI
    | LOGGED_INPUT    COLON LBRACK (STRING_LITERAL (COMMA STRING_LITERAL)*)? RBRACK SEMI
    | LOGGED_OUTPUT   COLON LBRACK (STRING_LITERAL (COMMA STRING_LITERAL)*)? RBRACK SEMI
    ;

// --- The Functional Signature (Consolidated from Commons) ---
signature
    : LPAR signatureBlock* RPAR
    ;

signatureBlock
    : (INPUT | OUTPUT) LBRACE 
        propertyBlock?
        parameterDeclaration* RBRACE SEMI?
    ;

rootPropertyBlock 
    : propertyBlock EOF 
    ;
