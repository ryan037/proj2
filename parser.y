%{
#define Trace(t)        printf(t)
#include <iostream>
#include "lex.yy.c"
#include "symtab.h"



%}

/*
%union{
	int int_dataType;
	double double_dataType;
	bool bool_dataType;
	string *string_dataType;
	Tuple_Identity* compound_dataType;
	int dataType;
}
*/



/* tokens */
%token ADDEQ SUBEQ MULEQ DIVEQ EQ NEQ LEQ GEQ
%token SEMI SEMICOLON ID ARROW INTEGER REAL STR DD
%token BOOL BREAK CHAR CASE CLASS CONTINUE DECLARE DO ELSE EXIT FLOAT FOR FUN IF IN INT LOOP PRINT PRINTLN READ RETURN STRING VAL VAR VOID WHILE
%type expression
%type data_type

/*
%token <int_dataType> INT_CONST
%token <double_dataType> REAL_CONST
%token <bool_dataType> BOOL_CONST
%token <string_dataType> STR_CONST
%token <string_dataType> ID
*/
/*
%type <compound_dataType> constant_values expression call_function logical_expression relational_expression bool_expression calculation_expression variable_choice_variation constant_choice_variation print_choice
*/

%left OR
%left AND
%left '!'
%left '<' LEQ EQ GEQ '>' NEQ
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS



%%
program:        CLASS ID '{' inside_class '}' 
                {
                	Trace("Reducing to program\n");
                };
                

inside_class:   inside_class function_choice  |
	        inside_class variable_choice  |
	        inside_class constant_choice  |
	        inside_class statement_choice | 
                
        	{
			Trace("Reducing to inside_class\n");
		};
                

function_choice:   FUN ID function_variation '{' inside_function '}'
	           {
			Trace("Reducing to function_dcl\n");
		   };


function_variation: '(' mul_args  ')' ':' data_type | 
		    '('  ')' ':' data_type          |
                    '(' mul_args  ')'               |
                    '(' ')'                  
                    {
			Trace("Reducing to function_variation\n");
		    };


mul_args:   mul_args ',' sgl_args | sgl_args
            {
		Trace("Reducing to mul_args\n");
            };	


sgl_args:   ID '|' data_type
	    {
		Trace("Reducing to sgl_args\n");
            }; 


inside_function:   inside_function variable_choice  |
	           inside_function constant_choice  |
                   inside_function statement_choice |
                 
		   {
		 	Trace("Reducing to inside_function\n");
		   };

variable_choice: VAR ID ':' data_type '=' expression | 
	         VAR ID ':' data_type                |
                 VAR ID '=' expression               |
                 VAR ID                             
	         {
			Trace("Reducing to variable_choice\n");
		 };


constant_choice:   VAL ID ':' data_type '=' expression | 
	           VAL ID '=' expression  
	           {
			Trace("Reducing to constant_choice\n");
	           }; 



statement_choice:    simple_statement | conditional_statement | loop_statement
		     {
                        Trace("Reducing to statement_choice\n");
                     };

simple_statement:    call_function | ID '=' expression | PRINT print_choice |
	             PRINTLN print_choice | RETURN expression | RETURN 
                     {
                        Trace("Reducing to simple_statement\n");
                     };


print_choice:        '(' expression ')' | expression
	             {
		        Trace("Reducing to print_choice\n");
		     };


conditional_statement:  IF '(' bool_expression ')' block_or_simple_conditional
		        else_choice
		        {
                            Trace("Reducing to conditional_statement\n");		               };


else_choice:         ELSE block_or_simple_conditional | 
	             {
			Trace("Reducing to conditional_statement\n");
		     };


block_or_simple_conditional: '{'inside_block_conditional'}' | statement_choice
                             {
                           Trace("Reducing to block_or_simple_condidtional\n");
                             };


inside_block_conditional:    inside_block_conditional statement_choice | 
			     {
                             Trace("Reducing to inside_block_conditional\n");
                             };

loop_statement:      WHILE '(' bool_expression  ')' block_or_simple_loop |
	             FOR '(' ID IN INTEGER DD INTEGER ')' block_or_simple_loop                     {
			Trace("Reducing to loop_statement\n");
		     };


block_or_simple_loop: '{' inside_block_loop  '}' | statement_choice |
		       BREAK | CONTINUE
                      {
		         	Trace("Reducing to block_or_simple_loop\n");
                      };


inside_block_loop:  inside_block_loop statement_choice |
	       	    inside_block_loop BREAK            | 
	       	    inside_block_loop CONTINUE         |
                    {Trace("Reducing to inside_block_loop\n");};


call_function:      ID '(' check_call_function_argument ')'
	            {Trace("Reduing to call_function");};


check_call_function_argument: comma_seperated_arguments | ;


comma_seperated_arguments: comma_seperated_arguments ',' comma_seperated_arguments | call_function_parameter ;


call_function_parameter: expression;


expression: call_function | ID | '(' expression  ')' | calculation_expression
	  | bool_expression | constant_values
          {Trace("Reducing to expression\n");};

calculation_expression: '-' expression %prec UMINUS | expression '*' expression                      | expression '/' expression | expression '%' expression                        | expression '+' expression | expression '-' expression                      {Trace("Reducing to calculation\n");};


bool_expression: relational_expression | logical_expression;


relational_expression:  expression '<' expression | expression LEQ expression | expression '>' expression | expression GEQ expression | expression EQ expression | expression NEQ expression;


logical_expression:  '!' expression | expression AND expression 
		  |  expression OR;


constant_values:         INTEGER | REAL | BOOL | STR;


data_type:        INT|FLOAT|BOOL|STRING|VOID;



                
%%
#include "lex.yy.c"

yyerror(msg)
char *msg;
{
    fprintf(stderr, "%s\n", msg);
}

main()
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
}

