
digit       [0-9]
letter      [a-zA-Z]
integer     [+-]?(0|[1-9]){digit}*
real        [+-]?(0|[1-9]){digit}*\.{digit}+([eE][-+]?{digit}+)?
identifier  {letter}+({letter}|{digit}|_)*
string      \"([^\"\n]|\"\")*\"



%{

#include "symtab.h"
#include "y.tab.h"
#define LIST     strcat(buf,yytext)

#define token(t) {LIST; printf("<%s>\n", #t);  return(t);}                     

#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",#t,atoi(i)); return(t);}
#define tokenFloat(t,i) {LIST; printf("<%s: %f>\n",#t,atof(i)); return(t);}
#define tokenString(t,s) {LIST; printf("<%s: %s>\n",#t,s); return(t);}
#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
char string_revise[MAX_LINE_LENG];
SymbolTable symtab;
%}

%%


"//".*    {LIST;}

\/\*([^*]|(\*+[^*/]))*\*+\/    {LIST;}


","     {token(',');}
":"     {token(':');}
";"     {token(';');}
"->"    {token(ARROW);}
"("     {token('(');}
")"     {token(')');}
"["     {token('[');}
"]"     {token(']');}
"{"     {token('{');}
"}"     {token('}');}


"+"     {token('+');}
"-"     {token('-');}
"*"     {token('*');}
"/"     {token('/');}
"%"     {token('%');}
"<"     {token('<');}
"<="    {token(LEQ);}
">="    {token(GEQ);}
">"     {token('>');}
"=="    {token(EQ);}
"!="    {token(NEQ);}
"&"     {token('&');}
"|"     {token('|');}
"!"     {token('!');}
"="     {token('=');}
"+="    {token(ADDEQ);}
"-="    {token(SUBEQ);}
"*="    {token(MULEQ);}
"/="    {token(DIVEQ);}

"bool"  {token(BOOL);}
"break"  {token(BREAK);}
"char"  {token(CHAR);}
"case"  {token(CASE);}
"class"  {token(CLASS);}
"continue"  {token(CONTINUE);}
"declare"  {token(DECLARE);}
"do"  {token(DO);}
"else"  {token(ELSE);}
"exit"  {token(EXIT);}
"float"  {token(FLOAT);}
"for"  {token(FOR);}
"fun"  {token(FUN);}
"if"  {token(IF);}
"int"  {token(INT);}
"loop"  {token(LOOP);}
"print"  {token(PRINT);}
"println"  {token(PRINTLN);}
"return"  {token(RETURN);}
"string"  {token(STRING);}
"val"  {token(VAL);}
"var"  {token(VAR);}
"while"  {token(WHILE);}



{real}        {tokenFloat(REAL,yytext);}
{integer}     {tokenInteger(INTEGER, yytext);}

true|false    {tokenString(BOOL, yytext);}

{identifier}  {symtab.insert(yytext); tokenString(ID,yytext);}
{string}      {
		int idx = 0;           
		for(int i=1; i<strlen(yytext)-1; i++){
   			if(yytext[i]=='"' && yytext[i+1] == '"'){
     				i+=1;
   			}
   			string_revise[idx++] = yytext[i];
		}
			string_revise[idx] = '\0';
			tokenString(STR, string_revise);
                        
              }





\n      {
        LIST;
        int idx = 0;
        for(int i=0; i<strlen(buf); i++){
            if(buf[i] == '\n'){   
               string_revise[idx] = '\0';
               printf("%d: %s\n", linenum++, string_revise);
               idx=0;
            }
            else
               string_revise[idx++] = buf[i];
        
        }

        
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }





%%

int main(int argc, char **argv)
{
   yylex();
   printf("--------------------------------SymbolTable Below\n");
   symtab.dump();
   exit(0);
   
}
