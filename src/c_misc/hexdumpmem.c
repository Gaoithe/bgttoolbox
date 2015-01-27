// gcc ~/c/hexdump.c -o ~/c/hexdump
// /usr/local/gcc-3.4.5-glibc-2.3.6/arm-linux/bin/arm-linux-gcc ~/c/hexdump.c -o ~/c/hexdump_arm
// ~/c/hexdump 0 10
// ~/c/hexdump 0xc0353c30 0x50
// /home/jc235005/c/hexdump_arm 0xc0353c30 0x50

// [jc235005@brocadh fconfig]$ nm /usr/local/OLO/Intel_CE_2110-1.5.354/linux-2.6.16.16/vmlinux  |grep c0353|sort |less
//c0353c30 B mtd_table
//c0353c70 b proc_mtd
//c0353c74 b mtd_class

#include <stdio.h>
#include <stdlib.h>

void hexdump(char *msg, char *buf, long offset, int len)
{
    long i;
    char c;
    char str[0x11];
    if (msg != NULL) printf("%s: %s\n", __func__, msg);
    i=0;
    while(i<len){
        if (i%0x10 == 0) printf("%08x: ",i+offset);
        c = *(buf+i);
        printf("%02x", (int)c);           
        str[i%0x10] = '.';     
        if (c >= 32 && c<=120) str[i%0x10] = c;
        if (i%2 == 0) printf(" ");
        if (i%0x10 == 0xf) {
            str[i%0x10+1] = 0;
            printf(" %s\n",str);
        }
        i++;
    }
    if (i%0x10 != 0xf) {
        str[i%0x10+1] = 0;
        printf(" %s\n",str);
    }                  
    
}

int a_glob;

int main(int argc, char **argv)
{
    char *ptr = 0;
    int len=0x10;

    // argv[1] = address argv[2] = length
    if (argc>=2)
        ptr = (char*)strtoul(argv[1],NULL,16);
    
    if (argc>=3)
        len = (int)strtoul(argv[2],NULL,16);

    printf("glob %p %lx, stack %p %lx\n", &a_glob, &a_glob, &len, &len);

    printf("hexdump %lx, %x,\n",(long)ptr,len);
    hexdump(NULL,ptr,(long)ptr,len);

    return 0;
}

