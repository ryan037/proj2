/*
%{..}%裡的東西只會include到y.tab.c, y.tab.h則沒有,所以union裡無法使用string
*/
%{
#define Trace(t)        printf(t)
#include <cstdio>
#include <iostream>
#include <typeinfo>
#include <string.h>
#include "symtab.h"
#include "gen.h"

extern FILE *yyin;
extern char *yytext;

extern int yylex(void);
static void  yyerror(const char *msg);
Symtab_list symtab_list;
Generator gen;

int if_else = 0;
int ret = 0;
bool global_flag = true;
bool operation_flag = false;
int count = 0;
int L_count = 0;
string class_name;
vector<ValueType> vt;
vector<ValueType> vt2;
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
%type<dataType> function_variation

%token <int_dataType> INT_CONST
%token <double_dataType> REAL_CONST
%token <bool_dataType> BOOL_CONST
%token <string_dataType> STR_CONST
%token <string_dataType> ID


%type <compound_dataType> constant_values expression call_function logical_expression relational_expression bool_expression calculation_expression variable_choice constant_choice print_choice



	          
%left '|'
%left '&'
%left '!'
%left '<' LEQ EQ GEQ '>' NEQ
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS



%%
program:        CLASS ID
                { 
                   class_name = $2;  
                   gen.beginProgram($2);     				   
                   Node *data = new Node($2, "global", type_class);
                   symtab_list.push();
                   symtab_list.insert_token(data);
                   symtab_list.push();
                   Node* n = symtab_list.lookup_token($2);
                     
                }
               '{' inside_class '}' 
                {
                   //Trace("Reducing to program\n");
                   symtab_list.pop();
                   symtab_list.pop();
                   gen.closeProgram();
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
                         
			//Trace("Reducing to inside_class\n");
		};
                

function_choice:   FUN ID
	           {
                        count = 0;
                        global_flag = false;
                        Node *data = new Node($2, "local", type_function);
                        data->setFunc(true);
                        symtab_list.insert_token(data);
                        symtab_list.push();
                   }
	           function_variation
                   {
                        Node *data = symtab_list.lookup_token($2);
                        for(int i=0; i<vt.size(); i++){
                           data->func_para.push_back(vt.at(i));
                        }
                        data->setRet_type($4);
                        vt.clear();
                        gen.beginFun(data);
                   }
                   '{' inside_function '}'
	           {    
                        Node *data = symtab_list.lookup_token($2);
                        if(ret == 1){   
                           data->setRet(true);
                        }
			//Trace("Reducing to function\n");
                        symtab_list.pop();
                        gen.returnValue(data->getRet_type());
                        count = 0; // 離開函式重設count
		   };


function_variation: '(' mul_args  ')' ':' data_type 
		    {
                         $$ = $5;
                    } 
                  | '('  ')' ':' data_type    
                    {
			 $$ = $4;
		    }
                  | '(' mul_args  ')' 
		    {
			 $$ = type_void;
		    }     
	          | '(' ')'                  
                    {
                         $$ = type_void;
			 //Trace("Reducing to function_variation\n");
		    };


mul_args:   mul_args ',' sgl_args | sgl_args
            {
		//Trace("Reducing to mul_args\n");
            };	


sgl_args:   ID ':' data_type
	    {
                Node *data = new Node($1, "function parameter", $3);
                data->setNum(count++);
                symtab_list.insert_token(data);
                vt.push_back(data->getType());
		//Trace("Reducing to sgl_args\n");
            }; 


inside_function:   inside_function variable_choice  |
	           inside_function constant_choice  |
                   inside_function statement_choice |
                 
		   {
		 	//Trace("Reducing to inside_function\n");
		   };

variable_choice: VAR ID ':' data_type '='   
	         {
                     Node *data = new Node($2, "local", $4);
                     symtab_list.insert_token(data);
                 } 
                 expression
                 {
                    Node* data = symtab_list.lookup_token($2);
                     if($7->getConstant()){
                        data->setValue($7->getValue());
                     }
                     if(global_flag){
                        gen.globalVarValue(data);
                        data->setScope("global");
                     }else{
                        data->setNum(count++);
                        gen.localVarValue(data);
                     }
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
                     if(global_flag){
                        gen.globalVar(data);
                        data->setScope("global");
                     }else{
                        data->setNum(count++);
                     }
                 }
	         | VAR ID '='
                 {
                     Node *data = new Node($2, "local", type_void);
                     symtab_list.insert_token(data);
                 }
                 expression
                 {
                    Node* data = symtab_list.lookup_token($2);
                     if($5->getConstant()){
                        data->setValue($5->getValue());
                     }
                     if(global_flag){
                        gen.globalVarValue(data);
                        data->setScope("global");
                     }else{
                        data->setNum(count++);
                        gen.localVarValue(data);
                     }
                 }
                 
		 | VAR ID                             
	         {
                     Node *data = new Node($2, "local", type_void);
                     data->setNum(count++);
                     symtab_list.insert_token(data);
		     //Trace("Reducing to variable_choice\n");
		 };


constant_choice:   VAL ID ':' data_type '=' expression
                   {
                     Node *data = new Node($2, "local", $4);
                     data->setVal(true);
                     data->setValue($6->getValue());
                     symtab_list.insert_token(data);
                   }
                 | VAL ID '=' expression
                   {
                     Node *data = new Node($2, "local", $4->getType());
                     data->setVal(true);
                     data->setValue($4->getValue());
                     symtab_list.insert_token(data);
	             //Trace("Reducing to constant_choice\n");
                   }; 
                   


statement_choice:    simple_statement | conditional_statement | loop_statement
		     
		     {
                        //Trace("Reducing to statement_choice\n");
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
                         if(data->getVal()){
                            yyerror("Val can't assign new value");
                         }
                     } 
                     '=' expression
                     {   
                         //if(strcmp(typeid($4).name(), "P4Node") == 0){
                         if($4->getType() == type_function  &&  !$4->getRet()){
                               yyerror("Function no return");
                         }
                         //}
                         if($4->getType() != type_function){
                            gen.expression_handle($4, class_name);
                         }
                         //------------------------------------------------
                         string output = "";
                         Node* data = symtab_list.lookup_token($1);
                         if(data->getScope() == "global"){
                                output += "putstatic ";
                                if(data->getType() == type_integer) //int
				{
   				    output += "int ";
				}else if(data->getType() == type_bool){ //bool
                                    output += "bool ";
                                }
                                    output += class_name;
                                    output += ".";
                                    output += data->getIdentifier();
                                    output += "\n";
                         }else if($4->getScope() == "local"){ //local
                                output += "istore ";
                                output += to_string(data->getNum());
                                output += "\n";
                         }
                         gen.assign(output);
                     }

                   |  ID '['ID']'
                   {
                        Node* n = symtab_list.lookup_token($3);
                        if(n->getType() != type_integer){
                           yyerror("Array argument error");        
                        }
                   }
                   | PRINT
                     {
                        gen.printStart();
                     }  
                     print_choice
                     {
                        gen.printOutput($3->getType());
                     } 
	           | PRINTLN
                     {
                        gen.printStart();
                     }
                     print_choice
                     {
                        gen.printlnOutput($3->getType());
                     }
                   | RETURN expression
                     {
                         ret = 1;
                     }
                   | RETURN 
                     {
                        //Trace("Reducing to simple_statement\n");
                     };


print_choice:        '(' expression ')'
                     {
                         if(!operation_flag)
                           gen.expression_handle($2,class_name);
                         $$ = $2;
                         operation_flag = false;

                     }	   
                     | expression
	             {		        
                         if(!operation_flag)
                           gen.expression_handle($1, class_name);
                         operation_flag = false;
                         $$ = $1;
                         //Trace("Reducing to print_choice\n");
                     };


conditional_statement:  IF '(' bool_expression ')'
		        {
                           gen.beginif(L_count);
                           if_else = 1;
                           symtab_list.push();
                           L_count+=2;
                        }
                        block_or_simple_conditional
                        {
                           symtab_list.pop();
                        }
		        else_choice
		        {
                           /* Trace("Reducing to conditional_statement\n");*/		               };


else_choice:         ELSE
	             {
                         gen.beginelse(L_count);
                         if_else -=1;
                         if(if_else < 0){
                            yyerror("if else syntax error");
                         }
                         symtab_list.push();
                         L_count+=1;
                     }
	             block_or_simple_conditional
                     {
                         symtab_list.pop();
                         gen.closeif(L_count);
                     }
                     | 
	             {
                         gen.closeif(L_count);
			//Trace("Reducing to conditional_statement\n");
		     };


block_or_simple_conditional: '{' inside_block_conditional '}' | statement_choice
                             {
                           //Trace("Reducing to block_or_simple_condidtional\n");
                             };


inside_block_conditional:    inside_block_conditional statement_choice |                                    inside_block_conditional constant_choice  |		                           inside_block_conditional variable_choice  | 
			     {
                             //Trace("Reducing to inside_block_conditional\n");
                             };

loop_statement:      WHILE
	             {
                       gen.beginWhile();
                       symtab_list.push();
                     } 
                     '(' bool_expression  ')'
	             {
                       gen.insideWhile();
                     }
                     block_or_simple_loop 
                     {
                       gen.closeWhile();
                       symtab_list.pop();
                     }
                   | FOR'(' ID IN INT_CONST 
                     {
                         Node *data = new Node($3, "function argument", type_integer);
                         symtab_list.insert_token(data);
                         symtab_list.push();
                         gen.beginFOr();
                     }
                     DD INT_CONST ')'
                     {
                         gen.insdieFor();
                     }
                     block_or_simple_loop                    
                     {
                         gen.closeFor();
                         symtab_list.pop();
			 //Trace("Reducing to loop_statement\n");
		     };


block_or_simple_loop: '{' inside_block_loop  '}' | statement_choice |
		       BREAK | CONTINUE
                      {
		         //	Trace("Reducing to block_or_simple_loop\n");
                      };


inside_block_loop:  inside_block_loop statement_choice |
                    inside_block_loop variable_choice  |
                    inside_block_loop constant_choice  |
	       	    inside_block_loop BREAK            | 
	       	    inside_block_loop CONTINUE         |
                    {/*Trace("Reducing to inside_block_loop\n");*/};


call_function:      ID '(' check_call_function_argument ')'
	            {
                        Node* data = symtab_list.lookup_token($1);
                        for(int i=0; i<data->func_para.size();i++){
			   if(data->func_para.at(i) != vt2.at(i)){
                              vt2.clear();
                              yyerror("function argument error");
                           }
                        }
                        
                        vt2.clear();

                        if(symtab_list.lookup_token($1) == NULL){
                           yyerror("Function not found"); 
                        }
                        gen.callFun(class_name, data);
                        $$ = symtab_list.lookup_token($1);
                        //Trace("Reduing to call_function");
                    };


check_call_function_argument: comma_seperated_arguments | ;


comma_seperated_arguments: comma_seperated_arguments ',' comma_seperated_arguments | call_function_parameter ;


call_function_parameter: expression
		         {
                           vt2.push_back($1->getType());
                           gen.expression_handle($1, class_name);
                         };


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
	  | constant_values | ID '[' INT_CONST ']'
          {/*Trace("Reducing to expression\n"); */};

calculation_expression: '-' expression %prec UMINUS
		        {
                           operation_flag = true;
                           gen.expression_handle($2, class_name);
                           gen.negativeIint("ineg\n");
                           Node* data = $2;
                           $2->setValue($2->getValue() * (-1)); 
                           $$ = data;
                        }
                        | expression '*' expression
                        {
                        }   
		        | expression '/' expression
                        {
                        }
                        | expression '%' expression       
                        {
                        }
          		| expression '+' expression
		        {
                            if($1->getType() == type_bool || $3->getType() == type_bool){
                                yyerror("bool data type can't calculate");
                            } 
                            operation_flag = true;
                            gen.expression_handle($1, class_name);
                            gen.expression_handle($3, class_name);
                            gen.operation("iadd\n");
                            $1->setValue($1->getValue() + $3->getValue());
                            $$ = $1;
                        }
		        | expression '-' expression        
         	        {/*Trace("Reducing to calculation\n");*/};


bool_expression: relational_expression | logical_expression;


relational_expression:  expression '<' expression 
		     {
                         gen.expression_handle($1, class_name);
                         gen.expression_handle($3, class_name);
                         gen.relationalOperator("isub\niflt");            
                     }
		     | expression LEQ expression 
                     | expression '>' expression
                     {
                         gen.expression_handle($1, class_name);
                         gen.expression_handle($3, class_name);
                         gen.relationalOperator("isub\nifgt");            
                     }
                     | expression GEQ expression 
                     | expression EQ expression 
                     | expression NEQ expression;


logical_expression:  expression
                     {
                        if($1->getType() != type_bool){yyerror("Expresstion isn't bool data type");}
                     }		 
                     |'!' expression 
                     {
                        if($2->getType() != type_bool){yyerror("Expresstion isn't bool data type");}

                     }
                     | expression '&' expression 
		     | expression '|' expression
                     | relational_expression '|' relational_expression
                     | relational_expression '&' relational_expression;


constant_values:         INT_CONST
	                 {
                            Node* data = new Node(); 
                            data->setConstant(true);
                            data->setValue($1);
                            data->setType(type_integer);
                            $$ = data;
                         }
                       | REAL_CONST 
                       | BOOL_CONST
                         {
                            Node* data = new Node(); 
                            data->setConstant(true);
                            if($1 == true)
                               data->setValue(1);
                            else
                               data->setValue(0);
                            data->setType(type_bool);
                            $$ = data;
                         }
                       | STR_CONST
                         {
                            Node* data = new Node(); 
                            data->setConstant(true);
                            data->setValue_string($1);
                            data->setType(type_string);
                            $$ = data;
                         };
	                


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
   // gen.fp = fopen("test.txt","w");
    /* perform parsing */
    if (yyparse() == 1){                
        yyerror("Parsing error !");
    }
    symtab_list.dump_all();
    //fclose(gen.fp);


}
