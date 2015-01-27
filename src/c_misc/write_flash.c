// Thanks Mike Frysinger
//http://blackfin.uclinux.org/gf/project/uclinux-dist/forum/?action=ForumBrowse&forum_id=39&_forum_action=ForumMessageBrowse&thread_id=34588

// I want to fseek to position 0x254 and write 1 or 2 instead of 0
// boot_script_timeout
// 00000240: 0c62 6f6f 745f 7363 7269 7074 5f74 696d  .boot_script_tim
// 00000250: 656f 7574 0262 6f6f 745f 7363 7269 7074  eout.boot_script
// 00000260: 0000 0000 0001 0601 0062 6f6f 7470 0000  .........bootp..

// gcc ~/c/write_flash.c -o ~/c/write_flash
// /usr/local/gcc-3.4.5-glibc-2.3.6/arm-linux/bin/arm-linux-gcc ~/c/write_flash.c -o ~/c/write_flash_arm


#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

// expect/assert
#define C(f, r) do { if ((f) != r) { perror(#f); return -1; } } while (0)

void hexdump(char *msg, char *buf, int len)
{
    int i;
    char c;
    char str[0x11];
    if (msg != NULL) printf("%s: %s\n", __func__, msg);
    i=0;
    while(i<len){
        if (i%0x10 == 0) printf("%08x: ",i);
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

char data[1024], data2[1024];
int main()
{
    int fd;
    C(fd = open("/dev/mtdblock4", O_RDWR), 3);
    //C(fd = open("/tmp/mtdblock4", O_RDWR), 3);
    
    // read
    C(lseek(fd, 0x240, SEEK_SET), 0x240);
    C(read(fd, data, 0x20), 0x20);
    hexdump("read data", data, 0x20);
    
    data[0x14] = 1;
    hexdump("mod data", data, 0x20);
    
    // this is the scary close your eyes bit for flash
    // write
    C(lseek(fd, 0x240, SEEK_SET), 0x240);
    if (1)
        C(write(fd, data, 0x20), 0x20);
    
    // read
    C(lseek(fd, 0x240, SEEK_SET), 0x240);
    C(read(fd, data2, 0x20), 0x20);
    hexdump("read data2", data2, 0x20);

    // verify
    C(memcmp(data, data2, 0x20), 0);
    
    /*
      memset(data, 0x35, sizeof(data));
      memcpy(data2, data, sizeof(data));
      C(lseek(fd, 6, SEEK_SET), 6);
      C(write(fd, data, sizeof(data)), sizeof(data));
      C(lseek(fd, 6, SEEK_SET), 6);
      C(read(fd, data, sizeof(data)), sizeof(data));
      C(memcmp(data, data2, sizeof(data)), 0);
      
      memset(data, ~0x35, sizeof(data));
      memcpy(data2, data, sizeof(data));
      C(lseek(fd, 6, SEEK_SET), 6);
      C(write(fd, data, sizeof(data)), sizeof(data));
      C(lseek(fd, 6, SEEK_SET), 6);
      C(read(fd, data, sizeof(data)), sizeof(data));
      C(memcmp(data, data2, sizeof(data)), 0);
    */
    
    C(close(fd), 0);
    puts("ALL OK");
    
    return 0;
}
