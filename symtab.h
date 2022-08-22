#ifndef SYMTAB_H
#define SYMTAB_H


#include <map>
#include <string>
#include <vector>
#include "values.h"

#define KEY_MAX 100

using namespace std;

class Node {
   string identifier, scope;
   ValueType type;
   ValueType ret_type;
   Node* next;
   bool val;
   bool ret;
   bool constant;
   bool func;
   int value;
   int num;
public:
   vector<ValueType> func_para;
   Node();
   Node(const string id, const string scope, const ValueType type);
   void Node_print();
   string getIdentifier();
   ValueType getType();
   ValueType getRet_type();
   string getScope();
   Node* getNext();
   
   void setScope(string s);
   void setType(ValueType v);
   void setVal(bool b);
   void setRet(bool b);
   void setConstant(bool b);
   void setValue(int v);
   void setFunc(bool b);
   void setRet_type(ValueType v);
   void setNum(int n);

   bool getVal();
   bool getRet();
   bool getConstant();
   int  getValue();
   bool getFunc();
   int getNum();
   friend class SymbolTable;
   
};


class SymbolTable
{
   map<int, Node*> symbolTable;
   SymbolTable* parent;
   vector<SymbolTable*> childs;  
public:
 
   SymbolTable();
//---------------------------------------------- 
   map<int, Node*>      getSymbolTable();
   SymbolTable*         getParent();
   vector<SymbolTable*> getChilds(); 
   void setParent(SymbolTable* parent);
   void addChilds();
//---------------------------------------------- 
   SymbolTable* creat();
   Node* lookup(const string id);
   bool insert(Node* n);
   int hashf(const string id);
   void dump();
   void dump(SymbolTable* s);
};

class Symtab_list : public SymbolTable
{
   SymbolTable* head;
   SymbolTable* cur;
   
public:
   Symtab_list();
   void pop();
   void push();
   Node* lookup_token(const string id);
   bool insert_token(Node* ti);
   void dump_all();
};

#endif
