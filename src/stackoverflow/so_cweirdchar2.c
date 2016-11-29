#include <stdio.h>
int main() 
{ 
    char c;
    int i;
    char *pc;
    int *pi;
    //char s[] = "Hoee ya sheragghat im bedazzlement.";
    char s[] = "bamboozle";

    int array[100];
    i=7;
    array[i]=77;
    printf("%d %d %d %d\n", array[i], *(array+i), *(i+array), i[array]);

    printf("c is %02x, *(c+&i) is %02x\n",c,*((int)c+&i));
    printf("i %p %02x\n",&i,c[&i]);
    printf("c %p %02x\n",&c,c[&c]);
    printf("pi %p %02x\n",&pi,c[pi]);
    printf("pc %p %02x\n",&pc,c[pc]);

    printf("i %p %02x\n",&i,i[&i]);
    printf("c %p %02x\n",&c,i[&c]);
    printf("pi %p %02x\n",&pi,i[pi]);
    printf("pc %p %02x\n",&pc,i[pc]);

    printf("i %p %02x\n",&i,c[&i]);
    printf("c %p %02x\n",&c,c[&c]);
    printf("pi %p %02x\n",&pi,c[pi]);
    printf("pc %p %02x\n",&pc,c[pc]);

    printf("i %p %02x\n",&i,c[&i]);
    printf("c %p %02x\n",&c,c[&c]);
    printf("pi %p %02x\n",&pi,c[pi]);
    printf("pc %p %02x\n",&pc,c[pc]);

    printf("&pi %p %02x\n",&pi,c[&pi]);
    printf("&pc %p %02x\n",&pc,c[&pc]);

    i=0; while(s[i]) { printf("%p %02x %c %c\n",s+i,c[s+i],c[s+i],s[i]); i++; }

    printf("pi ptr ref from ptr on stack\n");
    i=0; pi=&c; while(s[i]) { printf("%p %02x\n",pi,c[pi]); i++; pi++; }

    printf("pi ptr 0 ref\n");
    i=0; pi=0; while(s[i]) { printf("%p %02x\n",pi,c[pi]); i++; pi++; }

    return 1;
}
