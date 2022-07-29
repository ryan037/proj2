#include <map>
#include <string>

#define KEY_MAX 100

using namespace std;

class Node {
   string identifier, scope, type;
   Node* next;
public:
   Node();
   Node(string key, string value, string type);
   void Node_print();

friend class SymbolTable;
}


class SymbolTable
{
   map<int, *Node> symbolTable;
   SymbolTable* last;
   vector<SymbolTable*>* next;  
public:

   void creat();
   string lookup(const string s);
   string insert(const string s);
   int hashf(string id);
   void dump();
   void push();
   void pop();

};
typedef SymbolTable symtab;

