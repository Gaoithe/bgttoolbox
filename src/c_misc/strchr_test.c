#include <stdio.h>
#include <string.h>


// in cobwebs.c iterate | seperated list
// yeah, actually strtok does same thing so might as well . . . 

int main(int argc, char **argv)
{
    char *md5_list[4] = { "ABC|DEF|GHI|JKL", "MNO", "", NULL };
    int i;

    char copy[800];
    char *c1,*c2;

    for (i=0;i<4;i++) {
        //c1 = md5_list[i];   // segfault writing to const var mem

        // need to check for NULL before strcpy :-7
        if (md5_list[i]) {

            strcpy(copy,md5_list[i]);
            c1 = copy;
            printf("TEST strchr with \"%s\"\n",c1);

            while (c1) { 
                c2 = strchr(c1,'|');
                if (c2 != NULL ) {
                    printf("  deb got | in str\n");
                    *c2 = 0;
                    printf("  deb 2\n");
                }

                printf(" sub:%s\n",c1);
                printf("  deb 3\n");

                if (c2 != NULL ) {
                    printf("  deb next\n");
                    c1 = c2;
                    c1++;
                } else {
                    printf("  deb set c1 to NULL END loop\n");
                    c1 = NULL;
                }

            }

        }

    }

#ifdef NOT_DEFINED
#endif

    for (i=0;i<4;i++) {
        //c1 = md5_list[i];


        // need to check for NULL before strcpy :-7
        if (md5_list[i]) {

            strcpy(copy,md5_list[i]);
            c1 = copy;
            printf("TEST strtok with \"%s\"\n",c1);

            //if (c1 && strlen(c1) > 0) { // need to check c1 and/or strlen(c1) ??
            //tokBuf = RESTRDUP(tokBuf, tmpPtr);
            //if ((c2 = strstr(c1, "|")) != NULL) {   // need the strstr check?

            c1 = strtok(c1, "|");
            while (c1) {
                printf(" sub:%s\n",c1);
                c1 = strtok(NULL, "|");
            }
        }
    }

    printf("TESTS FINISHED\n");

}
