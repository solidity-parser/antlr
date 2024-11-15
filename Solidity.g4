// Copyright 2020 Gonçalo Sá <goncalo.sa@consensys.net>
// Copyright 2016-2019 Federico Bond <federicobond@gmail.com>
// Licensed under the MIT license. See LICENSE file in the project root for details.

grammar Solidity;

sourceUnit
  : (
    pragmaDirective
    | importDirective
    | contractDefinition
    | enumDefinition
    | eventDefinition
    | structDefinition
    | functionDefinition
    | fileLevelConstant
    | customErrorDefinition
    | typeDefinition
    | usingForDeclaration
    )* EOF ;

pragmaDirective
  : 'pragma' pragmaName pragmaValue ';' ;

pragmaName
  : identifier ;

pragmaValue
  : '*' | version | expression ;

version
  : versionConstraint ('||'? versionConstraint)* ;

versionOperator
  : '^' | '~' | '>=' | '>' | '<' | '<=' | '=' ;

versionConstraint
  : versionOperator? VersionLiteral
  | versionOperator? DecimalNumber ;

importDeclaration
  : identifier ('as' identifier)? ;

importDirective
  : 'import' importPath ('as' identifier)? ';'
  | 'import' ('*' | identifier) ('as' identifier)? 'from' importPath ';'
  | 'import' '{' importDeclaration ( ',' importDeclaration )* '}' 'from' importPath ';' ;

importPath : StringLiteralFragment ;

contractDefinition
  : 'abstract'? ( 'contract' | 'interface' | 'library' ) identifier
    ( 'is' inheritanceSpecifier (',' inheritanceSpecifier )* )?
    '{' contractPart* '}' ;

inheritanceSpecifier
  : userDefinedTypeName ( '(' expressionList? ')' )? ;

contractPart
  : stateVariableDeclaration
  | usingForDeclaration
  | structDefinition
  | modifierDefinition
  | functionDefinition
  | eventDefinition
  | enumDefinition
  | customErrorDefinition
  | typeDefinition;

stateVariableDeclaration
  : typeName
    ( PublicKeyword | InternalKeyword | PrivateKeyword | ConstantKeyword | TransientKeyword | ImmutableKeyword | overrideSpecifier )*
    identifier ('=' expression)? ';' ;

fileLevelConstant
  : typeName ConstantKeyword identifier '=' expression ';' ;

customErrorDefinition
  : 'error' identifier parameterList ';' ;

typeDefinition
  : 'type' identifier
    'is'  elementaryTypeName ';' ;

usingForDeclaration
  : 'using' usingForObject 'for' ('*' | typeName) GlobalKeyword? ';';

usingForObject
  : userDefinedTypeName
  | '{' usingForObjectDirective ( ',' usingForObjectDirective )* '}';

usingForObjectDirective
  : userDefinedTypeName ( 'as' userDefinableOperators )?;

userDefinableOperators
  : '|' | '&' | '^' | '~' | '+' | '-' | '*' | '/' | '%' | '==' | '!=' | '<' | '>' | '<=' | '>=' ;

structDefinition
  : 'struct' identifier
    '{' ( variableDeclaration ';' (variableDeclaration ';')* )? '}' ;

modifierDefinition
  : 'modifier' identifier parameterList? ( VirtualKeyword | overrideSpecifier )* ( ';' | block ) ;

modifierInvocation
  : identifier ( '(' expressionList? ')' )? ;

functionDefinition
  : functionDescriptor parameterList modifierList returnParameters? ( ';' | block ) ;

functionDescriptor
  : 'function' identifier?
  | ConstructorKeyword
  | FallbackKeyword
  | ReceiveKeyword ;

returnParameters
  : 'returns' parameterList ;

modifierList
  : (ExternalKeyword | PublicKeyword | InternalKeyword | PrivateKeyword | VirtualKeyword | stateMutability | modifierInvocation | overrideSpecifier )* ;

eventDefinition
  : 'event' identifier eventParameterList AnonymousKeyword? ';' ;

enumValue
  : identifier ;

enumDefinition
  : 'enum' identifier '{' enumValue? (',' enumValue)* '}' ;

parameterList
  : '(' ( parameter (',' parameter)* )? ')' ;

parameter
  : typeName storageLocation? identifier? ;

eventParameterList
  : '(' ( eventParameter (',' eventParameter)* )? ')' ;

eventParameter
  : typeName IndexedKeyword? identifier? ;

functionTypeParameterList
  : '(' ( functionTypeParameter (',' functionTypeParameter)* )? ')' ;

functionTypeParameter
  : typeName storageLocation? ;

variableDeclaration
  : typeName storageLocation? identifier ;

typeName
  : elementaryTypeName
  | userDefinedTypeName
  | mapping
  | typeName '[' expression? ']'
  | functionTypeName
  | 'address' 'payable' ;

userDefinedTypeName
  : identifier ( '.' identifier )* ;

mappingKey
  : elementaryTypeName
  | userDefinedTypeName ;

mapping
  : 'mapping' '(' mappingKey mappingKeyName? '=>' typeName mappingValueName? ')' ;

mappingKeyName : identifier;
mappingValueName : identifier;

functionTypeName
  : 'function' functionTypeParameterList
    ( InternalKeyword | ExternalKeyword | stateMutability )*
    ( 'returns' functionTypeParameterList )? ;

storageLocation
  : 'memory' | 'storage' | 'calldata';

stateMutability
  : PureKeyword | ConstantKeyword | ViewKeyword | PayableKeyword ;

block
  : '{' statement* '}' ;

statement
  : ifStatement
  | tryStatement
  | whileStatement
  | forStatement
  | block
  | inlineAssemblyStatement
  | doWhileStatement
  | continueStatement
  | breakStatement
  | returnStatement
  | throwStatement
  | emitStatement
  | simpleStatement
  | uncheckedStatement
  | revertStatement;

expressionStatement
  : expression ';' ;

ifStatement
  : 'if' '(' expression ')' statement ( 'else' statement )? ;

tryStatement : 'try' expression returnParameters? block catchClause+ ;

// In reality catch clauses still are not processed as below
// the identifier can only be a set string: "Error". But plans
// of the Solidity team include possible expansion so we'll
// leave this as is, befitting with the Solidity docs.
catchClause : 'catch' ( identifier? parameterList )? block ;

whileStatement
  : 'while' '(' expression ')' statement ;

simpleStatement
  : ( variableDeclarationStatement | expressionStatement ) ;

uncheckedStatement
  : 'unchecked' block ;

forStatement
  : 'for' '(' ( simpleStatement | ';' ) ( expressionStatement | ';' ) expression? ')' statement ;

inlineAssemblyStatement
  : 'assembly' StringLiteralFragment? ('(' inlineAssemblyStatementFlag ')')? assemblyBlock ;

inlineAssemblyStatementFlag
  : stringLiteral;

doWhileStatement
  : 'do' statement 'while' '(' expression ')' ';' ;

continueStatement
  : 'continue' ';' ;

breakStatement
  : 'break' ';' ;

returnStatement
  : 'return' expression? ';' ;

throwStatement
  : 'throw' ';' ;

emitStatement
  : 'emit' functionCall ';' ;

revertStatement
  : 'revert' functionCall ';' ;

variableDeclarationStatement
  : ( 'var' identifierList | variableDeclaration | '(' variableDeclarationList ')' ) ( '=' expression )? ';';

variableDeclarationList
  : variableDeclaration? (',' variableDeclaration? )* ;

identifierList
  : '(' ( identifier? ',' )* identifier? ')' ;

elementaryTypeName
  : 'address' | 'bool' | 'string' | 'var' | Int | Uint | 'byte' | Byte | Fixed | Ufixed ;

Int
  : 'int' (NumberOfBits)? ;

Uint
  : 'uint' (NumberOfBits)? ;

Byte
  : 'bytes' (NumberOfBytes)?;

Fixed
  : 'fixed' ( NumberOfBits 'x' [0-9]+ )? ;

Ufixed
  : 'ufixed' ( NumberOfBits 'x' [0-9]+ )? ;

fragment
NumberOfBits
  : '8' | '16' | '24' | '32' | '40' | '48' | '56' | '64' | '72' | '80' | '88' | '96' | '104' | '112' | '120' | '128' | '136' | '144' | '152' | '160' | '168' | '176' | '184' | '192' | '200' | '208' | '216' | '224' | '232' | '240' | '248' | '256' ;

fragment
NumberOfBytes
  : [1-9] | [12] [0-9] | '3' [0-2] ;

expression
  : expression ('++' | '--')
  | 'new' typeName
  | expression '[' expression ']'
  | expression '[' expression? ':' expression? ']'
  | expression '.' identifier
  | expression '{' nameValueList '}'
  | expression '(' functionCallArguments ')'
  | '(' expression ')'
  | ('++' | '--') expression
  | ('+' | '-') expression
  | 'delete' expression
  | '!' expression
  | '~' expression
  | <assoc=right> expression '**' expression
  | expression ('*' | '/' | '%') expression
  | expression ('+' | '-') expression
  | expression ('<<' | '>>') expression
  | expression '&' expression
  | expression '^' expression
  | expression '|' expression
  | expression ('<' | '>' | '<=' | '>=') expression
  | expression ('==' | '!=') expression
  | expression '&&' expression
  | expression '||' expression
  | <assoc=right> expression '?' expression ':' expression
  | expression ('=' | '|=' | '^=' | '&=' | '<<=' | '>>=' | '+=' | '-=' | '*=' | '/=' | '%=') expression
  | primaryExpression ;

primaryExpression
  : BooleanLiteral
  | numberLiteral
  | hexLiteral
  | stringLiteral
  | identifier
  | TypeKeyword
  | PayableKeyword
  | tupleExpression
  | typeName;

expressionList
  : expression (',' expression)* ;

nameValueList
  : nameValue (',' nameValue)* ','? ;

nameValue
  : identifier ':' expression ;

functionCallArguments
  : '{' nameValueList? '}'
  | expressionList? ;

functionCall
  : expression '(' functionCallArguments ')' ;

assemblyBlock
  : '{' assemblyItem* '}' ;

assemblyItem
  : identifier
  | assemblyBlock
  | assemblyExpression
  | assemblyLocalDefinition
  | assemblyAssignment
  | assemblyStackAssignment
  | labelDefinition
  | assemblySwitch
  | assemblyFunctionDefinition
  | assemblyFor
  | assemblyIf
  | BreakKeyword
  | ContinueKeyword
  | LeaveKeyword
  | numberLiteral
  | stringLiteral
  | hexLiteral ;

assemblyExpression
  : assemblyCall | assemblyLiteral | assemblyMember ;

assemblyMember
  : identifier '.' identifier ;

assemblyCall
  : ( 'return' | 'address' | 'byte' | identifier ) ( '(' assemblyExpression? ( ',' assemblyExpression )* ')' )? ;

assemblyLocalDefinition
  : 'let' assemblyIdentifierOrList ( ':=' assemblyExpression )? ;

assemblyAssignment
  : assemblyIdentifierOrList ':=' assemblyExpression;

assemblyIdentifierOrList
  : identifier
  | assemblyMember
  | assemblyIdentifierList
  | '(' assemblyIdentifierList ')';

assemblyIdentifierList
  : identifier ( ',' identifier )* ;

assemblyStackAssignment
  : assemblyExpression '=:' identifier ;

labelDefinition
  : identifier ':' ;

assemblySwitch
  : 'switch' assemblyExpression assemblyCase* ;

assemblyCase
  : 'case' assemblyLiteral assemblyBlock
  | 'default' assemblyBlock ;

assemblyFunctionDefinition
  : 'function' identifier '(' assemblyIdentifierList? ')'
    assemblyFunctionReturns? assemblyBlock ;

assemblyFunctionReturns
  : ( '->' assemblyIdentifierList ) ;

assemblyFor
  : 'for' ( assemblyBlock | assemblyExpression )
    assemblyExpression ( assemblyBlock | assemblyExpression ) assemblyBlock ;

assemblyIf
  : 'if' assemblyExpression assemblyBlock ;

assemblyLiteral
  : stringLiteral | DecimalNumber | HexNumber | hexLiteral | BooleanLiteral ;

tupleExpression
  : '(' ( expression? ( ',' expression? )* ) ')'
  | '[' ( expression ( ',' expression )* )? ']' ;

numberLiteral
  : (DecimalNumber | HexNumber) NumberUnit? ;

// some keywords need to be added here to avoid ambiguities
// for example, "revert" is a keyword but it can also be a function name
identifier
  : ('from' | 'calldata' | 'receive' | 'callback' | 'revert' | 'error' | 'address' | GlobalKeyword | ConstructorKeyword | PayableKeyword | LeaveKeyword | Identifier) ;

BooleanLiteral
  : 'true' | 'false' ;

DecimalNumber
  : ( DecimalDigits | (DecimalDigits? '.' DecimalDigits) ) ( [eE] '-'? DecimalDigits )? ;

fragment
DecimalDigits
  : [0-9] ( '_'? [0-9] )* ;

HexNumber
  : '0' [xX] HexDigits ;

fragment
HexDigits
  : HexCharacter ( '_'? HexCharacter )* ;

NumberUnit
  : 'wei' | 'gwei' | 'szabo' | 'finney' | 'ether'
  | 'seconds' | 'minutes' | 'hours' | 'days' | 'weeks' | 'years' ;

hexLiteral : HexLiteralFragment+ ;

HexLiteralFragment : 'hex' ('"' HexDigits? '"' | '\'' HexDigits? '\'') ;

fragment
HexCharacter
  : [0-9A-Fa-f] ;

ReservedKeyword
  : 'after'
  | 'alias'
  | 'apply'
  | 'auto'
  | 'case'
  | 'copyof'
  | 'default'
  | 'define'
  | 'final'
  | 'implements'
  | 'in'
  | 'inline'
  | 'let'
  | 'macro'
  | 'match'
  | 'mutable'
  | 'null'
  | 'of'
  | 'partial'
  | 'promise'
  | 'reference'
  | 'relocatable'
  | 'sealed'
  | 'sizeof'
  | 'static'
  | 'supports'
  | 'switch'
  | 'typedef'
  | 'typeof' ;

AnonymousKeyword : 'anonymous' ;
BreakKeyword : 'break' ;
ConstantKeyword : 'constant' ;
TransientKeyword : 'transient' ;
ImmutableKeyword : 'immutable' ;
ContinueKeyword : 'continue' ;
LeaveKeyword : 'leave' ;
ExternalKeyword : 'external' ;
IndexedKeyword : 'indexed' ;
InternalKeyword : 'internal' ;
PayableKeyword : 'payable' ;
PrivateKeyword : 'private' ;
PublicKeyword : 'public' ;
VirtualKeyword : 'virtual' ;
PureKeyword : 'pure' ;
TypeKeyword : 'type' ;
ViewKeyword : 'view' ;
GlobalKeyword : 'global' ;

ConstructorKeyword : 'constructor' ;
FallbackKeyword : 'fallback' ;
ReceiveKeyword : 'receive' ;

overrideSpecifier : 'override' ( '(' userDefinedTypeName (',' userDefinedTypeName)* ')' )? ;

Identifier
  : IdentifierStart IdentifierPart* ;

fragment
IdentifierStart
  : [a-zA-Z$_] ;

fragment
IdentifierPart
  : [a-zA-Z0-9$_] ;

stringLiteral
  : StringLiteralFragment+ ;

StringLiteralFragment
  : 'unicode'? ( '"' DoubleQuotedStringCharacter* '"' | '\'' SingleQuotedStringCharacter* '\'' ) ;

fragment
DoubleQuotedStringCharacter
  : ~["\r\n\\] | ('\\' .) ;

fragment
SingleQuotedStringCharacter
  : ~['\r\n\\] | ('\\' .) ;

VersionLiteral
  : [0-9]+ '.' [0-9]+ ('.' [0-9]+)? ;

WS
  : [ \t\r\n\u000C]+ -> skip ;

COMMENT
  : '/*' .*? '*/' -> channel(HIDDEN) ;

LINE_COMMENT
  : '//' ~[\r\n]* -> channel(HIDDEN) ;
