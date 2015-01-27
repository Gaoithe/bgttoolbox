#include <stdio.h>
#include <string.h>

char *lowercase(char *s)
{
    char *p;

    // convert key to lowercase. vld8r user helper
    p=s;
    while(*p) {
        //printf("*p=%c\n",*p);
        if (*p >= 'A' && *p <= 'Z') {
            *p += 'A' - 'a';
        }
        p++;
    }

    return s;
}

int main(int argc, char **argv)
{
    char copy[800];
    char *a="aaaAAAaaaAAAbbbBBBBzzzZZZ0123456789(&*\"!£$%^&*()";
    printf("%s\n",a);
    strcpy(copy,a);
    printf("%s\n",lowercase(copy));
}
