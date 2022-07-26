%{
#define Trace(t)        printf(t)
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
%token SEMI SEMICOLON ID ARROW INTEGER REAL STR
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

%%
program:        CLASS ID '{' inside_class '}' 
                {
                	Trace("Reducing to program\n");
                };
                

inside_class:   inside_class funtion_choice   |
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

variable_choice: VAR ID | variable_choice_variation
	         {
			Trace("Reducing to variable_choice\n");
		 };


variable_choice_variation:  ':' data_type '=' expression |
			    ':' data_type                |
                            '=' expression               |
                            
                            {
				Trace("Reducing to variable_choice_variation\n");
			    };


 







semi:           SEMICOLON
                {
                Trace("Reducing to semi\n");
                }
                ;
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

