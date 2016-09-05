#include "itoa.h"
#include <math.h>
#include <cstdio>

char *itoa(int i)
{
    static char s[200];
    sprintf(s,"%d",i);
    return s;
}
