
#include <iostream>
#include <string>
#include "gen.h"
#include "symtab.h"

using namespace std;

Generator::Generator()
{}
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
   cout << "method public static " << data->getRet_type() << " " << data->getIdentifier() << '(';
   if(data->func_para.size() == 1){
      cout << data->func_para[0] << ')' << endl;
   }
   else if(data->func_para.size() > 1){
      int i=0;
      for(i=0; i<data->func_para.size()-1; i++){
         cout << data->func_para[i] << ", ";
      }
      cout << data->func_para[i] << ')' << endl;
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
   cout << "ireturn" << endl << "}" << endl;
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
