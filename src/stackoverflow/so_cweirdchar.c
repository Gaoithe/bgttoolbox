#include <stdio.h>
int main() 
{ 
    char c;
    int i;
    printf("%p %02x\n",&i,c[&i]);
    printf("%p %02x\n",&c,c[&c]);
}
