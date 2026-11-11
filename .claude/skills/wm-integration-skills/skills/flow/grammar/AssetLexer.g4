lexer grammar AssetLexer;

// --- 1. DATA TYPES & JAVA WRAPPERS ---
STRING_TYPE         : 'String' ; 
OBJECT_TYPE         : 'Object' ;
INTEGER_TYPE        : 'Integer' ;
FLOAT_TYPE          : 'Float' ;
DOUBLE_TYPE         : 'Double' ; 
BOOLEAN_TYPE        : 'Boolean' ;
DATETIME_TYPE       : 'DateTime' ;
DOCUMENT_TYPE       : 'document' ;
RECORD_TYPE         : 'record' ;
RECORD_LIST         : 'recordList' ;
BYTE_TYPE           : 'Byte' ;
CHAR_TYPE           : 'Char' ;
LONG_TYPE           : 'Long' ;
SHORT_TYPE          : 'Short' ;
BIGINTEGER_TYPE     : 'BigInteger' ;
BIGDECIMAL_TYPE     : 'BigDecimal' ;
XOPOBJECT_TYPE      : 'XOPObject' ;

// Primitives
BYTE_PRIMITIVE        : 'byte' ;
CHAR_PRIMITIVE        : 'char' ;
INT_PRIMITIVE         : 'int' ;
LONG_PRIMITIVE        : 'long' ;
SHORT_PRIMITIVE       : 'short' ;
BOOLEAN_PRIMITIVE     : 'boolean' ;
FLOAT_TYPE_PRIMITIVE  : 'float' ;
DOUBLE_TYPE_PRIMITIVE : 'double' ; 
OBJECT_PRIMITIVE      : 'object' ;

// --- 2. UNIVERSAL COMMON PROPERTIES (Top-Level) ---
PROPERTIES      : 'properties' ;
COMMENT         : 'comment' ;
DISPLAY_NAME    : 'displayName' ;
TAGS            : 'tags' ;
SINCE           : 'since' ;
FAVORITE        : 'favorite' ;
DEPRECATED      : 'deprecated' ;
VISIBLE         : 'visible' ;
REUSE           : 'reuse' ;
SOURCE_URI      : 'sourceUri' ;
NAMESPACE_NAME  : 'namespaceName' ;
LOCAL_NAME      : 'localName' ;

// Visibility/Reuse Options
PUBLIC          : 'public' ;
PRIVATE         : 'private' ;

// --- 3. PERMISSIONS & ACLs ---
PERMISSIONS     : 'permissions' ;
LIST_ACL        : 'listACL' ;
READ_ACL        : 'readACL' ;
WRITE_ACL       : 'writeACL' ;
EXECUTE_ACL     : 'executeACL' ;
ENFORCE_EXEC_ACL: 'enforceExecuteACL' ;

// ACL Values
ACL_INHERIT     : 'Inherited' ;
ACL_ADMINS      : 'Administrators' ;
ACL_ANON        : 'Anonymous' ;
ACL_DEFAULT     : 'Default' ;
ACL_DEVS        : 'Developers' ;
ACL_INTERNAL    : 'Internal' ;
ACL_MON_ADMIN   : 'MonitorAdministrators' ;
ACL_MON_USER    : 'MonitorUsers' ;
ACL_READ_ADMIN  : 'ReadOnlyAdministrators' ;
ACL_REPLICATOR  : 'Replicators' ;

// Enforce Execute Options
EXEC_TOP_ONLY   : 'When top-level service only' ;
EXEC_ALWAYS     : 'always' ;

// --- 4. DOCUMENT-TYPE-SPECIFIC PROPERTIES ---
MODEL_TYPE      : 'modelType' ;
DOC_DATA_TYPE   : 'documentDataType' ;
ROLE            : 'role' ;
LINKED_SOURCE   : 'linkedToSource' ;
SCHEMA_DOMAIN   : 'schemaDomain' ;
REGISTERED      : 'registered' ;
SCHEMA_TYPE_NAME: 'schemaTypeName' ;

// Enum Options for Docs
MODEL_HIER      : 'hierarchical' ;
MODEL_FLAT      : 'flat' ;
MODEL_UNORD     : 'unordered' ;
ROLE_FRAG       : 'fragment' ;

// Messaging
MESSAGING       : 'messaging' ;
PUBLISHABLE     : 'publishable' ;
CONN_ALIAS      : 'connectionAliasName' ;
CONN_TYPE       : 'connectionAliasType' ;
PROV_DEF        : 'providerDefinition' ;
ENCODING        : 'encodingType' ;
DISCARD         : 'discard' ;
TTL             : 'timeToLive' ;
STORAGE_TYPE    : 'storageType' ;
VALIDATE_PUB    : 'validateWhenPublished' ;

// Messaging Options
STORAGE_GUAR    : 'Guaranteed' ;
STORAGE_VOL     : 'Volatile' ;
ENC_PROTO       : 'Protocol buffers' ;
ENC_IDATA       : 'IData' ;

// --- 5. SERVICE-SPECIFIC PROPERTIES ---
STATELESS          : 'stateless' ;
CACHE_RESULTS      : 'cacheResults' ;
CACHE_EXPIRE       : 'cacheExpire' ;
PREFETCH           : 'prefetch' ;
PREFETCH_ACT       : 'prefetchActivation' ;
EXEC_LOCALE        : 'executionLocale' ;
URL_ALIAS          : 'httpUrlAlias' ;
PIPELINE_DEBUG     : 'pipelineDebug' ;
DEFAULT_XML_FORMAT : 'defaultXmlFormat' ;
ALLOWED_HTTP       : 'allowedHttpMethods' ;

// Debug Options
DEBUG_NONE      : 'None' ;
DEBUG_SAVE      : 'Save' ;
DEBUG_REST_OVR  : 'Restore (Override)' ;
DEBUG_REST_MRG  : 'Restore (Merge)' ;

// XML Format Options
XML_BYTES       : 'bytes' ;
XML_ENHANCED    : 'enhanced' ;
XML_NODE        : 'node' ;
XML_STREAM      : 'stream' ;

// HTTP Method Options
HTTP_GET        : 'GET';
HTTP_POST       : 'POST';
HTTP_HEAD       : 'HEAD';
HTTP_PUT        : 'PUT';
HTTP_DELETE     : 'DELETE';
HTTP_PATCH      : 'PATCH';
HTTP_OPTIONS    : 'OPTIONS';
HTTP_TRACE      : 'TRACE';

// Error & Audit
MAX_RETRY_ATTEMPTS : 'maxRetryAttempts' ;
RETRY_INTERVAL     : 'retryInterval' ;
ENABLE_AUDIT       : 'enableAuditing' ;
LOG_ON             : 'logOn' ;
INC_PIPELINE       : 'includePipeline' ;

// Audit Options
AUDIT_NEVER     : 'never' ;
// Note: EXEC_TOP_ONLY and EXEC_ALWAYS reused from Permissions
LOG_ERR         : 'Error only' ;
LOG_ERR_SUC     : 'Error and success' ;
LOG_ERR_SUC_ST  : 'Error, success and start' ;
INC_PIPE_ERRS   : 'On errors only' ;

// Circuit Breaker
CB_ENABLED      : 'circuitBreakerEnabled' ;
CB_FAILURE_EVT  : 'failureEvent' ;
CB_TIMEOUT      : 'timeoutPeriod' ;
CB_CANCEL_THRD  : 'cancelThreadOnTimeout' ;
CB_THRESHOLD    : 'failureThreshold' ;
CB_FAILURE_PER  : 'failurePeriod' ;
CB_OPEN_ACTION  : 'circuitOpenAction' ;
CB_OPEN_SVC     : 'circuitOpenService' ;
CB_RESET_PER    : 'circuitResetPeriod' ;

// Circuit Breaker Options
EVT_EXC         : 'Exception only' ;
EVT_TMO         : 'Timeout only' ;
EVT_BOTH        : 'Exception or timeout' ;
ACT_THROW       : 'Throw exception' ;
ACT_INVOKE      : 'Invoke service' ;

// Templates & Concurrency
TEMPLATE_NAME       : 'templateName' ;
TEMPLATE_TYPE       : 'templateType' ;
TEMPLATE_SRC        : 'templateSource' ;
HTML                : 'html' ;
XML                 : 'xml' ;
CONCURRENCY_ENABLED : 'concurrencyEnabled' ;
MAX_CONCURRENT      : 'maxConcurrentRequests' ;

// Signature
INPUT           : 'input' ;
OUTPUT          : 'output' ;
SPEC_REF        : 'specificationReference' ;
SIG_IN_DOC      : 'signatureInputDocumentType' ;
SIG_OUT_DOC     : 'signatureOutputDocumentType' ;
VALIDATE_INPUT  : 'validateInput' ;
VALIDATE_OUTPUT : 'validateOutput' ;
LOGGED_INPUT    : 'inputLoggedFields' ;
LOGGED_OUTPUT   : 'outputLoggedFields' ;

// --- 6. FIELD-LEVEL PROPERTIES ---
REQUIRED        : 'required' ;
OPTIONAL        : 'optional' ;
DEFAULT         : 'default' ;
NILLABLE        : 'nillable' ;
ALLOW_NULL      : 'allowNull' ;
ALLOW_UNSPECIFIED_FIELDS : 'allowUnspecifiedFields' ;
ALLOW_UNDEF     : 'allowUndefined' ;
SUB_GROUP       : 'substitutionGroup' ;
XML_NS          : 'xmlNamespace' ;
STR_DISP_TYPE   : 'stringDisplayType' ;
PICKLIST        : 'picklist' ;
PICKLIST_VALS   : 'pickListChoices' ;
ALLOW_OTHER     : 'allowOtherValues' ;
URI_LIST        : 'anyUriList' ;
DOC_REF         : 'documentReference' ;
CONTENT_TYPE    : 'contentType' ;

// Display Options
DISP_TEXT       : 'Text field' ;
DISP_PASS       : 'Password' ;
DISP_LARGE      : 'Large editor' ;
DISP_PICK       : 'Picklist' ;

// W3C Types
W3C_STRING      : 'string' ;
W3C_DECIMAL     : 'decimal' ;
W3C_DURATION    : 'duration' ;
W3C_DATETIME    : 'dateTime' ;
W3C_TIME        : 'time' ;
W3C_DATE        : 'date' ;
W3C_HEX_BINARY  : 'hexBinary' ;
W3C_BASE64      : 'base64Binary' ;
W3C_ANY_URI     : 'anyURI' ;
W3C_INTEGER     : 'integer' ;
W3C_NORM_STR    : 'normalizedString' ;
W3C_GYEAR       : 'gYear' ;
W3C_GMONTH      : 'gMonth' ;
W3C_GDAY        : 'gDay' ;
W3C_GYEARMONTH  : 'gYearMonth' ;
W3C_GMONTHDAY   : 'gMonthDay' ;

// Facets
FACET_ENUM      : 'enumeration' ;
FACET_LENGTH    : 'length' ;
FACET_MIN_LEN   : 'minLength' ;
FACET_MAX_LEN   : 'maxLength' ;
FACET_PATTERN   : 'pattern' ;
FACET_MIN_INC   : 'minInclusive' ;
FACET_MIN_EXC   : 'minExclusive' ;
FACET_MAX_INC   : 'maxInclusive' ;
FACET_MAX_EXC   : 'maxExclusive' ;
FACET_TOTAL_DIG : 'totalDigits' ;
FACET_FRAC_DIG  : 'fractionDigits' ;
FACET_WHITESPACE: 'whiteSpace' ;

// Java Wrapper Types
JAVA_BOOLEAN   : 'java.lang.Boolean' ;
JAVA_BYTE      : 'java.lang.Byte' ;
JAVA_CHAR      : 'java.lang.Character' ;
JAVA_DOUBLE    : 'java.lang.Double' ;
JAVA_FLOAT     : 'java.lang.Float' ;
JAVA_INT       : 'java.lang.Integer' ;
JAVA_LONG      : 'java.lang.Long' ;
JAVA_SHORT     : 'java.lang.Short' ;

// --- 7. FLOW LOGIC KEYWORDS ---
IF               : 'IF' ;
ELSEIF           : 'ELSEIF' ;
ELSE             : 'ELSE' ;
SWITCH           : 'SWITCH' ;
CASE             : 'CASE' ;
REPEAT           : 'REPEAT' ;
DO               : 'DO' ;
UNTIL            : 'UNTIL' ;
WHILE            : 'WHILE' ;
CONTINUE         : 'CONTINUE' ;
BREAK            : 'BREAK' ;
DOCUMENT_DATA    : 'Document' ;
SERVICE          : 'service' ;
INTERFACE        : 'interface' ;
INVOKE           : 'INVOKE' ;
MAP              : 'MAP' ;
MAPFOREACH       : 'MAPFOREACH' ;
SEQUENCE         : 'SEQUENCE' ;
LOOP             : 'LOOP' ;
BRANCH           : 'BRANCH' ;
TRY              : 'TRY' ;
CATCH            : 'CATCH' ;
FINALLY          : 'FINALLY' ;
EXIT             : 'EXIT' ;
MAP_SOURCE       : 'mapSource' ;
MAP_TARGET       : 'mapTarget' ;
IN_PACKAGE       : 'in-package' ;
OUT_PACKAGE      : 'out-package' ;
COPY             : 'copy' ;
COPY_IF          : 'copy-if' ;
COPY_IF_DISABLED : 'copy-if-disabled' ;
SET              : 'set' ;
TRANSFORM        : 'TRANSFORM' ;
DROP             : 'drop' ;
COPY_MODE        : 'copyMode' ;
IN_ARRAY         : 'inArray' ;
OUT_ARRAY        : 'outArray' ;
CARDINALITY      : 'cardinality' ;
CONDITION        : 'condition' ;
MERGE            : 'MERGE' ;
APPEND           : 'APPEND' ;
MAX_ITERATION    : 'maxIteration' ;
COUNT            : 'count' ;
TIMEOUT          : 'timeout' ;
REPEAT_INTERVAL  : 'repeatInterval' ;
REPEAT_COUNT     : 'repeatCount' ;
REPEAT_ON        : 'repeatOn' ;
SCOPE            : 'scope' ;
LABEL            : 'label' ;
DISABLED         : 'disabled' ;
MODE             : 'mode' ;
INVOKE_ORDER     : 'invoke-order' ;
INPUT_ARRAY      : 'inputArray' ;
OUTPUT_ARRAY     : 'outputArray' ;
MAX_THREADS      : 'maxThreads' ;
PARALLEL_ERROR_HANDLING : 'parallelErrorHandling' ;
EXIT_ON          : 'exitOn' ;
FAILURES         : 'failures' ;
SELECTION        : 'selection' ;
SWITCH_PROP      : 'switch' ;
EVAL_LABELS      : 'evaluateLabels' ;
SIGNAL           : 'signal' ;
FAILURE_NAME     : 'failureName' ;
FAILURE_INSTANCE : 'failureInstance' ;
EXIT_FROM        : 'exitFrom' ;
FAILURE_MESSAGE  : 'failureMessage' ;
TO               : 'to' ;
AS               : 'as' ;

// --- 8. REMAINING KEYWORDS & ENUMS ---
// These are specific strings; place them above generic ID and ERROR_CHAR
JAVA_WRAPPER_TYPE : 'java_wrapper' ; 
DATA_IDATA        : 'idata' ;
VALIDATION_NONE   : 'none' ;
OVERWRITE         : 'overwrite' ;
VARIABLE          : 'variable' ;
GLOBAL_VARIABLES  : 'globalvariables' ;

// --- 9. OPERATORS & DELIMITERS ---
PLUS   : '+' ;
MINUS  : '-' ;
MULT   : '*' ;
DIV    : '/' ;
PCT    : '%' ;
EQ     : '==' ;
NEQ    : '!=' ;
LT     : '<' ;
GT     : '>' ;
LTE    : '<=' ;
GTE    : '>=' ;
AND    : '&&' | '&' | [Aa][Nn][Dd] ;
OR     : '||' | '|' | [Oo][Rr] ;
NOT    : '!'  | [Nn][Oo][Tt] ;

ARRAY_SUFFIX : '[]' ;

LBRACE : '{' ; 
RBRACE : '}' ;
LPAR   : '(' ; 
RPAR   : ')' ;
LBRACK : '[' ; 
RBRACK : ']' ;
COLON  : ':' ; 
SEMI   : ';' ;
COMMA  : ',' ; 
DOT    : '.' ;
ARROW  : '->' ; 
EQUALS : '=' ;
AT     : '@' ;
DOLLAR : '$' ;

// --- 10. LITERALS & IDENTIFIERS ---
BOOLEAN_LITERAL     : 'true' | 'false' ;
NULL_LITERAL        : 'null' ;
FLOAT_LITERAL       : [0-9]+ '.' [0-9]* | '.' [0-9]+ ;
INT                 : [0-9]+ ;

TEXT_BLOCK          : '"""' ( '\\' . | ~('\\'|'"') | '"' ~'"' | '""' ~'"' )* '"""' ;
STRING_LITERAL      : '"' (~["\\] | '\\' .)* '"' ;
MULTILINE_STRING    : '"""' ( . | '\r' | '\n' )*? '"""' ;

// Clear out the hyphen from SPECIAL_VAR so it matches standard alpha-numeric IDs
SPECIAL_VAR         : '$' [a-zA-Z_][a-zA-Z0-9_]* ;

// Matches pipeline substitution fields like %$retries% or %customerId%
SUBSTITUTION_VAR    : '%' '$'? [a-zA-Z_][a-zA-Z0-9_]* '%' ;

// Standard clean alphanumeric identifier
ID                  : [a-zA-Z_][a-zA-Z0-9_]* ;

BACKTICK_IDENTIFIER : '`' (~[`] | '\\`')* '`' ;

// --- 11. SYSTEM RULES & WHITESPACE ---
// Add these immediately below ID, and ABOVE your ERROR_CHAR catch-all

// This tells ANTLR to ignore spaces, tabs, and line breaks completely
WS : [ \t\r\n]+ -> skip ;

// This ensures comments are stripped out cleanly too
LINE_COMMENT  : '//' ~[\r\n]* -> skip ;
BLOCK_COMMENT : '/*' .*? '*/' -> skip ;

// ABSOLUTE LAST RULE IN THE FILE
ERROR_CHAR : . ;

