
#include <map>
#include <string>

class SymbolTable
{
public:

   void creat();
   std::string lookup(const std::string s);
   std::string insert(const std::string s);
   void dump();

private:

   std::map<std::string, std::string> symbolTable;
};
