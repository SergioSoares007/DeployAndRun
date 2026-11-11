parser grammar Document;

options {
    tokenVocab=AssetLexer;
}

import CommonProperties;

/**
 * ENTRY POINT: documentFile
 * Use this to parse standalone .ndp / Document Type assets.
 */
documentFile
    : interfaceDeclaration? documentCategory ID LBRACE 
        documentPropertyBlock?           // <-- Specialized properties block for document assets
        messagingBlock?                  // <-- Separate messaging properties block
        parameterDeclaration* RBRACE SEMI?
    ;

documentCategory
    : SERVICE        // For service-linked documents
    | DOCUMENT_TYPE  // For standalone Document assets
    | RECORD_TYPE    // For inline record definitions
    ;

// --- Parameter Declarations (The Data Tree) ---
parameterDeclaration
    : fieldDeclaration
    | recordDeclaration
    ;

fieldDeclaration
    : fieldType=dataType (ARRAY_SUFFIX | LBRACK RBRACK)* fieldName=dottedFieldName simpleFieldPropertyBlock? constraints? SEMI
    ;

recordDeclaration
    : (RECORD_TYPE | RECORD_LIST) fieldName=dottedFieldName
      (LPAR (documentReference | namespaceName) RPAR)?
      recordFieldPropertyBlock?
      (LBRACE documentPropertyBlock? parameterDeclaration* RBRACE)?
      constraints? SEMI?
    ;

// Property block for simple fields (no allowUnspecifiedFields)
simpleFieldPropertyBlock
    : LBRACE simpleFieldPropertyEntry* RBRACE
    ;

simpleFieldPropertyEntry
    : REQUIRED COLON BOOLEAN_LITERAL SEMI
    | ALLOW_NULL COLON BOOLEAN_LITERAL SEMI
    | CONTENT_TYPE COLON STRING_LITERAL SEMI
    | COMMENT COLON (STRING_LITERAL | TEXT_BLOCK) SEMI
    ;

// Property block for record/recordList fields (includes allowUnspecifiedFields)
recordFieldPropertyBlock
    : LBRACE recordFieldPropertyEntry* RBRACE
    ;

recordFieldPropertyEntry
    : REQUIRED COLON BOOLEAN_LITERAL SEMI
    | ALLOW_NULL COLON BOOLEAN_LITERAL SEMI
    | ALLOW_UNSPECIFIED_FIELDS COLON BOOLEAN_LITERAL SEMI
    | COMMENT COLON (STRING_LITERAL | TEXT_BLOCK) SEMI
    ;

dottedFieldName
    : anyIdentifier (DOT anyIdentifier)*
    ;

// --- Referencing & Constraints ---
documentReference 
    : namespaceName 
    ;

constraints : LBRACK constraint (COMMA constraint)* RBRACK ;

constraint
    : REQUIRED
    | OPTIONAL
    | DEFAULT EQUALS literalVal=literal
    | FACET_MIN_LEN EQUALS INT
    | FACET_MAX_LEN EQUALS INT
    | FACET_PATTERN EQUALS STRING_LITERAL
    ;

// --- Data Types ---
dataType
    : DOCUMENT_DATA | STRING_TYPE | OBJECT_TYPE | INTEGER_TYPE | FLOAT_TYPE | DOUBLE_TYPE 
    | BOOLEAN_TYPE | DATETIME_TYPE | BYTE_TYPE | CHAR_TYPE
    | LONG_TYPE | SHORT_TYPE | BIGINTEGER_TYPE | BIGDECIMAL_TYPE | XOPOBJECT_TYPE
    ;

// --- Document-Specific Properties Block ---
documentPropertyBlock
    : PROPERTIES LBRACE documentPropertyEntry* RBRACE
    ;

documentPropertyEntry
    : generalProperty                           // Inherited from CommonProperties (display name, comment, etc.)
    | permissionsBlock                          // Inherited from CommonProperties
    | fieldProperty                             // Reuses common field traits (nillable, xml ns, etc.)
    | MODEL_TYPE       COLON modelTypeValue SEMI
    | DOC_DATA_TYPE    COLON ENC_IDATA SEMI
    | ROLE             COLON (STRING_LITERAL | anyIdentifier) SEMI
    | LINKED_SOURCE    COLON BOOLEAN_LITERAL SEMI
    | SCHEMA_DOMAIN    COLON (STRING_LITERAL | anyIdentifier) SEMI
    | REGISTERED       COLON BOOLEAN_LITERAL SEMI
    | SCHEMA_TYPE_NAME COLON (STRING_LITERAL | anyIdentifier) SEMI
    ;

modelTypeValue
    : MODEL_HIER
    | MODEL_FLAT
    | MODEL_UNORD
    ;

// --- Messaging Configuration Block ---
messagingBlock
    : MESSAGING LBRACE messagingProperty* RBRACE
    ;

messagingProperty
    : PUBLISHABLE  COLON BOOLEAN_LITERAL SEMI
    | CONN_ALIAS   COLON (STRING_LITERAL | anyIdentifier) SEMI
    | CONN_TYPE    COLON (STRING_LITERAL | anyIdentifier) SEMI
    | PROV_DEF     COLON STRING_LITERAL SEMI
    | ENCODING     COLON encodingTypeValue SEMI
    | DISCARD      COLON BOOLEAN_LITERAL SEMI
    | TTL          COLON INT SEMI
    | STORAGE_TYPE COLON storageTypeValue SEMI
    | VALIDATE_PUB COLON BOOLEAN_LITERAL SEMI
    ;

encodingTypeValue
    : ENC_PROTO
    | ENC_IDATA
    ;

storageTypeValue
    : STORAGE_GUAR
    | STORAGE_VOL
    ;
