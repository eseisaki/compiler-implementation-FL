#include "FLlib.h"


/* program  function_fun */ 

 typedef int intfunc(int n);

 typedef char* string;

 
 int f0,f1,temp;

int fibonacci(int n){
int result;
f0 = 0;
f1 = 1;
while (n>1)
{
temp = f1;
f1 = f1+f0;
f0 = temp;
n = n-1;
}

result = f1;
return result;
}
 
 int fac,i;

int factorial(int n){
int result;
fac = 1;
for(i=n;i>=1;i--)
fac = i*fac;
result = fac;
return result;
}
 


void eval(string prompt, intfunc f, int val){
writeString(prompt);
writeString("(");
writeInteger(val);
writeString(")=");
writeInteger(f(val));
writeString("\n");
return;
}


int main() {
eval("Fibonacci", fibonacci, 5);
eval("factorial", factorial, 5);
}
 


//Syntax Accepted!
