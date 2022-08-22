#include <stdio.h>
#include <iostream>
#include <string>
#include "symtab.h"
using namespace std;

class Generator{
public:
   Generator();
   FILE* fp;
   void beginProgram(string s);
   void closeProgram();
   void beginFun(Node* data);
   void returnValue(ValueType v);
   void globalVarValue(Node* data);
   void globalVar(Node* data);
   void localVarValue(Node* data);
   void identifier(string s);
   void assign(string s);
  
   void printstart();
   void printoutput();

};
