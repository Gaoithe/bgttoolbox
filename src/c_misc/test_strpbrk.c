#include <stdio.h>
#include <string.h>

int main(int argc, char**argv)
{
    char *s = "test string withj a few exclaims\!\!\! and \"quotes\" and quotes at end too\!\!\"\"\"";
    char *charstr = "\"\\\!e";
    char *charstr2 = "#+-=";
    char *ptr;
    int off = 0;
    int slen;

    slen = strlen(s);
    printf("s=%s replace_chars=%s\n",s,charstr);

    ptr = s;

    while (off < slen) {
        // find next char to escape in src str
        ptr = strpbrk(ptr, charstr);
        printf("offset=%d strpbrk p=%p c=%c\n", off, ptr, (ptr==NULL)?'@':*ptr);
        
        if (ptr != NULL  && *ptr != 0) {
            off = ptr - s;
            printf("match:%c off=%d\n", *ptr, off);

            //*ptr = '%';

            // increment ptr over current match
            ptr++;

        } else {
            if (ptr != NULL) {
                off = ptr - s;
                printf("END OF STRING match:%c off=%d\n", *ptr, off);
            } else {
                printf("END OF STRING ptr==NULL==%p\n", ptr);
            }
            break;
        }

        printf("next string ptr=%s\n", ptr);
    }

    printf("s=%s\n",s);


    slen = strlen(s);
    printf("s=%s replace_chars=%s\n",s,charstr2);

    ptr = s;

    while (off < slen) {
        // find next char to escape in src str
        ptr = strpbrk(ptr, charstr2);
        printf("offset=%d strpbrk p=%p c=%c\n", off, ptr, (ptr==NULL)?'@':*ptr);
        
        if (ptr != NULL  && *ptr != 0) {
            off = ptr - s;
            printf("match:%c off=%d\n", *ptr, off);

            //*ptr = '%';

            // increment ptr over current match
            ptr++;

        } else {
            if (ptr != NULL) {
                off = ptr - s;
                printf("END OF STRING match:%c off=%d\n", *ptr, off);
            } else {
                printf("END OF STRING ptr==NULL==%p\n", ptr);
            }
            break;
        }

        printf("next string ptr=%s\n", ptr);
    }

    printf("s=%s\n",s);





}
