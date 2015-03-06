#include <stdio.h>

// NEXT time remember this:
// https://docs.python.org/2/library/binascii.html

int main(int argc, char **argv)
{
    if (argc<1) {
        printf("ERROR: Give me a file name.\n.");
        return -1;
    }

    FILE *fin=fopen(argv[1],"r");
    if (fin == NULL) {
        printf("ERROR: opening file '%s'\n.",argv[1]);
        return -1;
    }

    FILE *fout=fopen("out.bin","w");
    if (fout == NULL) {
        printf("ERROR: opening file for write\n.");
        return -1;
    }

    char s[1024];    
    int n;
    int j=0;
    //size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
    while (n=fread(s,1,1024,fin)) {
        printf("n:%d ",n);
        //printf("\n");
        int val=0;
        int i;
        int v=0x55;
        for (i=0;i<n;i++) {
            //printf("i:%d ",i);
            if (s[i] >= '0' && s[i] <= '9') v=s[i]-'0';
            if (s[i] >= 'a' && s[i] <= 'f') v=s[i]-'a'+10;
            if (s[i] >= 'A' && s[i] <= 'F') v=s[i]-'A'+10;
            //printf("v:%d j:%d ",v,j);
            if (v==0x55) {
                if (s[i] != '\n' && s[i] != '\r') {
                    //if (s[i] >= 32 && s[i]<=120) . . . 
                    printf("Invalid char %02x\n",s[i]);
                }
            } else {
                val *= 0x10;
                val += v;
                j++;
                //printf("v:%d j:%d ",v,j);
                if (j==2) {
                    printf("%02x==%c ",val, val);
                    fprintf(fout,"%c",val);
                    j=0;
                    v=0x55;
                }
            }
            
            
        }     
    }

    close(fin);
    close(fout);

    return 0;
}

