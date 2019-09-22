#include "FLlib.h"


/* program  complement */ 

 int n,reverse,temp;


int main() {
writeString("Enter a number to check if it is a palindrome or not\n");
n = readInteger();
temp = n;
do
{
reverse = reverse*10;
reverse = reverse+temp % 10;
temp = temp/10;
}
while (temp!=0);

if (n==reverse) 
{
writeString("Yes,");
writeInteger(n);
writeString(" is a palindrome number.");
writeString("\n");
}

else
{
writeString("No,");
writeInteger(n);
writeString(" is not a palindrome number.");
writeString("\n");
}

writeString("\n");
}
 


//Syntax Accepted!
