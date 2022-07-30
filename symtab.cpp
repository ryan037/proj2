#include "symtab.h"
#include <iostream>

using namespace std;

Node::Node()
{
	this->next = NULL;
}

Node::Node(const string key, const string value, const string type)
{
	this->identifier = key;
	this->scope = value;
	this->type = type;
	this->next = NULL;
}


void Node::Node_print()
{
	cout << "Identifier's Name: " << this->identifier << "\nType: " << this->type << "\nScope: " << this->scope << endl;
}


string Node::getIdentifier()
{
   return this->identifier;
}
string Node::getType()
{
   return this->type;
}
string Node::getScope()
{
   return this->scope;
}

//-------------------------------------------
SymbolTable::SymbolTable()
{
   this->parent = NULL;
}
SymbolTable* SymbolTable::creat()
{
  return new SymbolTable();
  
}

bool SymbolTable::lookup(const string id)
{
   int index = hashf(id);
   
   map<int, Node*>::iterator it;
   it = symbolTable.find(index);
   if(it != symbolTable.end()){
      Node* n = symbolTable[index];	   
      while(n != NULL){
         if(n->getIdentifier() == id)
            return true;
	 n = n->next;
      }
   }

   return false;
}
bool SymbolTable::insert(const string id, const string scope, const string type)
{
   Node* n = new Node(id, scope, type); 
   int index = hashf(id);
   map<int, Node*>::iterator it = symbolTable.find(index);

   if(it == symbolTable.end()){
      symbolTable[index] = n;
      return true;
   }
   else{
      Node* start = symbolTable[index];
      while(start->next != NULL)
	      start = start->next;
      start->next = n;
      return true;
   }
   return false;
/*   pair<map<index, *Node>::iterator, bool> retPair;
   retPair = this->symbolTable.insert(pair<int, *Node>(index, n));
   if(retPair.second == true){
	cout << "Insert Successfully\n";
        return s;
   }

   else
	cout << "Insert Failure\n";
*/
}

void SymbolTable::dump()
{
   for(const auto& entry : symbolTable){
      cout << "index: " << entry.first << ", value: " << entry.second << endl;
   }
}

int SymbolTable::hashf(const string id)
{
   int asciiSum = 0;
   for(int i=0; i< id.length(); i++){
       asciiSum += id[i];
   }
   return (asciiSum % KEY_MAX);
}

map<int, Node*>  SymbolTable:: getSymbolTable()
{
   return this->symbolTable;
}
SymbolTable* SymbolTable::getParent()
{
   return this->parent;
}
vector<SymbolTable*> SymbolTable::getChilds()
{
   return this->childs;
}
void SymbolTable::setParent(SymbolTable* parent)
{
   this->parent = parent;
}
//-------------------------------------------
void Symtab_list::push()
{ 
   //如果是第一個symbol table
   if(head == NULL){
       head = creat();
       this->head->getChilds().push_back(creat());
       this->setParent(NULL);
       this->cur = this->head->getChilds().front();
   }
   //曾做過的階層
   else if(cur->getChilds().size() == 0){
       this->cur->getChilds().push_back(creat()); 
       this->cur = this->cur->getChilds().back();
   }
   //未做過得階層
   else{
       this->cur->getChilds().push_back(creat());
       this->cur = this->cur->getChilds().front();
   }
   
}
void Symtab_list::pop()
{
   this->cur = this->cur->getParent();
}
