/* 
 g++ ~/c/skeytest.c -o ~/c/skeytest 
 g++ -O3 ~/c/skeytest.c -o ~/c/skeytest 
 gcc ~/c/skeytest.c -o ~/c/skeytestgcc 
 gcc -O3 ~/c/skeytest.c -o ~/c/skeytestgccO3 
 g++ -m64 ~/c/skeytest.c -o ~/c/skeytest64 
 g++ -O3 -m64 ~/c/skeytest.c -o ~/c/skeytest64O3 

 unset LD_LIBRARY_PATH
 echo ~/c/skeytest > ~/c/skeytest.log
 ~/c/skeytest >> ~/c/skeytest.log
 echo ~/c/skeytestgcc >> ~/c/skeytest.log
 ~/c/skeytestgcc >> ~/c/skeytest.log
 echo ~/c/skeytestgccO3 >> ~/c/skeytest.log
 ~/c/skeytestgccO3 >> ~/c/skeytest.log
 export LD_LIBRARY_PATH=/usr/lib/sparcv9:/usr/sfw/lib/sparcv9:$LD_LIBRARY_PATH
 echo ~/c/skeytest64 >> ~/c/skeytest.log
 ~/c/skeytest64 >> ~/c/skeytest.log
 echo ~/c/skeytest64O3 >> ~/c/skeytest.log
 ~/c/skeytest64O3 >> ~/c/skeytest.log
 */

#include <stdio.h>

typedef unsigned char UINT8;
typedef unsigned short UINT16;
typedef unsigned int UINT32;

#ifdef WIN32
#define _LITTLE_ENDIAN
#ifndef UINT64
typedef unsigned __int64 UINT64;
#endif
#else
#ifndef UINT64
typedef unsigned long long UINT64;
#endif
#endif

UINT64 localRef2Key(UINT16 rnc, UINT16 cn, UINT32 local_ref)
{
   UINT64 theKey = 0;

   // this doesn't work if gcc -O3
   *((UINT16 *)&theKey) = rnc;
   *((UINT16 *)&theKey+1) = cn;
   *((UINT32 *)&theKey+1) = local_ref;

   //printf("theKey %016llx %" FS_UINT64 " %p\n", theKey, theKey, theKey);
   // printf("theKey %016llx %p\n", theKey, theKey, theKey);

   return theKey;
}

UINT64 localRef2Key_m2(UINT16 rnc, UINT16 cn, UINT32 local_ref)
{
   UINT64 theKey = 0;

   theKey = rnc;
   theKey <<= 16;
   theKey |= cn;
   theKey <<= 32;
   theKey |= local_ref;

   return theKey;
}

UINT64 localRef2Key_m3(UINT16 rnc, UINT16 cn, UINT32 local_ref)
{
   UINT64 theKey = 0;

   theKey = ((UINT64)rnc) | ((UINT64)(((UINT32)cn) << 16)) | (((UINT64)local_ref) << 32);

   return theKey;
}

void localRefTest(UINT16 rnc, UINT16 cn, UINT32 local_ref)
{
   UINT64 key1, key2, key3;
      
   printf(" %d %d %06x: ", rnc, cn, local_ref);

   key1 = localRef2Key(rnc, cn, local_ref);
   printf(" key1:%016llx ", key1);

   key2 = localRef2Key_m2(rnc, cn, local_ref);
   printf(" key2:%016llx ", key2);

   key3 = localRef2Key_m3(rnc, cn, local_ref);
   printf(" key2:%016llx ", key3);

   printf("\n");
}

int main()
{
   localRefTest(1234, 5678, 0x111111);
   localRefTest(1234, 5678, 0x222222);
   localRefTest(1234, 5678, 0x564321);
   localRefTest(1234, 5678, 0x999999);
   localRefTest(5467, 2222, 0x111111);
   localRefTest(5467, 2222, 0x222222);
   localRefTest(5467, 2222, 0x000000);
   localRefTest(1234, 3232, 0x222222);
   localRefTest(1224, 3332, 0x564321);
   localRefTest(2234, 6543, 0x999999);
}

