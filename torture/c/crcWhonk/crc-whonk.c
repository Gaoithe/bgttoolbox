#include <stdio.h>

// bit by bit
// proper divide in bitstream by the poly (bit by bit)
// we don't care about result of divide, the remainder is the crc.
/// proper divide ... didn't really work? 
// 3 algos here, well ... two.
// remainder algo and reg/sreg algo.   reg/sreg seem to be good
int CrcCalcBit(int crcpoly, int bitoffset, int bitlen, char *buf){
  int crc = 0;
  int i,j,index;
  char byte;
  int bit;

  int rem = 0; // ramainder
  int reg = 0; // register implementation 
  // http://www.repairfaq.org/filipg/LINK/F_crc_v33.html#CRCV_001 

  for (i=bitoffset;i<(bitlen+bitoffset);i++){
     byte = *(buf + (i / 8));

     // lsb last
     bit = (byte>>((7-(i%8))))&1;

     rem <<= 1;
     rem |= bit;

     int topbit=reg&0x40;
     reg <<= 1;
     reg |= bit;

     //printf("Byte is %02x, bit is %02x, rem %02x, reg %02x, %d. ", byte, bit, rem, reg, i);

     if (topbit) {   // if top bit of reg set
        reg=reg&0x7f;
        reg=reg^crcpoly;
     }

     if (rem >= crcpoly) {
        rem ^= crcpoly;
        rem &= 0x7f;
     } else {
     }

     //crc = rem;
     crc = reg;

     //printf("reg is %02x, crc is %02x, sreg is %02x\n", reg, crc, sreg);

  }
  return crc & 0x7f; 
}


int testcrc(char *buf)
{
   int crc;

   /// 0 to 33+7? 7 to 33? 7 to 33+7?
   crc = CrcCalcBit(0x45, 7, 33+7, buf);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[0]>>1)&0x7f, buf[0]&0x7f);
   if (crc == ((buf[0]>>1)&0x7f)) printf("WAHOO!\n"); else printf("Feh :(\n");

   return crc;
}

main()
{

   unsigned char buf[100] = "\x7a\x12\x02\x01\x01\x00";
   //unsigned char bwbuf[100] = "\x7a\x48\x40\x80\x80\x00"; // buf backwards
   unsigned char buf2[100] = "\xd2\xfe\x02\x01\x01\x00";
   unsigned char buf3[100] = "\x80\x56\x02\x01\x01\x00";
   unsigned char buf4[100] = "\x80\xfc\x01\x18\x2b\x00";

   int crc = 0;

   testcrc(buf);
   testcrc(buf2);
   testcrc(buf3);
   testcrc(buf4);

}
