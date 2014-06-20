#include <stdio.h>

unsigned char CrcByteLUT[128][256];

void MakeCrcByteLUT()
{
    int crcpoly=0x45;
    int crc, byte, i, reg, bit;
    for(crc=0;crc<128;crc++)
	for(byte=0;byte<256;byte++){
	    reg=crc;
	    for(i=0;i<8;i++){
		bit = (byte>>(7-i))&1;
		reg <<= 1;
		reg |= bit;

		if (reg&0x80) {   // if top bit of reg set
		    reg=reg&0x7f; // not really needed
		    reg=reg^crcpoly;
		}

	    }
	    reg&=0x7f;
	    CrcByteLUT[crc][byte] = reg;
	}
}

int CalcCrcUsingCrcByteLUT(int bytelen, char *buf){
    int i;
    unsigned char byte;    // see this unsigned ... cost me an hour. nassSS55ty
    int crc = 0;

    //printf("crc,byte: ");

    for(i=0;i<=bytelen;i++){
	// from a bit-offset of 7 
                                // first LSB
	byte = ((*(buf+i))&1)<<7;
                                // next 7 MSBits (or 7 bits of 0s at end)
	if (i!=bytelen) byte |= ((*(buf+i+1))&0xfe)>>1;  
	//printf("%02x,%02x - ", crc, byte);
	crc=CrcByteLUT[crc][byte];
	//printf("%02x, ", crc, byte);

    }

    //printf("\n");

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
  char byte,fbyte;
  int bit;

  int rem = 0; // ramainder
  int reg = 0; // register implementation 
  // http://www.repairfaq.org/filipg/LINK/F_crc_v33.html#CRCV_001 

  //printf("crc,byte: ");

  for (i=bitoffset;i<(bitlen+bitoffset);i++){
     byte = *(buf + (i / 8));

     // lsb last
     bit = (byte>>((7-(i%8))))&1;

     fbyte <<= 1; fbyte |= bit;
     //if ( (i-bitoffset ) % 8 == 0) printf("%02x,%02x %02x, ", crc, byte, fbyte);

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

  //printf("\n");

  return crc & 0x7f; 
}


int testcrc(char *buf, int byteslen)
{
   int crc;

   /// 0 to 33+7? 7 to 33? 7 to 33+7?
   crc = CrcCalcBit(0x45, 7, (byteslen*8)+1+7, buf);
   printf("crc is %02x == %02x?\n", crc, (buf[0]>>1)&0x7f);
   if (crc == ((buf[0]>>1)&0x7f)) printf("WAHOO!\n"); else printf("Feh :(\n");

   crc = CalcCrcUsingCrcByteLUT(byteslen, buf);
   printf("crc is %02x == %02x?\n", crc, (buf[0]>>1)&0x7f);
   if (crc == ((buf[0]>>1)&0x7f)) printf("WAHOO TWO!\n"); else printf("Feh :( ngyeh\n");

   return crc;
}

main()
{
    // 0 0001 0010 0000 0010 0000 0001 0000 0001 0000 0000
    // 00001001 00000001 00000000 10000000 10000000 0
    // 09 01 00 80 80
   unsigned char buf[100] = "\x7a\x12\x02\x01\x01\x00";
   //unsigned char bwbuf[100] = "\x7a\x48\x40\x80\x80\x00"; // buf backwards
   unsigned char buf2[100] = "\xd2\xfe\x02\x01\x01\x00";
   unsigned char buf3[100] = "\x80\x56\x02\x01\x01\x00";
   unsigned char buf4[100] = "\x80\xfc\x01\x18\x2b\x00";
   unsigned char buf5[100] = "\x80\xfc\x01\x00\x18\x2b\x00";
   unsigned char buf6[100] = "\x7a\x12\x02\x01\x01\xff";

   int crc = 0;

   MakeCrcByteLUT();

   testcrc(buf,4);
   testcrc(buf2,4);
   testcrc(buf3,4);
   testcrc(buf4,4);  // expect wrong
   testcrc(buf5,2);

   testcrc(buf6,4); // bit impl will fail (not padded with 7 0s at end, LUT impl should work

}
