/** Based on the arc lexer (http://code.google.com/p/intelli-arc/) **/

package com.r4intellij.lang.lexer;

import com.intellij.lexer.FlexLexer;
import com.intellij.psi.tree.IElementType;
import static com.r4intellij.psi.RTypes.*;
import static org.intellij.grammar.BnfParserDefinition.BNF_LINE_COMMENT;
import static org.intellij.grammar.BnfParserDefinition.BNF_BLOCK_COMMENT;


import com.intellij.util.containers.Stack;

%%


%class _RLexer
%implements FlexLexer
%unicode
%public
%char

%function advance
%type IElementType

%{
  StringBuffer string = new StringBuffer();

  //helper
  long yychar = 0;
%}

/*
Macro Declarations

These declarations are regular expressions that will be used latter in the
Lexical Rules Section.
*/

/* A line terminator is a \r (carriage return), \n (line feed), or \r\n. */
LineTerminator = \r|\n|\r\n
WHITE_SPACE= {LineTerminator} | [ \t\f]
COMMENT = "#"[^\r\n]*

/* A identifier integer is a word beginning a letter between A and Z, a and z,
or an underscore followed by zero or more letters between A and Z, a and z,
zero and nine, or an underscore. */
SYMBOL = [A-Za-z_][A-Za-z_0-9._]*


/* A literal integer is is a number beginning with a number between one and nine
followed by zero or more numbers between zero and nine or just a zero. */
IntLiteral = 0 | [1-9][0-9]*[L]?


Exponent = [eE] [+-]? [0-9]+
FLit1    = [0-9]+ \. [0-9]*
FLit2    = \. [0-9]+
FLit3    = [0-9]+
DoubleLiteral = ({FLit1}|{FLit2}|{FLit3}) {Exponent}?

//StringCharacter = [^\r\n]
// picked up from arc.flex :
EscapeSequence=\\[^\r\n]
STRING=\"([^\\\"]|{EscapeSequence})*(\"|\\)?

//%state STRING

%%

/* ------------------------Lexical Rules Section---------------------- */

/*
This section contains regular expressions and actions, i.e. Java code, that
will be executed when the scanner matches the associated regular expression. */

/* YYINITIAL is the state at which the lexer begins scanning.  So these regular
expressions will only be matched if the scanner is in the start state
YYINITIAL. */

%%

<YYINITIAL> {
  {WHITE_SPACE} {yybegin(YYINITIAL); return com.intellij.psi.TokenType.WHITE_SPACE; }
  {COMMENT} {yybegin(YYINITIAL); return R_COMMENT; }

  {STRING} {yybegin(YYINITIAL); return RTypes.R_STR_CONST; }
  {NUMBER} {yybegin(YYINITIAL); return RTypes.R_NUM_CONST; }
  {SYMBOL} {yybegin(YYINITIAL); return RTypes.R_SYMBOL; }

  ";" {yybegin(YYINITIAL); return RTypes.R_SEMICOLON; }

  "(" {yybegin(YYINITIAL); return RTypes.R_LEFT_PAREN; }
  ")" {yybegin(YYINITIAL); return RTypes.R_RIGHT_PAREN; }
  "{" {yybegin(YYINITIAL); return RTypes.R_LEFT_BRACE; }
  "}" {yybegin(YYINITIAL); return RTypes.R_RIGHT_BRACE; }
  "[" {yybegin(YYINITIAL); return RTypes.R_LEFT_BRACKET; }
  "]" {yybegin(YYINITIAL); return RTypes.R_RIGHT_BRACKET; }
  "<<" {yybegin(YYINITIAL); return RTypes.R_EXTERNAL_START; }
  ">>" {yybegin(YYINITIAL); return RTypes.R_EXTERNAL_END; }


  "::=" {yybegin(YYINITIAL); return RTypes.R_OP_IS; }
  "=" {yybegin(YYINITIAL); return RTypes.R_OP_EQ; }
  "+" {yybegin(YYINITIAL); return RTypes.R_OP_ONEMORE; }
  "*" {yybegin(YYINITIAL); return RTypes.R_OP_ZEROMORE; }
  "?" {yybegin(YYINITIAL); return RTypes.R_OP_OPT; }
  "!" {yybegin(YYINITIAL); return RTypes.R_OP_NOT; }
  "|" {yybegin(YYINITIAL); return RTypes.R_OP_OR; }



  {BAD_TOKENS} {yybegin(YYINITIAL); return com.intellij.psi.TokenType.BAD_CHARACTER; }
  [^] {yybegin(YYINITIAL); return com.intellij.psi.TokenType.BAD_CHARACTER; }

}


<YYINITIAL> {

      /* If an identifier is found print it out , return the token ID that
    represents an identifier and the default value one that is given to all
    identifiers. */
    //{Variable} { System.out.print("word:"+yytext()); return WORD;}


    "FALSE" | "F" | "TRUE" | "T" | "pi" | "NULL" { return CONSTANT; }


    // separators
    "(" { return LEFT_PAREN; }
    ")" { return RIGHT_PAREN; }
    "{" { return LEFT_CURLY; }
    "}" { return RIGHT_CURLY; }
    "[" { return LEFT_SQUARE; }
    "]" { return RIGHT_SQUARE; }
    ";" { return SEMICOLON; }
    "," { return COMMA; }


    // operators
    "-" { return ARITH_MINUS; }
    "+" { return ARITH_PLUS; }
    "!" { return NEGATION; }
    "~" { return TILDE; }
    "?" {}
    ":" { return COLON; }
    "*" { return ARITH_MULT; }
    "/" { return ARITH_DIV; }
    "^" { return ARITH_EXPONENTIAION; }
    "%%" { return ARITH_MOD; }

    "%/%" | "%*%" | "%o%" | "%x%" | "%in%"  { return ARITH_MISC; }

    "&" | "&&" | "|" | "||" | ("<"|">")[=]? { return LOG_OPERATOR; }

    "$" { return LIST_SUBSET; }

    // misc
    "..." { return VARARGS; }
    "<-" | "=" | "->"  { return ASSIGNMENT; }


    // todo refactor these away
    "." { return DOT; }

    // string literal
//    \" | \' {// yybegin(STRING); string.setLength(0); }

    {IntLiteral} | {DoubleLiteral}  { return NUMBER; }

    {Identifier} { return IDENTIFIER; }
//    {Identifier} {System.out.print("word:"+yytext());  return IDENTIFIER; }

    {Comment} {return COMMENT; }
    {WhiteSpace} { return com.intellij.psi.TokenType.WHITE_SPACE; }
//    {WhiteSpace} { /* skip this */ }

    {StringLiteral}  { return STRING_LITERAL; }
//    "\"" ({StringCharacter} | "\'" | "}")* "\""   { return STRING_LITERAL; }
//    "\'" ({StringCharacter} | "\"")* "\'"   { return STRING_LITERAL; }

   // "\"\\t\"" {return  STRING_LITERAL; }
}
