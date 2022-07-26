#include "symtab.h"
#include <iostream>

using namespace std;

void SymbolTable::creat()
{
  return;
}

string SymbolTable::lookup(string s)
{
   map<string, string>::iterator it;
   it = symbolTable.find(s);
   if(it != symbolTable.end())
	return s;
   return NULL;
}
string SymbolTable::insert(string s)
{
   pair<map<string, string>::iterator, bool> retPair;
   retPair = this->symbolTable.insert(pair<string,string>(s,s));
   if(retPair.second == true){
//	cout << "Insert Successfully\n";
        return s;
   }
//   else
//	cout << "Insert Failure\n";
   return "False";
}

void SymbolTable::dump()
{
   for(const auto& entry : symbolTable){
      cout << "index: " << entry.first << ", value: " << entry.second << endl;
   }
}
