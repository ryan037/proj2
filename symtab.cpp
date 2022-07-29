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
	cout << "Identifier's Name: " << this->identifer << "\nType: " << this->type << "\nScope: " << this->scope << endl;
}



SymbolTable SymbolTable::creat()
{
  return new SymbolTable();
  
}

bool SymbolTable::lookup(const string id)
{
   int index = hashf(id);
   
   map<index, *Node>::iterator it;
   it = symbolTable.find(id);
   if(it != symbolTable.end()){
      *Node n = symbolTable[index];	   
      while(n != NULL){
         if(n->identifer == id)
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
   map<int, *Node>::iterator it = symbolTable.find(index);

   if(it == symbolTable.end()){
      symbleTable[index] = n;
      return true;
   }
   else{
      Node* start = symbolTable[index];
      while(start->next != NULL)
	      start = start->next;
      start->next = p;
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
   for(int i=0; i< id.length; i++){
       asciiSum += id[i];
   }
   return (asciiSum % KEY_MAX);
}

void SymbolTable::push()
{
   this->jkghjgf;
   if(this->last == NULL && this->next == NULL){
       this->next = new vector<SymbolTable*>;
       this->next->push_back(this->creat());
       this->last = NULL;
   }else{
       this->next
   
   }


}
void SymbolTable::pop()
{

}
