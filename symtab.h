#ifndef SYMTAB_H
#define SYMTAB_H


#include <map>
#include <string>
#include <vector>
#include "values.h"

#define KEY_MAX 100

using namespace std;

class Tuple_Identity
{
public:
   string id,scope;
   ValueType type;
};


class Node {
   string identifier, scope;
   ValueType type;
   Node* next;
public:
   Node();
   Node(const string id, const string scope, const ValueType type);
   void Node_print();
   string getIdentifier();
   ValueType getType();
   string getScope();
   Node* getNext();
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
   bool lookup(const string id);
   bool insert(const string id, const string scope, ValueType type);
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
   bool lookup_token(const string id);
   bool insert_token(const string id, const string scope, ValueType type);
   void dump_all();
};

#endif
