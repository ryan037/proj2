#include <map>
#include <string>
#include <vector>
#define KEY_MAX 100

using namespace std;

class Node {
   string identifier, scope, type;
   Node* next;
public:
   Node();
   Node(const string key, const string value, const  string type);
   void Node_print();
   string getIdentifier();
   string getType();
   string getScope();
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
//---------------------------------------------- 
   SymbolTable* creat();
   bool lookup(const string s);
   bool insert(const string id, const string scope, const string type);
   int hashf(const string id);
   void dump();
   void push();
   void pop();
};

class Symtab_list : public SymbolTable
{
   SymbolTable* head;
   SymbolTable* cur;
   

public:
   void pop();
   void push();
   bool lookup_token(const string s);
   bool insert_token(const string s);
   void dump_all_symtab();
};

