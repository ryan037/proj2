/*
%{..}%裡的東西只會include到y.tab.c, y.tab.h則沒有,所以union裡無法使用string
*/
%{
#define Trace(t)        printf(t)
#include <cstdio>
#include <iostream>
#include "symtab.h"

extern FILE *yyin;
extern char *yytext;

extern int yylex(void);
static void  yyerror(const char *msg);
Symtab_list symtab_list;


int if_else = 0;
int ret = 0;
%}

%code requires{
   #include<string>
   #include "symtab.h"
}

%union{
	int int_dataType;
	double double_dataType;
	bool bool_dataType;
	char* string_dataType;
        Node* compound_dataType;
        ValueType dataType;
}



/* tokens */
%token ADDEQ SUBEQ MULEQ DIVEQ EQ NEQ LEQ GEQ
%token SEMI SEMICOLON  ARROW DD
%token BOOL BREAK CHAR CASE CLASS CONTINUE DO ELSE EXIT FLOAT FOR FUN IF IN INT LOOP PRINT PRINTLN READ RETURN STRING VAL VAR VOID WHILE
%type expression
%type<dataType> data_type


%token <int_dataType> INT_CONST
%token <double_dataType> REAL_CONST
%token <bool_dataType> BOOL_CONST
%token <string_dataType> STR_CONST
%token <string_dataType> ID


%type <compound_dataType> constant_values expression call_function logical_expression relational_expression bool_expression calculation_expression variable_choice constant_choice print_choice



%left OR
%left AND
%left '!'
%left '<' LEQ EQ GEQ '>' NEQ
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS



%%
program:        CLASS ID
                {                                      
                   Node *data = new Node($2, "global", type_class);
                   symtab_list.push();
                   symtab_list.insert_token(data);
                   symtab_list.push();
                   Node* n = symtab_list.lookup_token($2);
                     
                }
               '{' inside_class '}' 
                {
                   Trace("Reducing to program\n");
                   symtab_list.pop();
                   symtab_list.pop();
                };
                

inside_class:   inside_class function_choice
	        {
                } 
              | inside_class variable_choice
                {
                }
              |	inside_class constant_choice 
                {
                }
              |	inside_class statement_choice
                {
                } 
              | 
        	{
                         
			Trace("Reducing to inside_class\n");
		};
                

function_choice:   FUN ID
	           {
                        Node *data = new Node($2, "local", type_function);
                        symtab_list.insert_token(data);
			
                   }
	           function_variation
                   {
                        symtab_list.push();
                   }
                   '{' inside_function '}'
	           {    
                        if(ret == 1){   
                           Node *data = symtab_list.lookup_token($2);
                           data->setRet(true);
                        }
			Trace("Reducing to function\n");
                        symtab_list.pop();
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


sgl_args:   ID ':' data_type
	    {
                Node *data = new Node($1, "function parameter", $3);
                symtab_list.insert_token(data);
		Trace("Reducing to sgl_args\n");
            }; 


inside_function:   inside_function variable_choice  |
	           inside_function constant_choice  |
                   inside_function statement_choice |
                 
		   {
		 	Trace("Reducing to inside_function\n");
		   };

variable_choice: VAR ID ':' data_type '='   
	         {
                     Node *data = new Node($2, "local", $4);
                     symtab_list.insert_token(data);
                 } 
                 expression
                 {

                 }
                 | VAR ID ':' data_type  '['INT_CONST']'
                 {
                     Node *data = new Node($2, "local", $4);
                     symtab_list.insert_token(data);

                 }
                 | VAR ID ':' data_type '['ID']'
                 {
                    Node* n = symtab_list.lookup_token($6);
                    if(n->getType() != type_integer){
                        yyerror("Array argument error");        
                    }
                    Node *data = new Node($2, "local", $4);
                    symtab_list.insert_token(data);
                 }

                 | VAR ID ':' data_type          
                 {
                     Node *data = new Node($2, "local", $4);
                     symtab_list.insert_token(data);
                 }
	         | VAR ID '='
                 {
                     Node *data = new Node($2, "local", type_void);
                     symtab_list.insert_token(data);
                 }
                 expression
                 {

                 }
		 | VAR ID                             
	         {
                     Node *data = new Node($2, "local", type_void);
                     symtab_list.insert_token(data);
		     Trace("Reducing to variable_choice\n");
		 };


constant_choice:   VAL ID ':' data_type '=' 
	           {
                     Node *data = new Node($2, "local", $4);
                     data->setConstant(true);
                     symtab_list.insert_token(data);
                   }
                   expression
                   {

                   }
                 | VAL ID '=' 
	           {
                     Node *data = new Node($2, "local", type_void);
                     data->setConstant(true);
                     symtab_list.insert_token(data);
	             Trace("Reducing to constant_choice\n");
	           }
                   expression
                   {

                   }; 
                    


statement_choice:    simple_statement | conditional_statement | loop_statement
		     
		     {
                        Trace("Reducing to statement_choice\n");
                     };

simple_statement:    call_function 
		   | ID
                     {
                         Node* data = symtab_list.lookup_token($1);
                         if(data == NULL){yyerror("Identifier Not Fonud");
                         }
                         if(data->getType() == type_class || data->getType() == type_function){
                            yyerror("Identifier is a class or function type");
                         }
                         if(data->getConstant()){
                            yyerror("Val can't assign new value");
                         }
                     } 
                     '=' expression
                     {
                         if($4->getType() == type_function  &&  !$4->getRet()){
                            yyerror("Function no return");
                         }
                     }
                   | PRINT print_choice 
	           | PRINTLN print_choice
                   | RETURN expression
                     {
                         ret = 1;
                     }
                   | RETURN 
                     {
                        Trace("Reducing to simple_statement\n");
                     };


print_choice:        '(' expression ')' | expression
	             {
		        Trace("Reducing to print_choice\n");
		     };


conditional_statement:  IF '(' bool_expression ')'
		        {
                           if_else = 1;
                           cout << "error\n";
                           symtab_list.push();
                        }
                        block_or_simple_conditional
                        {
                           symtab_list.pop();
                        }
		        else_choice
		        {
                            Trace("Reducing to conditional_statement\n");		               };


else_choice:         ELSE
	             {
                         if_else -=1;
                         if(if_else < 0){
                            yyerror("if else syntax error");
                         }
                         symtab_list.push();
                     }
	             block_or_simple_conditional
                     {
                         symtab_list.pop();
                     }
                     | 
	             {
			Trace("Reducing to conditional_statement\n");
		     };


block_or_simple_conditional: '{' inside_block_conditional '}' | statement_choice
                             {
                           Trace("Reducing to block_or_simple_condidtional\n");
                             };


inside_block_conditional:    inside_block_conditional statement_choice |                                    inside_block_conditional constant_choice  |		                           inside_block_conditional variable_choice  | 
			     {
                             Trace("Reducing to inside_block_conditional\n");
                             };

loop_statement:      WHILE '(' bool_expression  ')'
	             {
                       symtab_list.push();
                     }
                     block_or_simple_loop 
                     {
                       symtab_list.pop();
                     }
                   | FOR '(' ID IN INT_CONST DD INT_CONST ')'
                     {
                         Node *data = new Node($3, "function argument", type_integer);
                         symtab_list.insert_token(data);
                         symtab_list.push();
                     }
                     block_or_simple_loop                    
                     {
                        symtab_list.pop();
			Trace("Reducing to loop_statement\n");
		     };


block_or_simple_loop: '{' inside_block_loop  '}' | statement_choice |
		       BREAK | CONTINUE
                      {
		         	Trace("Reducing to block_or_simple_loop\n");
                      };


inside_block_loop:  inside_block_loop statement_choice |
                    inside_block_loop variable_choice  |
                    inside_block_loop constant_choice  |
	       	    inside_block_loop BREAK            | 
	       	    inside_block_loop CONTINUE         |
                    {Trace("Reducing to inside_block_loop\n");};


call_function:      ID '(' check_call_function_argument ')'
	            {
                        
                        if(symtab_list.lookup_token($1) == NULL){
                           yyerror("Function not found"); 
                        }
                        $$ = symtab_list.lookup_token($1);
                        Trace("Reduing to call_function");
                    };


check_call_function_argument: comma_seperated_arguments | ;


comma_seperated_arguments: comma_seperated_arguments ',' comma_seperated_arguments | call_function_parameter ;


call_function_parameter: expression;


expression: call_function
	    {
                $$ = $1;
            }
	  | ID
            {
                Node* data = symtab_list.lookup_token($1);
                if(data == NULL){ yyerror("Identifier Not Fonud");}	
                if(data->getType() == type_class || data->getType() == type_function){
                   yyerror("Identifier is a class or function type");
                }
                $$ = data;      
            }
	  | '(' expression  ')' | calculation_expression
	  | bool_expression | constant_values | ID '[' INT_CONST ']'
          {Trace("Reducing to expression\n");};

calculation_expression: '-' expression %prec UMINUS | expression '*' expression                      | expression '/' expression | expression '%' expression                        | expression '+' expression
		        {
                            if($1->getType() !=  $3->getType()){
                               yyerror("Both expression has different data type");
                            }  
                        }
		      | expression '-' expression                      {Trace("Reducing to calculation\n");};


bool_expression: relational_expression | logical_expression;


relational_expression:  expression '<' expression | expression LEQ expression | expression '>' expression | expression GEQ expression | expression EQ expression | expression NEQ expression;


logical_expression:  expression
                     {
                        if($1->getType() != type_bool){yyerror("Expresstion isn't bool data type");}
                     }		 
                     |'!' expression 
                     {
                        if($2->getType() != type_bool){yyerror("Expresstion isn't bool data type");}

                     }
                     | expression AND expression 
		     |  expression OR expression;


constant_values:         INT_CONST | REAL_CONST | BOOL_CONST | STR_CONST;
	                


data_type:  INT    {$$ = type_integer;}
         |  FLOAT  {$$ = type_real;}
         |  BOOL   {$$ = type_bool;}
         |  STRING {$$ = type_string;}
         |  VOID   {$$ = type_void;};



                
%%

void yyerror(const char *msg)
{
   printf("[ERROR]: %s\n", msg);
   exit(0);
}

int main(int argc, char **argv)
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /* perform parsing */
    if (yyparse() == 1){                
        yyerror("Parsing error !");
    }
    symtab_list.dump_all();


}
