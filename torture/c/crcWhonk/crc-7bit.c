#include <stdio.h>

//int poly = 0x51;
int poly = 0x45;

int CrcCalcXX(int len, char *buf){
  int crc = 0;
  int i,j,index;
  char byte;
  for (i=0;i<len;i++){
	 byte = *buf++;
    crc ^= byte;
    for (j=0;j<8;j++){

       printf("Byte is %02x, crc is %02x, %d %d\n", byte, crc, i, j );

       int bit = crc & 1;
       crc >>= 1;
       if (bit)
          crc ^= poly;

       /*
       // shift in msb first, lsb last

       //if (byte & 1){
       if (byte & 0x80){
		  crc = (crc >> 1) ^ poly;
		} else {
		  crc = (crc >> 1);
		}
      byte<<=1;
       */


    }
	 //index = (byte ^ crc) & 0xff;
	 //crc = (crc >> 8) ^ CrcLUT[index];
  }
  return crc; 
}

int bitmask7f = 0x7f;
// 7 bit byte by 7 bit byte
// ?? doesn't work ?? because crc paload is not 7bitbyte aligned???? maybe?
int CrcCalc(int crcpoly, int len, char *buf){
  int crc = 0;
  int i,j,index;
  char byte1, byte2;
  int byte;
  int byteptr, bitoffset;

  int bitlen = (len * 8);             /// 24
  int byte7len = (len * 8) / 7;       /// 3

  crc = crcpoly; // cheat to start off with 1st bit 0

  for (i=0;i<bitlen;i++){


     if (i%7 == 0){

        // msb first or lsb first?
        byteptr = i/8;          /// 0, 0, 1, 2, 
        byte1 = *(buf+byteptr);
        byte2 = *(buf+byteptr+1);

        bitoffset = i%8;             /// 0, 7, 6, 5 ...
 
        // 1st time
        //byte = byte1 & bitmask7f;
        //byte |= byte2 & 0;

        // 2nd time
        //byte = (byte1>>7) & (bitmask7f);  
        //byte |= (byte2<<1) & (bitmask7f);

        byte = (byte2<<8) | byte1;
        printf("ByteByte is %02x\n", byte);
        byte >>= bitoffset;
        byte &= bitmask7f;

        crc ^= byte;

        printf("Byte is %02x, crc is %02x, i byteptr bitoffset %d %d %d\n", 
               byte, crc, i, byteptr, bitoffset );

     }

     //for (j=0;j<7;j++){
     printf("Byte is %02x, crc is %02x, %d %d\n", byte, crc, i, i%7 );

     int bit = crc & 1;
     crc >>= 1;
     if (bit) {
        crc ^= crcpoly;
        crc |= 0x40;
     }

  }
  return crc; 
}


typedef long crc24;
crc24 crc_octets_x(crc24 crcpoly, crc24 crc, unsigned char *octets, size_t len)
{
  // crc24 crc = CRC24_INIT;
  int i,bit;
  
  // right shifting byte in from left
  while (len--) {
	 crc ^= (*octets++) << 16;
	 for (i = 0; i < 8; i++) {
		bit = crc & 1;
		crc >>= 1;
		if (bit)
		  crc ^= crcpoly;
	 }
  }
  //return crc;
  return crc & 0xffffffL;
}

// bit by bit
int CrcCalcBitWRONG(int crcpoly, int bitoffset, int bitlen, char *buf){
  int crc = 0;
  int i,j,index;
  char byte;
  int bit;

  //crc = crcpoly; // cheat to start off with 1st bit 0

  for (i=bitoffset;i<(bitlen+bitoffset);i++){

     byte = *(buf + (i / 8));

     // lsb last
     bit = byte & (0x80>>(i%8));

     printf("Byte is %02x, bit is %02x, %d\n", byte, bit, i);

     crc >>= 1;

     if (bit) crc ^= crcpoly;

     printf("crc is %02x\n", crc);

  }
  return crc; 
}

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
  int sreg = 0; // another register implementation 
  // http://www.repairfaq.org/filipg/LINK/F_crc_v33.html#CRCV_001
 
  //crc = crcpoly; // cheat to start off with 1st bit 0

  for (i=bitoffset;i<(bitlen+bitoffset);i++){
     byte = *(buf + (i / 8));

     // lsb last
     //bit = (byte>>(i%8))&1;
     bit = (byte>>((7-(i%8))))&1;

     rem <<= 1;
     rem |= bit;

     int topbit=reg&0x40;
     reg <<= 1;
     reg |= bit;

     printf("Byte is %02x, bit is %02x, rem %02x, reg %02x, %d. ", byte, bit, rem, reg, i);

     //if (reg&0x40) {   // if top bit of reg set   // this check WRONG, too late, other top bit!
     if (topbit) {   // if top bit of reg set
        reg=reg&0x7f;
        reg=reg^crcpoly;
     }

     if (rem >= crcpoly) {
        rem ^= crcpoly;
        rem &= 0x7f;
     } else {
     }

     int stopbit = sreg&0x40; 
     sreg <<= 1;
     sreg=sreg&0x7f;
     if (stopbit) {   // if top bit of reg set
        sreg=sreg^crcpoly;
     }
     sreg ^= bit;

     //crc = rem;
     //crc = reg;

     crc = rem;
     crc = reg;

     printf("reg is %02x, crc is %02x, sreg is %02x\n", reg, crc, sreg);

  }
  return crc & 0x7f; 
}

// byte backwards 
char bw(char b)
{
   char bbw = 0;
   int i;
   for(i=0;i<8;i++){
      bbw<<=1;
      bbw |= b&1;
      b>>=1;
   }
      
   return bbw;
}

void maybecrc(char b)
{
   char b1 = (b>>1)&0x7f;
   char b2 = b&0x7f;
   char bbw1 = bw(b&0xfe);
   char bbw2 = bw((b&0x7f)<<1);

   b1&=0xff; b2&=0xff;
   bbw1&=0xff; bbw2&=0xff;
   printf(" == %02x => %02x? %02x? %02x? %02x?", 
          b&0xff, b1, b2, bbw1&0xff, bbw2
          );

   printf(" not %02x? %02x? %02x? %02x?", 
          (~b1)&0x7f, (~b2)&0x7f, (~(bbw1&0xff))&0x7f, (~bbw2)&0x7f
          );

   printf("1s comp %02x?, ", (~b)&0x7f); // one's compliment (and 24 bit)
   
   printf("\n");
}

int testcrc(char *buf)
{
   int crc;

   /// 0 to 33+7? 7 to 33? 7 to 33+7?
   crc = CrcCalcBit(0x45, 7, 33+7, buf);


   //crc = CrcCalcBit(0, 7, 33+7, buf);

   //crc = CrcCalcBit(0x45, 7, 33+7, buf);
   //crc = CrcCalcBit(0x45, 0, 33+8, buf);
   //crc = CrcCalcBit(0x45, 0, 33+7+8, buf);
   //crc = CrcCalcBit(0x51, 7, 33+7, buf);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[0]>>1)&0x7f, buf[0]&0x7f);
   if (crc == ((buf[0]>>1)&0x7f)) printf("WAHOO!\n"); else printf("Feh :(\n");

   //maybecrc(crc);
   //maybecrc(buf[0]);

   /*
   crc = CrcCalcBit(0x45, 0, 40, buf);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[0]>>1)&0x7f, buf[0]&0x7f);

   crc = CrcCalcBit(0x45, 7, 33, buf);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[0]>>1)&0x7f, buf[0]&0x7f);

   crc = CrcCalcBit(0x45, 0, 48, buf);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[0]>>1)&0x7f, buf[0]&0x7f);
   */


   /*
   crc = CrcCalcBit(0x45, 7, 33+8, buf);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[0]>>1)&0x7f, buf[0]&0x7f);

   crc = CrcCalcBit(0x45, 7, 25, buf+1);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[1]>>1)&0x7f, buf[1]&0x7f);

   crc = CrcCalcBit(0x45, 7, 25+8, buf+1);
   printf("crc is %02x == %02x? %02x?\n", crc, (buf[1]>>1)&0x7f, buf[1]&0x7f);
   */

   return crc;
}


int testXcrc(char *buf1, char*buf2)
{
   int crc;

   int p = 0x45; // polynomial

   //for (p=0;p<=0xff;p++){

      int crc1 = CrcCalcBit(p, 7, 33, buf1);
      int crc2 = CrcCalcBit(p, 7, 33, buf2);

      if (crc1 == crc2) printf("HOI! poly %02x\n", p);
      printf("poly %02x crc1 %02x crc2 %02x\n", p, crc1, crc2);

      crc1 = CrcCalcBit(p, 7, 35, buf1);
      crc2 = CrcCalcBit(p, 7, 35, buf2);

      if (crc1 == crc2) printf("HOI! poly %02x\n", p);
      printf("poly %02x crc1 %02x crc2 %02x\n", p, crc1, crc2);

      crc1 = CrcCalcBit(p, 7, 33+7, buf1);
      crc2 = CrcCalcBit(p, 7, 33+7, buf2);

      if (crc1 == crc2) printf("HOI! poly %02x\n", p);
      printf("poly %02x crc1 %02x crc2 %02x\n", p, crc1, crc2);

      crc1 = CrcCalcBit(p, 0, 33+8, buf1);
      crc2 = CrcCalcBit(p, 0, 33+8, buf2);

      if (crc1 == crc2) printf("HOI! poly %02x\n", p);
      printf("poly %02x crc1 %02x crc2 %02x\n", p, crc1, crc2);

      crc1 = CrcCalcBit(p, 0, 42, buf1);
      crc2 = CrcCalcBit(p, 0, 42, buf2);

      if (crc1 == crc2) printf("HOI! poly %02x\n", p);
      printf("poly %02x crc1 %02x crc2 %02x\n", p, crc1, crc2);

      crc1 = CrcCalcBit(p, 0, 33+7+8, buf1);
      crc2 = CrcCalcBit(p, 0, 33+7+8, buf2);

      if (crc1 == crc2) printf("HOI! poly %02x\n", p);
      printf("poly %02x crc1 %02x crc2 %02x\n", p, crc1, crc2);

      //}
}

int testcrc2(char *buf)
{
   // crc starts on 2nd byte??
   int crc = CrcCalcBit(0x45, 7, 25, buf+1);
   printf("crc is %02x == %02x?\n", crc, (buf[1]>>1)&0x7f);
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

   //crc = CrcCalcBit(0x45, 7, 25, buf);
   //printf("crc is %02x == %02x?\n", crc, buf[0]>>1);

   testcrc(buf);
   //testcrc(bwbuf);
   testcrc(buf2);
   testcrc(buf3);
   testcrc(buf4);

   //testXcrc(buf3,buf4);

   /*
   testcrc2(buf);
   testcrc2(buf2);
   testcrc2(buf3);
   testcrc2(buf4);
   */


   /*
   crc = CrcCalcBit(0x45, 7, 33, buf);
   printf("crc is %02x == %02x?\n", crc, buf[0]>>1);


   //crc = CrcCalcBit(0x45, 7, 25, buf2);
   //printf("crc is %02x == %02x?\n", crc, buf2[0]>>1);

   //crc = CrcCalcBit(0x45, 7, 25, buf2+1);
   //printf("crc is %02x == %02x?\n", crc, buf2[1]>>1);

   crc = CrcCalcBit(0x45, 7, 33, buf2);
   printf("crc is %02x == %02x?\n", crc, buf2[0]>>1);

   crc = CrcCalcBit(0x45, 7, 33, buf3);
   printf("crc is %02x == %02x?\n", crc, buf3[0]>>1);

   crc = CrcCalcBit(0x45, 7, 33, buf4);
   printf("crc is %02x == %02x?\n", crc, buf4[0]>>1);
   */

   /*
   crc = CrcCalcBit(0x45, 0, 24, buf+1);
   printf("crc is %02x\n", crc); */

   //crc = CrcCalcBit(0x51, 7, 25, buf);
   //printf("crc is %02x\n", crc);

   /*
   int crc = CrcCalc(0x45, 3, buf+1);
   printf("crc is %02x\n", crc);

   crc = CrcCalc(0x51, 3, buf+1);
   printf("crc is %02x\n", crc);
   */
}
