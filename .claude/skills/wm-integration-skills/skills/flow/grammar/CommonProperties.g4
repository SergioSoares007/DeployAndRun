parser grammar CommonProperties;

options {
    tokenVocab=AssetLexer;
}

unknownProperty
    : key=anyIdentifier COLON propVal=literal SEMI 
    ;

// --- General Metadata ---
generalProperty
    : COMMENT      COLON (STRING_LITERAL | MULTILINE_STRING) SEMI
    | DISPLAY_NAME COLON STRING_LITERAL SEMI
    | TAGS         COLON LBRACK (STRING_LITERAL (COMMA STRING_LITERAL)*)? RBRACK SEMI
    | SINCE        COLON STRING_LITERAL SEMI
    | FAVORITE     COLON BOOLEAN_LITERAL SEMI
    | DEPRECATED   COLON BOOLEAN_LITERAL SEMI
    | VISIBLE      COLON enumVisibleValue SEMI
    | REUSE        COLON enumVisibleValue SEMI
    | SOURCE_URI   COLON STRING_LITERAL SEMI
    ;

enumVisibleValue
    : PUBLIC
    | PRIVATE
    ;

// --- Universal Name Properties ---
nameProperty
    : NAMESPACE_NAME COLON STRING_LITERAL SEMI
    | LOCAL_NAME     COLON STRING_LITERAL SEMI
    ;

// --- Permissions & ACLs ---
permissionsBlock
    : PERMISSIONS LBRACE aclEntry* RBRACE
    ;

aclEntry
    : LIST_ACL         COLON aclValue SEMI
    | READ_ACL         COLON aclValue SEMI
    | WRITE_ACL        COLON aclValue SEMI
    | EXECUTE_ACL      COLON aclValue SEMI
    | ENFORCE_EXEC_ACL COLON (EXEC_TOP_ONLY | EXEC_ALWAYS) SEMI
    ;

aclValue
    : ACL_ADMINS | ACL_ANON | ACL_DEFAULT | ACL_DEVS | ACL_INTERNAL 
    | ACL_MON_ADMIN | ACL_MON_USER | ACL_READ_ADMIN | ACL_REPLICATOR | ACL_INHERIT
    ;

// --- Field-Level Properties (Shared by Signatures and Documents) ---
fieldProperty
    : REQUIRED          COLON BOOLEAN_LITERAL SEMI
    | NILLABLE          COLON BOOLEAN_LITERAL SEMI
    | ALLOW_UNDEF       COLON BOOLEAN_LITERAL SEMI
    | XML_NS            COLON STRING_LITERAL SEMI
    | SUB_GROUP         COLON STRING_LITERAL SEMI
    | JAVA_WRAPPER_TYPE COLON javaWrapper SEMI
    | contentTypeProperty
    | stringDisplayProperty
    | picklistProperty
    | documentRefProperty
    ;

javaWrapper
    : JAVA_BOOLEAN | JAVA_BYTE | JAVA_CHAR | JAVA_DOUBLE 
    | JAVA_FLOAT | JAVA_INT | JAVA_LONG | JAVA_SHORT
    | STRING_TYPE
    ;

contentTypeProperty
    : CONTENT_TYPE COLON (STRING_LITERAL | anyIdentifier) SEMI
    ;

stringDisplayProperty
    : STR_DISP_TYPE COLON (DISP_TEXT | DISP_PASS | DISP_LARGE | DISP_PICK) SEMI
    | ALLOW_OTHER   COLON BOOLEAN_LITERAL SEMI
    ;

picklistProperty
    : URI_LIST      COLON STRING_LITERAL SEMI
    | PICKLIST_VALS COLON LBRACK (STRING_LITERAL (COMMA STRING_LITERAL)*)? RBRACK SEMI
    ;

documentRefProperty
    : DOC_DATA_TYPE COLON (DATA_IDATA | anyIdentifier) SEMI
    | DOC_REF       COLON STRING_LITERAL SEMI
    ;

// --- Shared Naming & Hierarchy Rules ---
interfaceDeclaration 
    : INTERFACE interfaceName SEMI?
    ;

namespaceName
    : interfaceName COLON assetName
    ;

interfaceName
    : interfaceSegment (DOT interfaceSegment)*
    ;

// Allows reserved keywords in interface/service names (e.g., "pub.string:length")
// Keywords remain reserved in other contexts (expressions, statements, etc.)
//
// MAINTENANCE NOTE: When adding new keywords to AssetLexer.g4, add them to anyKeywordAsIdentifier
// to ensure they can be used in service names without causing parse errors.
interfaceSegment
    : ID
    | BACKTICK_IDENTIFIER
    | anyKeywordAsIdentifier
    ;

// Accept any keyword token as an identifier in service/interface names
// This allows services like pub.string:length, pub.math:pattern, etc.
//
// IMPORTANT: This list should include ALL keyword tokens from AssetLexer.g4 that could
// reasonably appear in service names. When new keywords are added to the lexer, add them here.
anyKeywordAsIdentifier
    : keywordReclamation
    // --- Flow control & step properties ---
    | CONDITION | MAP_SOURCE | MAP_TARGET | IN_PACKAGE | OUT_PACKAGE
    | COPY_MODE | IN_ARRAY | OUT_ARRAY | CARDINALITY | MAX_ITERATION
    | COUNT | TIMEOUT | REPEAT_INTERVAL | REPEAT_COUNT | REPEAT_ON
    | SCOPE | LABEL | DISABLED | MODE | INPUT_ARRAY | OUTPUT_ARRAY
    | MAX_THREADS | PARALLEL_ERROR_HANDLING
    | EXIT_ON | FAILURES | SELECTION | SWITCH_PROP | EVAL_LABELS
    | SIGNAL | FAILURE_NAME | FAILURE_INSTANCE | EXIT_FROM | FAILURE_MESSAGE
    | TO | AS | MAPFOREACH | MERGE | APPEND
    // --- XML Schema facets (common in pub.string, pub.math services) ---
    | FACET_LENGTH | FACET_MIN_LEN | FACET_MAX_LEN | FACET_PATTERN
    | FACET_MIN_INC | FACET_MIN_EXC | FACET_MAX_INC | FACET_MAX_EXC
    | FACET_TOTAL_DIG | FACET_FRAC_DIG | FACET_WHITESPACE | FACET_ENUM
    // --- W3C type keywords ---
    | W3C_DURATION | W3C_TIME | W3C_HEX_BINARY | W3C_BASE64 | W3C_ANY_URI
    | W3C_NORM_STR | W3C_GYEAR | W3C_GMONTH | W3C_GDAY | W3C_GYEARMONTH | W3C_GMONTHDAY
    // --- HTTP methods ---
    | HTTP_GET | HTTP_POST | HTTP_HEAD | HTTP_PUT | HTTP_DELETE | HTTP_PATCH | HTTP_OPTIONS | HTTP_TRACE
    // --- Service & document properties ---
    | MODEL_TYPE | DOC_DATA_TYPE | ROLE | LINKED_SOURCE | SCHEMA_DOMAIN | REGISTERED | SCHEMA_TYPE_NAME
    | MODEL_HIER | MODEL_FLAT | MODEL_UNORD | ROLE_FRAG
    | MESSAGING | PUBLISHABLE | CONN_ALIAS | CONN_TYPE | PROV_DEF | ENCODING | DISCARD | TTL | STORAGE_TYPE | VALIDATE_PUB
    | STORAGE_GUAR | STORAGE_VOL | ENC_PROTO | ENC_IDATA
    | LIST_ACL | READ_ACL | WRITE_ACL | EXECUTE_ACL | ENFORCE_EXEC_ACL
    | DEBUG_NONE | DEBUG_SAVE | DEBUG_REST_OVR | DEBUG_REST_MRG
    | XML_BYTES | XML_ENHANCED | XML_NODE | XML_STREAM | HTML | XML
    | DATA_IDATA | VALIDATION_NONE
    | DISP_TEXT | DISP_PASS | DISP_LARGE | DISP_PICK
    // --- Java wrapper types ---
    | JAVA_BOOLEAN | JAVA_BYTE | JAVA_CHAR | JAVA_DOUBLE | JAVA_FLOAT | JAVA_INT | JAVA_LONG | JAVA_SHORT
    ;

// Allows reserved keywords in service/asset names (e.g., "some.interface:condition")
assetName : interfaceSegment ;

// --- Master Variable Rules ---
variableRef
    : (namespaceName | anyIdentifier | dottedFieldName | SPECIAL_VAR) 
      (LBRACK indexRef RBRACK)?
      (DIV pathSegment)*
    ;

pathSegment
    : anyIdentifier (LBRACK indexRef RBRACK)?
    ;

indexRef
    : INT
    | expression
    | SPECIAL_VAR        
    | SUBSTITUTION_VAR   
    ;

// --- Literals & Identifiers ---
literal
    : STRING_LITERAL | INT | FLOAT_LITERAL | BOOLEAN_LITERAL | NULL_LITERAL 
    ;

anyIdentifier
    : (ID | keywordReclamation) (MINUS (ID | keywordReclamation))*
    | BACKTICK_IDENTIFIER
    ;

keywordReclamation
    : // --- Structure & Assets ---
      SERVICE | INTERFACE | INPUT | OUTPUT | PROPERTIES | RECORD_TYPE | RECORD_LIST
    | DOCUMENT_TYPE | DOCUMENT_DATA

    // --- Flow Controls ---
    | MAP | INVOKE | BRANCH | REPEAT | SEQUENCE | LOOP | TRY | CATCH | FINALLY
    | EXIT | IF | ELSE | ELSEIF | SWITCH | CASE | WHILE | DO | UNTIL
    | CONTINUE | BREAK | TRANSFORM | INVOKE_ORDER
    
    // --- Flow Control & Step Properties (used as field/variable names) ---
    | CONDITION | MAP_SOURCE | MAP_TARGET | IN_PACKAGE | OUT_PACKAGE
    | COPY_MODE | IN_ARRAY | OUT_ARRAY | CARDINALITY | MAX_ITERATION
    | COUNT | TIMEOUT | REPEAT_INTERVAL | REPEAT_COUNT | REPEAT_ON
    | SCOPE | LABEL | DISABLED | MODE | INPUT_ARRAY | OUTPUT_ARRAY
    | MAX_THREADS | PARALLEL_ERROR_HANDLING
    | EXIT_ON | FAILURES | SELECTION | SWITCH_PROP | EVAL_LABELS
    | SIGNAL | FAILURE_NAME | FAILURE_INSTANCE | EXIT_FROM | FAILURE_MESSAGE
    | TO | AS | MAPFOREACH | MERGE | APPEND

    // --- Mapping Actions ---
    | COPY | COPY_IF | COPY_IF_DISABLED | SET | DROP | OVERWRITE | VARIABLE | GLOBAL_VARIABLES

    // --- Common Metadata Keys ---
    | COMMENT | DISPLAY_NAME | TAGS | SINCE | FAVORITE | DEPRECATED | VISIBLE | REUSE
    | SOURCE_URI | NAMESPACE_NAME | LOCAL_NAME | PERMISSIONS
    | PUBLIC | PRIVATE

    // --- Service Property Keys ---
    | STATELESS | CACHE_RESULTS | CACHE_EXPIRE | PREFETCH | PREFETCH_ACT
    | EXEC_LOCALE | URL_ALIAS | PIPELINE_DEBUG | DEFAULT_XML_FORMAT | ALLOWED_HTTP
    | MAX_RETRY_ATTEMPTS | RETRY_INTERVAL | ENABLE_AUDIT | LOG_ON | INC_PIPELINE
    | CB_ENABLED | CB_FAILURE_EVT | CB_TIMEOUT | CB_CANCEL_THRD | CB_THRESHOLD
    | CB_FAILURE_PER | CB_OPEN_ACTION | CB_OPEN_SVC | CB_RESET_PER
    | TEMPLATE_NAME | TEMPLATE_TYPE | TEMPLATE_SRC
    | CONCURRENCY_ENABLED | MAX_CONCURRENT
    | SPEC_REF | SIG_IN_DOC | SIG_OUT_DOC | VALIDATE_INPUT | VALIDATE_OUTPUT
    | LOGGED_INPUT | LOGGED_OUTPUT

    // --- ACL & Enum Values ---
    | ACL_ADMINS | ACL_ANON | ACL_DEFAULT | ACL_DEVS | ACL_INTERNAL 
    | ACL_MON_ADMIN | ACL_MON_USER | ACL_READ_ADMIN | ACL_REPLICATOR | ACL_INHERIT
    | DEBUG_NONE | DEBUG_SAVE | DEBUG_REST_OVR | DEBUG_REST_MRG
    | XML_BYTES | XML_ENHANCED | XML_NODE | XML_STREAM
    | AUDIT_NEVER | EXEC_TOP_ONLY | EXEC_ALWAYS
    | LOG_ERR | LOG_ERR_SUC | LOG_ERR_SUC_ST
    | INC_PIPE_ERRS | EVT_EXC | EVT_TMO | EVT_BOTH | ACT_THROW | ACT_INVOKE

    // --- Field Constraints ---
    | REQUIRED | NILLABLE | ALLOW_UNDEF | XML_NS | SUB_GROUP | JAVA_WRAPPER_TYPE
    | CONTENT_TYPE | STR_DISP_TYPE | ALLOW_OTHER | URI_LIST | PICKLIST_VALS
    | DOC_DATA_TYPE | DOC_REF | OPTIONAL | DEFAULT | EQUALS

    // --- Data Types ---
    | STRING_TYPE | OBJECT_TYPE | INTEGER_TYPE | FLOAT_TYPE | DOUBLE_TYPE
    | BOOLEAN_TYPE | DATETIME_TYPE | BYTE_TYPE | CHAR_TYPE
    | LONG_TYPE | SHORT_TYPE | BIGINTEGER_TYPE | BIGDECIMAL_TYPE | XOPOBJECT_TYPE
    | BYTE_PRIMITIVE | CHAR_PRIMITIVE | INT_PRIMITIVE | LONG_PRIMITIVE
    | SHORT_PRIMITIVE | BOOLEAN_PRIMITIVE | FLOAT_TYPE_PRIMITIVE | DOUBLE_TYPE_PRIMITIVE
    | OBJECT_PRIMITIVE | W3C_DECIMAL | W3C_INTEGER | W3C_STRING | W3C_TIME
    
    // --- Boolean Literals (reclaimed as identifiers) ---
    | BOOLEAN_LITERAL  // Allows 'true' and 'false' to be used as field/variable names
    ;

arrayLiteral : LBRACK (jsonValue (COMMA jsonValue)*)? RBRACK ; 
jsonObject   : LBRACE (jsonPair (COMMA jsonPair)*)? RBRACE ;

jsonPair     : (STRING_LITERAL | anyIdentifier) COLON jsonValue ;

jsonValue    : STRING_LITERAL 
             | INT 
             | FLOAT_LITERAL 
             | BOOLEAN_LITERAL 
             | NULL_LITERAL 
             | arrayLiteral
             | jsonObject
             ;

value
    : arrayLiteral
    | jsonObject
    | expression
    ;

expression : primaryExpression (binaryOperator primaryExpression)* ;

primaryExpression
    : variableRef                      # PrimaryVariable
    | SUBSTITUTION_VAR                 # PrimarySubVar
    | literal                          # PrimaryLiteral
    | LPAR expression RPAR             # PrimaryParen
    | unaryOperator primaryExpression  # PrimaryUnary
    ;

binaryOperator : PLUS | MINUS | MULT | DIV | PCT | EQ | NEQ | LT | GT | LTE | GTE | AND | OR ;
unaryOperator  : NOT | MINUS ;
