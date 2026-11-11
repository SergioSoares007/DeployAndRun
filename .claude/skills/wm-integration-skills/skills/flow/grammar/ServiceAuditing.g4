parser grammar ServiceAuditing;

options {
    tokenVocab=AssetLexer;
}

// Import Lexer tokens through the foundation chain
// This module implements the "path-style" notation for deep hierarchies
auditLoggingBlock
    : (inputLoggedFields | outputLoggedFields)*
    ;

inputLoggedFields
    : LOGGED_INPUT COLON LBRACK fieldPath (COMMA fieldPath)* RBRACK SEMI
    ;

outputLoggedFields
    : LOGGED_OUTPUT COLON LBRACK fieldPath (COMMA fieldPath)* RBRACK SEMI
    ;

// Path-style notation: e.g., "OrderDoc/Header/TransactionID"
fieldPath
    : STRING_LITERAL 
    ;
