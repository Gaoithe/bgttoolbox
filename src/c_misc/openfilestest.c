#include <stdio.h>

int main(int argc, char *argv[])
{
    FILE *fp;
    char filename[80] = "xxxx_openfilestest.xxx";
    int i=0;
    int error = 0;
    while (i<1000000 && !error) {
        sprintf(filename,"%04x_openfilestest.xxx",i);
        fp = fopen(filename,"w");
        if (!fp) error=1;
        i++;
    }
    printf("opened %d files, now error=%d\n", i, error);
    return 0;
}
