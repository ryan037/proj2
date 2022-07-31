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
   Node(const string id, const string scope, const  string type);
   void Node_print();
   string getIdentifier();
   string getType();
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
   bool insert(const string id, const string scope, const string type);
   int hashf(const string id);
   void dump();
   void dump(SymbolTable* s);
   void push();
   void pop();
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
   bool insert_token(const string id, const string scope, const string type);
   void dump_all();
};
