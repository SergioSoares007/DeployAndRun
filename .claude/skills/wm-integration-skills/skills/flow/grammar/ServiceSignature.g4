parser grammar ServiceSignature;

options {
    tokenVocab=AssetLexer;
}

// Import Common for metadata and Document for parameterDeclaration
import CommonProperties, Document;

// --- Entry Point ---
// The rule FlowService will call
signature
    : LPAR inputBlock? outputBlock? RPAR
    ;

inputBlock
    : INPUT LBRACE parameterDeclaration* RBRACE SEMI?
    ;

outputBlock
    : OUTPUT LBRACE parameterDeclaration* RBRACE SEMI?
    ;

// --- Values & Data Structures ---
value 
    : literal 
    | arrayLiteral 
    | jsonObject 
    | expression 
    ;
