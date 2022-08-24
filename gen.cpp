
#include <iostream>
#include <string>
#include "gen.h"
#include "symtab.h"

using namespace std;

Generator::Generator()
{}
void Generator::expression_handle(Node* data, string class_name)
{
   string output = "";
                       
   if(data->getConstant() || data->getVal()){ // constant Val
      if(data->getType() == type_integer){
         output += "sipush ";
         output += to_string(data->getValue());
      }                        
      else if(data->getType() == type_bool){
         if(data->getValue() == 1)
            output += "iconst_1";      
         else
            output += "iconst_0";      
      }else if(data->getType() == type_string){
         output +="ldc ";
         output += data->getValue_string();
      }
      output += "\n";
   }                        
   else{                  //variable
      if(data->getScope() == "global"){ //global
         output += "getstatic ";                                                        if(data->getType() == type_integer) //
	 {
   	    output += "int ";
	 }else if(data->getType() == type_bool){ //bool
            output += "bool ";
         }
            output += class_name;
            output += ".";
            output += data->getIdentifier();
         }else if(data->getScope() == "local"){ //local
            output += "iload ";
            output += to_string(data->getNum());
         }
         output += "\n";       
    }
    if(output != "")
         this->identifier(output);
}

void Generator::beginProgram(string s)
{ 
   //fscanf(this->fp,"class %s", s.c_str());
   cout << "class " << s << endl;
   cout << "{" << endl;
}
void Generator::closeProgram()
{
   cout << '}' << endl;
}

void Generator::beginFun(Node* data)
{
   cout << "method public static " << EnumToString(data->getRet_type()) << " " << data->getIdentifier() << '(';
   if(data->getIdentifier() == "main"){
     cout << "java.lang.Stringp[])\n";
   }
   else if(data->func_para.size() == 1){
      cout << EnumToString(data->func_para[0]) << ')' << endl;
   }
   else if(data->func_para.size() > 1){
      int i=0;
      for(i=0; i<data->func_para.size()-1; i++){
         cout << EnumToString(data->func_para[i]) << ", ";
      }
      cout << EnumToString(data->func_para[i]) << ')' << endl;
   }else{
      cout << ")" << endl; 
   }
   //-----------------------------------------------------
   cout << "max_stack 15" << endl << "max_locals 15" << endl << "{" << endl;
   //-----------------------------------------------------
   
   for(int i=0; i<data->func_para.size(); i++){
          cout << "iload " << i << endl;
   }
}
void Generator::returnValue(ValueType v)
{
   if(v == type_integer)
      cout << "ireturn" << endl << "}" << endl;
   else if(v == type_void)
      cout << "return" << endl << "}" << endl;
}
void Generator::globalVarValue(Node* data)
{
   cout << "field static " << "int "  << data->getIdentifier() << " = "  << data->getValue() << endl;
}
void Generator::globalVar(Node* data)
{
   cout << "field static " <<  "int " << data->getIdentifier() << endl;
}
void Generator::localVarValue(Node* data)
{
   cout << "sipush " << data->getValue() << endl;
   cout << "istore " << data->getNum() << endl;
}
void Generator::identifier(string s)
{
   cout << s;
}
void Generator::assign(string s)
{
   cout << s;
}
void Generator::printStart()
{
   cout << "getstatic java.io.PrintStream java.lang.System.out\n";
}
void Generator::printOutput(ValueType v)
{
   if(v == type_string){
    cout << "invokevirtual void java.io.PrintStream.print(java.lang.String)\n";
   }
   if(v == type_integer){
    cout << "invokevirtual void java.io.PrintStream.print(int)\n";
   }
   if(v == type_bool){
    cout << "invokevirtual void java.io.PrintStream.print(boolean)\n";
   }
}
void Generator::printlnOutput(ValueType v)
{
   if(v == type_string){
    cout << "invokevirtual void java.io.PrintStream.println(java.lang.String)\n";
   }
   if(v == type_integer){
    cout << "invokevirtual void java.io.PrintStream.println(int)\n";
   }
   if(v == type_bool){
    cout << "invokevirtual void java.io.PrintStream.println(boolean)\n";
   }
}
void Generator::beginif(int i)
{
  cout << " L" << i << "\niconst_0\n" << "goto L" << i+1 << "\nL" << i;
  cout << ":\niconst_1\n" << "L" << i+1 << ":\nifeq L" << i+2 << endl;  
}
void Generator::beginelse(int i)
{
   cout << "goto L" << i+1 << "\nL" << i << ":\n";
}

void Generator::closeif(int i)
{
   cout << "L" << i << ":\n";
}
void Generator::relationalOperator(string s)
{
   cout << s;
}
void Generator::negativeIint(string s)
{
   cout << s;
}
void Generator::callFun(string s, Node* data)
{
   cout << "invokestatic " << EnumToString(data->getRet_type()) << " " << s << "." << data->getIdentifier() << "(";

   if(data->func_para.size() == 1){
      cout << EnumToString(data->func_para[0]) << ')' << endl;
   }
   else if(data->func_para.size() > 1){
      int i=0;
      for(i=0; i<data->func_para.size()-1; i++){
         cout << EnumToString(data->func_para[i]) << ", ";
      }
      cout <<EnumToString(data->func_para[i]) << ')' << endl;
   }else{
      cout << ")" << endl; 
   }
}
void Generator::operation(string s)
{
   cout << s;
}
