#include "symtab.h"
#include <iostream>
#include <queue>

using namespace std;

Node::Node()
{
	this->constant = false;
	this->ret = false;
	this->next = NULL;
}

Node::Node(const string id, const string scope, ValueType type)
{
	this->identifier = id;
	this->scope = scope;
	this->type = type;
	this->constant = false;
	this->ret = false;
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
ValueType Node::getType()
{
   return this->type;
}
string Node::getScope()
{
   return this->scope;
}
Node* Node::getNext()
{
    return this->next;
}
void Node::setConstant(bool b)
{
   this->constant = b;
}
bool Node::getConstant()
{
   return this->constant;
}
void Node::setRet(bool b)
{
   this->ret = b;
}
bool Node::getRet()
{
   return this->ret;
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

Node* SymbolTable::lookup(const string id)
{
   int index = hashf(id);
   
   map<int, Node*>::iterator it;
   it = this->symbolTable.find(index);
   if(it != this->symbolTable.end()){
      Node* n = this->symbolTable[index];	   
      while(n != NULL){
         if(n->getIdentifier() == id)
            return n;
	 n = n->next;
      }
   }

   return NULL;
}
bool SymbolTable::insert(Node* n)
{
   int index = hashf(n->getIdentifier());
   map<int, Node*>::iterator it = this->symbolTable.find(index);

   if(it == this->symbolTable.end()){
      this->symbolTable[index] = n;
      return true;
   }
   else{
      Node* start = this->symbolTable[index];

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
   for(const auto& entry : this->symbolTable){
      Node* temp = entry.second;
      while(temp != NULL){
         cout << temp->getIdentifier() << "  " << temp->getType() << " " <<  temp->getScope() << endl;
         temp = temp->getNext();
      }
   }
}
void SymbolTable::dump(SymbolTable* s)
{
   for(const auto& entry : s->symbolTable){
      Node* temp = entry.second;
      while(temp != NULL){
   printf("%-20s%-20d%-20s\n", temp->getIdentifier().c_str(), temp->getType(), temp->getScope().c_str());
         //cout << temp->getIdentifier() << " " << temp->getType() << " " <<  temp->getScope() << endl;
         temp = temp->getNext();
      }
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

void SymbolTable::setParent(SymbolTable* parent)
{
   this->parent = parent;
}
vector<SymbolTable*> SymbolTable::getChilds()
{
   return this->childs;
}
void SymbolTable::addChilds()
{
   SymbolTable* temp = creat();
   temp->setParent(this);
   return this->childs.push_back(temp);
}
//-------------------------------------------

Symtab_list::Symtab_list()
{
   this->head = NULL;
   this->cur  = NULL;
}

void Symtab_list::push()
{ 
   //如果是第一個symbol table
   if(this->head == NULL){
       this->head = creat();
       this->head->addChilds();
       this->cur = this->head->getChilds().front();
      // cout << "1: " << this->cur << endl;
   }
   //曾做過的階層
   else if(cur->getChilds().size() != 0){
     //  cout << "2:" << this->cur << endl;
       this->cur->addChilds();
       //this->cur->getChilds().back()->setParent(this->cur);
    //   cout << "2:" <<this->cur->getParent() << endl;
       this->cur = this->cur->getChilds().back();
   }
   //未做過得階層
   else{
    //   cout << "3:" << this->cur << endl;

       this->cur->addChilds();
    //   cout << "3:" <<this->cur->getParent() << endl;

       //this->cur->getChilds().front()->setParent(this->cur);
       this->cur = this->cur->getChilds().front();
   }
   
}
void Symtab_list::pop()
{
   this->cur = this->cur->getParent();
}

Node* Symtab_list::lookup_token(const string id)
{
   SymbolTable* temp = this->cur;  
   while(temp != head){
      Node* n = temp->lookup(id);
      if(n == NULL ){
         temp = temp->getParent();
      }else{
         return n;
      }
   }

   return NULL;
}
bool Symtab_list::insert_token(Node* ti)
{
   return this->cur->insert(ti);
}
void Symtab_list::dump_all()
{
   int count = 1;
   queue<SymbolTable*> symtab_queue;
   for(const auto& symtab : this->head->getChilds()){
      symtab_queue.push(symtab);
   }
   cout << "--------------------------------------------------\n";
   printf("%-20s%-20s%-20s\n", "Name", "Type", "Scope");
   while(!symtab_queue.empty()){
      cout << "Symbol Table: "<< count++  << "-----------------------------------" << endl;
      SymbolTable* s = symtab_queue.front();
      if(!s->getChilds().empty()){     
         for(const auto& symtab : s->getChilds()){
            symtab_queue.push(symtab);
	 }
      }
      symtab_queue.pop();    
      dump(s);
   }
}
