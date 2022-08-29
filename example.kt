/*
 * Example with Functions
 */

class example {
  // constants
  val a = 5
   
  // variables
  var c : int
  var n = 5 
  var b = true
  // function declaration
  fun add (a: int, b: int) : int {
    return a+b
  }
  
  
  while(n<=10)
     n = n + 1
  
  
  
  // main statements
  fun main() {
    if(true)
       n = 11
    else
       n = 12
    c = add(a, 10)
    if (c > 10)
      print -c
    else
      print c
    println ("Hello World")
  }
}
