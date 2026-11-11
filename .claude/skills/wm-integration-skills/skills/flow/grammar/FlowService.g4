parser grammar FlowService;

options { 
    tokenVocab=AssetLexer; 
}

import CommonProperties, Document, ServiceProperties, ServiceAuditing;

flowService
    : (interfaceDeclaration SEMI?)?
      SERVICE
      (namespaceName | assetName)
      signature?
      servicePropertiesBlock?
      LBRACE
      step* RBRACE
    ;

mapSignatureBlock
    : MAP_SOURCE (LBRACK anyIdentifier RBRACK)? LBRACE parameterDeclaration* RBRACE
    | MAP_TARGET (LBRACK anyIdentifier RBRACK)? LBRACE parameterDeclaration* RBRACE
    ;

// --- Implementation Logic ---

// General step rule - used in most contexts (excludes break/continue)
step
    : transformStep
    | invokeStep
    | mapStep
    | loopStep
    | sequenceStep
    | branchStep
    | repeatStep
    | tryStep
    | exitStep
    | doUntilStep
    | ifThenStep
    | switchCaseStep
    | whileStep
    | continueStep
    | breakStep
    ;

// --- Step Definitions ---

invokeStep
    : INVOKE namespaceName (LBRACE stepProperty* invokeProperty* mappingBlock* RBRACE | SEMI)
    ;

mapStep
    : MAP LBRACE mapContent* RBRACE SEMI?
    | MAP SEMI 
    ;

mapContent
    : mapElement
    | mapProperty
    | stepProperty
    ;

mapElement
    : mappingSetEntry
    | mappingCopyEntry
    | dropStep
    | transformStep
    | mapForEachStep
    | mapSignatureBlock
    ;

mapForEachStep
    : MAPFOREACH (LBRACE mapForEachProperty* mapStep* RBRACE)? SEMI
    ;

mapForEachProperty
    : COPY_MODE COLON (MERGE | APPEND | OVERWRITE) SEMI
    | IN_ARRAY COLON STRING_LITERAL SEMI
    | OUT_ARRAY COLON STRING_LITERAL SEMI
    | CARDINALITY COLON INT SEMI
    | CONDITION COLON expression SEMI
    ;

mappingBlock
    : mapSignatureBlock
    | INPUT  LBRACE (mapElement | stepProperty)* RBRACE SEMI?
    | OUTPUT LBRACE (mapElement | stepProperty)* RBRACE SEMI?
    ;

mappingCopyEntry
    : COPY source=variableRef ARROW target=variableRef SEMI
    | COPY_IF LPAR condition=expression RPAR source=variableRef ARROW target=variableRef SEMI
    | COPY_IF_DISABLED LPAR condition=expression RPAR source=variableRef ARROW target=variableRef SEMI
    ;

mappingSetEntry
    : SET setAttributes? target=variableRef EQUALS assignedVal=value SEMI
    ;

transformStep
    : TRANSFORM transformServicePath LBRACE transformBlockContent* RBRACE
    | TRANSFORM transformServicePath SEMI
    ;

transformBlockContent
    : transformProperty
    | mappingBlock
    | mapElement
    | stepProperty
    ;

transformServicePath
    : (ID | pathKeywordReclamation) (DOT (ID | pathKeywordReclamation))* COLON (ID | pathKeywordReclamation)
    ;

pathKeywordReclamation
    : keywordReclamation
    | W3C_STRING        // Explicitly handles lowercase 'string' paths (e.g., pub.string)
    | W3C_DATETIME      // Explicitly handles lowercase 'dateTime' paths
    | W3C_DATE          // Explicitly handles lowercase 'date' paths
    | facetKeyword      // Explicitly handles facet keywords (e.g., pub.string:length)
    | flowControlKeyword // Explicitly handles flow control keywords in service paths
    | w3cTypeKeyword    // Explicitly handles W3C type keywords in service paths
    | httpMethodKeyword // Explicitly handles HTTP method keywords in service paths
    | servicePropertyKeyword // Explicitly handles service property keywords in service paths
    | javaWrapperKeyword // Explicitly handles Java wrapper type keywords in service paths
    | booleanLiteralKeyword // Explicitly handles boolean literal keywords in service paths
    ;

// Facet keywords that can appear in service paths
// These are XML Schema facets that might be used as flow service names and need to be reclaimed back so that they don't show up as reserved keywords in the parser.
facetKeyword
    : FACET_LENGTH      // 'length' - e.g., pub.string:length
    | FACET_MIN_LEN     // 'minLength'
    | FACET_MAX_LEN     // 'maxLength'
    | FACET_PATTERN     // 'pattern'
    | FACET_MIN_INC     // 'minInclusive'
    | FACET_MIN_EXC     // 'minExclusive'
    | FACET_MAX_INC     // 'maxInclusive'
    | FACET_MAX_EXC     // 'maxExclusive'
    | FACET_TOTAL_DIG   // 'totalDigits'
    | FACET_FRAC_DIG    // 'fractionDigits'
    | FACET_WHITESPACE  // 'whiteSpace'
    | FACET_ENUM        // 'enumeration'
    ;

// Flow control keywords that can appear in service paths
// These are flow control properties that might be used as service names
flowControlKeyword
    : CONDITION         // 'condition'
    | COUNT             // 'count'
    | SCOPE             // 'scope'
    | TIMEOUT           // 'timeout'
    | LABEL             // 'label'
    | MODE              // 'mode'
    | DISABLED          // 'disabled'
    ;

// Additional W3C type keywords that can appear in service paths
// Beyond the already-handled W3C_STRING, W3C_DATETIME, W3C_DATE
w3cTypeKeyword
    : W3C_DURATION      // 'duration'
    | W3C_TIME          // 'time'
    | W3C_HEX_BINARY    // 'hexBinary'
    | W3C_BASE64        // 'base64Binary'
    | W3C_ANY_URI       // 'anyURI'
    | W3C_NORM_STR      // 'normalizedString'
    | W3C_GYEAR         // 'gYear'
    | W3C_GMONTH        // 'gMonth'
    | W3C_GDAY          // 'gDay'
    | W3C_GYEARMONTH    // 'gYearMonth'
    | W3C_GMONTHDAY     // 'gMonthDay'
    | W3C_DECIMAL       // 'decimal'
    | W3C_INTEGER       // 'integer'
    ;

// HTTP method keywords that can appear in service paths
httpMethodKeyword
    : HTTP_GET          // 'GET'
    | HTTP_POST         // 'POST'
    | HTTP_HEAD         // 'HEAD'
    | HTTP_PUT          // 'PUT'
    | HTTP_DELETE       // 'DELETE'
    | HTTP_PATCH        // 'PATCH'
    | HTTP_OPTIONS      // 'OPTIONS'
    | HTTP_TRACE        // 'TRACE'
    ;

// Service and document property keywords that can appear in service paths
servicePropertyKeyword
    : MODEL_TYPE        // 'modelType'
    | DOC_DATA_TYPE     // 'documentDataType'
    | ROLE              // 'role'
    | LINKED_SOURCE     // 'linkedToSource'
    | SCHEMA_DOMAIN     // 'schemaDomain'
    | REGISTERED        // 'registered'
    | SCHEMA_TYPE_NAME  // 'schemaTypeName'
    | MODEL_HIER        // 'hierarchical'
    | MODEL_FLAT        // 'flat'
    | MODEL_UNORD       // 'unordered'
    | ROLE_FRAG         // 'fragment'
    | MESSAGING         // 'messaging'
    | PUBLISHABLE       // 'publishable'
    | CONN_ALIAS        // 'connectionAliasName'
    | CONN_TYPE         // 'connectionAliasType'
    | PROV_DEF          // 'providerDefinition'
    | ENCODING          // 'encodingType'
    | DISCARD           // 'discard'
    | TTL               // 'timeToLive'
    | STORAGE_TYPE      // 'storageType'
    | VALIDATE_PUB      // 'validateWhenPublished'
    | STORAGE_GUAR      // 'Guaranteed'
    | STORAGE_VOL       // 'Volatile'
    | ENC_PROTO         // 'Protocol buffers'
    | ENC_IDATA         // 'IData'
    | LIST_ACL          // 'listACL'
    | READ_ACL          // 'readACL'
    | WRITE_ACL         // 'writeACL'
    | EXECUTE_ACL       // 'executeACL'
    | ENFORCE_EXEC_ACL  // 'enforceExecuteACL'
    | DEBUG_NONE        // 'None'
    | DEBUG_SAVE        // 'Save'
    | DEBUG_REST_OVR    // 'Restore (Override)'
    | DEBUG_REST_MRG    // 'Restore (Merge)'
    | XML_BYTES         // 'bytes'
    | XML_ENHANCED      // 'enhanced'
    | XML_NODE          // 'node'
    | XML_STREAM        // 'stream'
    | HTML              // 'html'
    | XML               // 'xml'
    | DATA_IDATA        // 'idata'
    | VALIDATION_NONE   // 'none'
    | DISP_TEXT         // 'Text field'
    | DISP_PASS         // 'Password'
    | DISP_LARGE        // 'Large editor'
    | DISP_PICK         // 'Picklist'
    ;

// Java wrapper type keywords that can appear in service paths
javaWrapperKeyword
    : JAVA_BOOLEAN      // 'java.lang.Boolean'
    | JAVA_BYTE         // 'java.lang.Byte'
    | JAVA_CHAR         // 'java.lang.Character'
    | JAVA_DOUBLE       // 'java.lang.Double'
    | JAVA_FLOAT        // 'java.lang.Float'
    | JAVA_INT          // 'java.lang.Integer'
    | JAVA_LONG         // 'java.lang.Long'
    | JAVA_SHORT        // 'java.lang.Short'
    ;

// Boolean literal keywords that can appear in service paths
// Allows 'true' and 'false' to be used as service names
booleanLiteralKeyword
    : BOOLEAN_LITERAL   // 'true' or 'false'
    ;

dropStep
    : DROP variableRef SEMI
    ;

// --- Control Structures ---

ifThenStep     : IF LPAR expression RPAR LBRACE stepProperty* step* RBRACE elseIfBlock* elseBlock? ;
elseIfBlock    : ELSEIF LPAR expression RPAR LBRACE stepProperty* step* RBRACE ;
elseBlock      : ELSE LBRACE stepProperty* step* RBRACE ;

switchCaseStep : SWITCH LPAR switchCondition=expression RPAR LBRACE stepProperty* caseBlock+ RBRACE ;
caseBlock      : CASE (caseVal=value) COLON stepProperty* step* ;

tryStep        : TRY LBRACE stepProperty* tryProperty* step* RBRACE catchStep* finallyStep? ;

catchStep      : CATCH (LBRACE stepProperty* catchProperty* step* RBRACE)? ;

finallyStep    : FINALLY (LBRACE stepProperty* finallyProperty* step* RBRACE)? ;

loopStep       : LOOP LBRACE stepProperty* loopProperty* step* RBRACE
               | LOOP SEMI 
               ;

sequenceStep   : SEQUENCE LBRACE stepProperty* sequenceProperty* step* RBRACE
               | SEQUENCE SEMI 
               ;

branchStep     : BRANCH LBRACE stepProperty* branchProperty* step* RBRACE
               | BRANCH SEMI 
               ;

repeatStep     : REPEAT LBRACE (stepProperty | repeatProperty)* step* RBRACE
               | REPEAT SEMI
               ;

doUntilStep    : DO LBRACE doProps+=stepProperty* doUntilProperty* step* RBRACE UNTIL LPAR expression RPAR (LBRACE untilProps+=stepProperty* RBRACE)? SEMI? ;

exitStep       : EXIT LBRACE exitProperty* RBRACE
               | EXIT SEMI 
               ;

whileStep      : WHILE LPAR expression RPAR (LBRACE stepProperty* doUntilProperty* step* RBRACE)? ;

continueStep   : CONTINUE (LBRACE commentProperty* RBRACE)?
               | CONTINUE SEMI 
               ;

breakStep      : BREAK (LBRACE commentProperty* RBRACE)?
               | BREAK SEMI 
               ;

// --- Properties & Operators ---

stepProperty
    : COMMENT COLON STRING_LITERAL
    | SCOPE   COLON scopePath
    | TIMEOUT COLON timeoutValue
    | LABEL   COLON STRING_LITERAL
    | DISABLED COLON BOOLEAN_LITERAL
    ;

commentProperty : COMMENT COLON STRING_LITERAL ;
scopePath       : anyIdentifier ( DIV anyIdentifier )* ;
scopeProperty   : SCOPE COLON scopePath ;
timeoutProperty : TIMEOUT COLON (numericValue | STRING_LITERAL) ;
labelProperty   : LABEL COLON STRING_LITERAL ;
disabledProperty: DISABLED COLON BOOLEAN_LITERAL ;

timeoutValue
    : numericValue                      // Handles raw values: 60, 5s, 10.5m
    | STRING_LITERAL                    // Handles quoted values: "60"
    | SUBSTITUTION_VAR ID?              // Handles %timeout% or %timeout%S
    ;

// --- Other Step Properties ---

mapProperty : MODE COLON ID ;

invokeProperty
    : VALIDATE_INPUT COLON validationValue
    | VALIDATE_OUTPUT COLON validationValue
    | DISABLED COLON BOOLEAN_LITERAL
    ;

validationValue : BOOLEAN_LITERAL | VALIDATION_NONE ;

transformProperty 
    : INVOKE_ORDER COLON INT 
    | VALIDATE_INPUT COLON validationValue 
    | VALIDATE_OUTPUT COLON validationValue 
    | DISABLED COLON BOOLEAN_LITERAL 
    ;

loopProperty
    : INPUT_ARRAY COLON STRING_LITERAL
    | OUTPUT_ARRAY COLON STRING_LITERAL
    | MAX_THREADS COLON STRING_LITERAL
    | PARALLEL_ERROR_HANDLING COLON STRING_LITERAL
    ;

sequenceProperty : EXIT_ON COLON expression ;

tryProperty : EXIT_ON COLON expression ;

catchProperty 
    : EXIT_ON COLON expression 
    | FAILURES COLON STRING_LITERAL 
    | SELECTION COLON expression 
    ;

finallyProperty : EXIT_ON COLON expression ;

branchProperty 
    : SWITCH_PROP COLON expression 
    | EVAL_LABELS COLON BOOLEAN_LITERAL 
    ;

repeatProperty
    : COUNT COLON ((MINUS)? INT | STRING_LITERAL | SUBSTITUTION_VAR)
    | REPEAT_INTERVAL COLON (FLOAT_LITERAL ID? | INT ID? | STRING_LITERAL | SUBSTITUTION_VAR)
    | REPEAT_ON COLON expression
    ;

// Numeric value rule to support integers, floats, and time formats like "5s", "10m", "2h", "1d"
// Used by TIMEOUT and other properties that accept numeric values with optional time units
numericValue
    : FLOAT_LITERAL ID?
    | INT ID?
    ;

exitProperty
    : COMMENT COLON STRING_LITERAL 
    | LABEL COLON STRING_LITERAL 
    | SIGNAL COLON STRING_LITERAL 
    | FAILURE_NAME COLON STRING_LITERAL 
    | FAILURE_INSTANCE COLON STRING_LITERAL 
    | EXIT_FROM COLON STRING_LITERAL 
    | FAILURE_MESSAGE COLON STRING_LITERAL 
    ;

doUntilProperty : MAX_ITERATION COLON (MINUS)? INT ;
    
setAttributes : LPAR setAttribute (COMMA setAttribute)* RPAR ;

setAttribute : (NOT)? OVERWRITE | (NOT)? VARIABLE | (NOT)? GLOBAL_VARIABLES ;

stepBlock : LBRACE step* RBRACE ;

// =================================================================
// --- Structural Literal Values (Add this to the bottom of the file) ---
// =================================================================

// Right-Hand Assignment Router (Prioritized to match structures first)
value
    : arrayLiteral
    | jsonObject
    | expression
    ;

// Handles empty [] or populated arrays [1, 2, 3]
arrayLiteral 
    : LBRACK (jsonValue (COMMA jsonValue)*)? RBRACK 
    ; 

// Handles empty {} or populated documents {"key": "value"}
jsonObject   
    : LBRACE (jsonPair (COMMA jsonPair)*)? RBRACE 
    ;

// Key-value pair configuration for maps/documents
jsonPair     
    : (STRING_LITERAL | anyIdentifier) COLON jsonValue 
    ;

// Permitted types inside arrays or documents
jsonValue    
    : STRING_LITERAL 
    | INT 
    | FLOAT_LITERAL 
    | BOOLEAN_LITERAL 
    | NULL_LITERAL 
    | arrayLiteral
    | jsonObject
    ;
