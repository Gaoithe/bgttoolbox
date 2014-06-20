#include <stdio.h>

#define CRC16_POLY 0x8005
#define CRC16_POLY_BACK 0xa001

long tbl_crc16[256] = {
   0x0000, 0x8005, 0x800f, 0x000a, 0x801b, 0x001e, 0x0014, 0x8011, 
   0x8033, 0x0036, 0x003c, 0x8039, 0x0028, 0x802d, 0x8027, 0x0022, 
   0x8063, 0x0066, 0x006c, 0x8069, 0x0078, 0x807d, 0x8077, 0x0072, 
   0x0050, 0x8055, 0x805f, 0x005a, 0x804b, 0x004e, 0x0044, 0x8041, 
   0x80c3, 0x00c6, 0x00cc, 0x80c9, 0x00d8, 0x80dd, 0x80d7, 0x00d2, 
   0x00f0, 0x80f5, 0x80ff, 0x00fa, 0x80eb, 0x00ee, 0x00e4, 0x80e1, 
   0x00a0, 0x80a5, 0x80af, 0x00aa, 0x80bb, 0x00be, 0x00b4, 0x80b1, 
   0x8093, 0x0096, 0x009c, 0x8099, 0x0088, 0x808d, 0x8087, 0x0082, 
   0x8183, 0x0186, 0x018c, 0x8189, 0x0198, 0x819d, 0x8197, 0x0192, 
   0x01b0, 0x81b5, 0x81bf, 0x01ba, 0x81ab, 0x01ae, 0x01a4, 0x81a1, 
   0x01e0, 0x81e5, 0x81ef, 0x01ea, 0x81fb, 0x01fe, 0x01f4, 0x81f1, 
   0x81d3, 0x01d6, 0x01dc, 0x81d9, 0x01c8, 0x81cd, 0x81c7, 0x01c2, 
   0x0140, 0x8145, 0x814f, 0x014a, 0x815b, 0x015e, 0x0154, 0x8151, 
   0x8173, 0x0176, 0x017c, 0x8179, 0x0168, 0x816d, 0x8167, 0x0162, 
   0x8123, 0x0126, 0x012c, 0x8129, 0x0138, 0x813d, 0x8137, 0x0132, 
   0x0110, 0x8115, 0x811f, 0x011a, 0x810b, 0x010e, 0x0104, 0x8101, 
   0x8303, 0x0306, 0x030c, 0x8309, 0x0318, 0x831d, 0x8317, 0x0312, 
   0x0330, 0x8335, 0x833f, 0x033a, 0x832b, 0x032e, 0x0324, 0x8321, 
   0x0360, 0x8365, 0x836f, 0x036a, 0x837b, 0x037e, 0x0374, 0x8371, 
   0x8353, 0x0356, 0x035c, 0x8359, 0x0348, 0x834d, 0x8347, 0x0342, 
   0x03c0, 0x83c5, 0x83cf, 0x03ca, 0x83db, 0x03de, 0x03d4, 0x83d1, 
   0x83f3, 0x03f6, 0x03fc, 0x83f9, 0x03e8, 0x83ed, 0x83e7, 0x03e2, 
   0x83a3, 0x03a6, 0x03ac, 0x83a9, 0x03b8, 0x83bd, 0x83b7, 0x03b2, 
   0x0390, 0x8395, 0x839f, 0x039a, 0x838b, 0x038e, 0x0384, 0x8381, 
   0x0280, 0x8285, 0x828f, 0x028a, 0x829b, 0x029e, 0x0294, 0x8291, 
   0x82b3, 0x02b6, 0x02bc, 0x82b9, 0x02a8, 0x82ad, 0x82a7, 0x02a2, 
   0x82e3, 0x02e6, 0x02ec, 0x82e9, 0x02f8, 0x82fd, 0x82f7, 0x02f2, 
   0x02d0, 0x82d5, 0x82df, 0x02da, 0x82cb, 0x02ce, 0x02c4, 0x82c1, 
   0x8243, 0x0246, 0x024c, 0x8249, 0x0258, 0x825d, 0x8257, 0x0252, 
   0x0270, 0x8275, 0x827f, 0x027a, 0x826b, 0x026e, 0x0264, 0x8261, 
   0x0220, 0x8225, 0x822f, 0x022a, 0x823b, 0x023e, 0x0234, 0x8231, 
   0x8213, 0x0216, 0x021c, 0x8219, 0x0208, 0x820d, 0x8207, 0x0202
   };

#define CRC16_INIT 0

// I haven't checked does this algo work
long crc_calc(char *cp, int len)
{
  long fcs = CRC16_INIT;
  while (len--)
	 fcs = (fcs >> 8) ^ tbl_crc16[(fcs ^ *cp++) & 0xff];
  return fcs;
}


/*

Crc16CalcBit is good, calculates checksum bit by bit

CrcInitLUTUsingBitwise generates CrcLUT[256] using crcs
calculated with Crc16CalcBit (bit-wise) 
(crcs of bytes from 00 to ff padded with two bytes 00)
     buf[0] = i;
     CrcLUT[i] = testcrc16(buf, 3) & 0xffff;

crc16_mp is good (with that LUT), always pad with two bytes of 00
// algorithim like this:
    int byte = *buf++;
    int index = (crc>>8) & 0xff;   // index into LUT is top byte of last crc
  	 crc = CrcLUT[index] ^ byte ^ ((crc<<8) & 0xff00);

*/


int printable(unsigned char c){
  if (c>=32 && c<127) return 1;
  return 0;
}

void hexdump(unsigned char *buffer, int len, int bytesperline)
{
  int i,j,p;
  char str_hex[40], str_char[20];
  for(i=0,p=0;p<len;i++){
    printf("%08x: ",p);
    for(j=0;j<bytesperline;j++){ // p<len && 
      if (p<len) {
		  sprintf(str_hex+j*2,"%02x",*(buffer+p));
		  sprintf(str_char+j,"%c",printable(*(buffer+p))?*(buffer+p):'.');
		} else {
		  sprintf(str_hex+j*2,"  ");
		  sprintf(str_char+j," ");
		}
		p++;
	 }
    printf("%s %s\n", str_hex, str_char);
  }
  if (!i%bytesperline) printf("\n");
}

unsigned int Reflect(unsigned int in, int size)
{
	unsigned int out = 0;
   int i;
	for (i = 0; i < size; i++)
	{
		out = (out << 1) | (in & 1);
		in >>= 1;
	}
	return out;
}



long  CrcLUT[256];
int CrcLUTInitFlag = 0;

// The CrcLUT calc is limited to how the algorithim operates (polynomial is backwards and
// LUT calculated that way, algorithim operates by shifting right ... and ...)
void CrcInitLUT(long poly){
  int i,j;
  long crc;
  CrcLUTInitFlag = 1;
  for(i=0;i<256;i++){
     crc = i;
     //crc = Reflect(i,8);
	 for(j=0;j<8;j++){
		//if (i == 0x80) printf("0x80th thing crc is %06x",crc);
		if (crc & 1){
		  crc = (crc >> 1) ^ poly;
		} else {
		  crc = (crc >> 1);
		}
		//if (i == 0x80) printf(", crc is %06x\n",crc);
      crc &= 0xffff;
	 }
	 CrcLUT[i] = crc & 0xffff;
  }
}

long CrcCalc(int len, char *buf){
   long crc = 0; //xffffff; // init 0xffffff for this crc
  int i,index;
  char byte;
  for (i=0;i<len;i++){
	 byte = *buf++;
	 index = (byte ^ crc) & 0xff;
	 crc = (crc >> 8) ^ CrcLUT[index];
  }
  //crc = ~crc & 0xffff; // one's compliment (and 24 bit)
  return crc; 
}




unsigned long crc16_mp(int len, unsigned char *buf)
{
	/*unsigned long crc = 0xFFFF;
	for(int i = len; i > 0; i--)
	{
		unsigned long tmp = (*buf++ ^ crc) & 0xff;
		crc >>= 8;
		crc ^= wCRCTable[tmp];
		printf("i = %d, tmp = 0x%04x, crc = 0x%04x, ~crc = 0x%04x\n", i, tmp, crc, (~crc & 0xffff));
	}
	return crc;*/

   int i;
	unsigned long crc = 0;
	for (i = 0; i < len; i++)
	{
      int byte = *buf++;

      int index = (crc>>8) & 0xff;
		crc = CrcLUT[index] ^ byte ^ ((crc<<8) & 0xff00);

      //int index = (crc ^ byte) & 0xff;
		//crc = ( ((crc >> 8)&0xff) ^ CrcLUT[index]) & 0xffff;

		//crc = ( (crc << 8) ^ CrcLUT[index]) & 0xffff;

		//crc = ( (crc << 8) ^ CrcLUT[(crc ^ *buf++) & 0xff]) & 0xffff;

//		crc = mp_crc16_byte(crc, *buf++);
//		crc = ((crc >> 8) & 0xff) ^ wCRCTable[(crc ^ *buf++) & 0xff];
//		crc = ((crc << 8) & 0xff00) ^ Crc16LUT[(crc ^ *buf++) & 0xff];
//		crc = ((crc >> 8) & 0xff) ^ Crc16LUT[(crc ^ *buf++) & 0xff];
//		unsigned int top_byte = (crc >> 8) & 0xff;
//		crc = (((crc << 8) | *buf++) ^ Crc16LUT[top_byte]) & 0xffff;
//		printf("Crc16LUT[0x%02x] = 0x%04x\n", top_byte, Crc16LUT[top_byte]);

		/*printf("i = %02d, *buf = 0x%02x index = %02x crc = 0x%04x,"
        " ~crc = 0x%04x\n", i , *(buf-1), 
        index, crc, (~crc & 0xffff));*/
	}	
	//return reflect(crc,16);


   //crc = ~crc & 0xffff; // one's compliment (and 24 bit)

	return crc;

}

void CrcShowLUT(){
   int i;

	printf("\nlong CrcLUT[256] = {\n   ");
	for(i=0;i<256;i++) {
	  printf("0x%04x",CrcLUT[i]);
	  if (i<255) printf(", ");
	  if (i%8 == 7) printf("\n   ");
	}
	printf("};\n");

	printf("\n\n// Cute trick. CrcLUT[0x80] is polynomial (backwards)\n");
	printf("\n#define CRC_POLY_BACK 0x%04x\n", Reflect(CRC16_POLY, 16) );
	printf("#define CRC_POLY 0x%04x\n", CRC16_POLY);
}

int LLCCheckCrc(int len, char *llc_buf){
  printf("Check llc crc. ");
  hexdump(llc_buf,len,16);
  long fcs = ~crc_calc(llc_buf,len-3);
  char fcsbuf[3];
  fcsbuf[0] = fcs & 0xff;
  fcsbuf[1] = (fcs>>8) & 0xff;
  fcsbuf[2] = (fcs>>16) & 0xff;
  printf("Received crc   "); hexdump(llc_buf+len-3,3,16);
  printf("Calculated crc "); hexdump(fcsbuf,3,16);
  return (strncmp(fcsbuf,llc_buf+len-3,3) == 0);
}

// bit by bit
// proper divide in bitstream by the poly (bit by bit)
// we don't care about result of divide, the remainder is the crc.
int Crc16CalcBit(int crcpoly, int bitoffset, int bitlen, unsigned char *buf){
  int crc = 0;
  int i,j,index;
  unsigned char byte,fbyte;
  int bit;

//  int rem = 0; // ramainder
  int reg = 0; // register implementation 
  // http://www.repairfaq.org/filipg/LINK/F_crc_v33.html#CRCV_001 

  //printf("crc,byte: ");

  for (i=bitoffset;i<(bitlen+bitoffset);i++){
     byte = *(buf + (i / 8));

     // lsb last
     bit = (byte>>((7-(i%8))))&1;

     fbyte <<= 1; fbyte |= bit;
     //if ( (i-bitoffset ) % 8 == 0) printf("%02x,%02x %02x, ", crc, byte, fbyte);

//     rem <<= 1;
//     rem |= bit;

     int topbit=reg&0x8000;
     reg <<= 1;
     reg |= bit;

     //printf("Byte is 0x%02x, bit is %01d, rem 0x%02x, reg 0x%02x, %d. \n", byte, bit, rem, reg, i);

     if (topbit) {   // if top bit of reg set
        reg=reg&0xffff;
        reg=reg^crcpoly;
     }

//     if (rem >= crcpoly) {
//        rem ^= crcpoly;
//        rem &= 0xffff;
//     } else {
//     }

     //crc = rem;
     crc = reg;

     //printf("i %d bit %d byte %02x reg is 0x%04x, crc is 0x%04x\n", i, bit, byte, reg, crc);
	  /*if (crc == 0xaf97)
	  {
	  		printf("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
	  }*/ 		
  }

  //printf("\n");

  return crc & 0xffff; 
}


unsigned int testcrc16(unsigned char *buf, int bytelen)
{
	unsigned int crc;

	crc = Crc16CalcBit(0x8005, 0, (bytelen*8), buf);
	//printf("crc = 0x%04x\n", crc);
	return crc;
}


void CrcInitLUTUsingBitwise(){
  int i,j;
  long crc;

  unsigned char buf[5] = "\x00\x00\x00\x00";

  CrcLUTInitFlag = 1;
  for(i=0;i<256;i++){
     buf[0] = i;
     crc = testcrc16(buf, 3);
     CrcLUT[i] = crc & 0xffff;
  }
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

	unsigned char big_buf[100] = "\x16\x3d\x8a\x50\x64\xf8\x5b\x81\xea\xc9\x00\x77\x75\x26\xfd\x38\xfb\x3e\xec\x42\x9f\xf3\x9a\x2e\x2a\xd2\x6a\xea\x55\x00\x8d\xd0\x00\x00";
	unsigned char big_buf2[100]= "\x41\x14\x8a\x91\xe4\x02\x45\xa5\xbb\x5a\x80\x17\x40\x7a\x7c\xc3\xcd\xc2\x7a\xe3\x92\x3f\x75\x74\x20\x84\xc9\xc1\xf6\x8c\xfc\x30\x70\x00\x00\x00";

   int crc = 0;


   //CrcInitLUT(CRC16_POLY);
   //CrcInitLUT(CRC16_POLY_BACK);
   CrcInitLUTUsingBitwise();
   CrcShowLUT();


	unsigned long crc_lut = crc16_mp(34, big_buf);
	printf("LUT: crc = 0x%04x, ~crc = 0x%04x, should be 0xaf97\n", crc_lut, (~crc_lut & 0xffff));
	unsigned long crc_bit = testcrc16(big_buf, 34);
	printf("bitwise: crc = 0x%04x, ~crc = 0x%04x, should be 0xaf97\n", crc_bit, (~crc_bit & 0xffff));



	crc_lut = crc16_mp(28, big_buf);
	printf("\nLUT: crc = 0x%04x\n", crc_lut);
	crc_bit = testcrc16(big_buf, 28);
	printf("bitwise: crc = 0x%04x\n", crc_bit);



unsigned char mini_buf0[5] = "\x00\x00\x00\x00";
unsigned char mini_buf1[5] = "\x00\x01\x00\x00";
unsigned char mini_buf2[5] = "\x00\x02\x00\x00";
unsigned char mini_buf3[5] = "\x01\x00\x00\x00";
unsigned char mini_buf4[5] = "\x80\x00\x00\x00";
unsigned char mini_buf5[5] = "\x02\x00\x00\x00";

printf("\n\n\n");
printf("\nmini_buf0000\n");
crc = testcrc16(mini_buf0, 4);
printf("bitwise -> crc = 0x%04x\n", crc);
crc = crc16_mp(2,mini_buf0);
printf("lut -> crc = 0x%04x\n", crc);

printf("\nmini_buf0001\n");
crc = testcrc16(mini_buf1, 4);
printf("bitwise -> crc = 0x%04x\n", crc);
crc = crc16_mp(4, mini_buf1);
printf("lut pad2 -> crc = 0x%04x\n", crc);

printf("\nmini_buf0002\n");
crc = testcrc16(mini_buf2, 4);
printf("bitwise -> crc = 0x%04x\n", crc);
crc = crc16_mp(4, mini_buf2);
printf("lut -> crc = 0x%04x\n", crc);

printf("\nmini_buf0100\n");
crc = testcrc16(mini_buf3, 4);
printf("bitwise -> crc = 0x%04x\n", crc);
crc = crc16_mp(4, mini_buf3);
printf("lut -> crc = 0x%04x\n", crc);

printf("\nmini_buf0200\n");
crc = testcrc16(mini_buf5, 4);
printf("bitwise -> crc = 0x%04x\n", crc);
crc = crc16_mp(4, mini_buf5);
printf("lut -> crc = 0x%04x\n", crc);

printf("\nmini_buf8000\n");
crc = testcrc16(mini_buf4, 4);
printf("bitwise -> crc = 0x%04x\n", crc);
crc = crc16_mp(4, mini_buf4);
printf("lut -> crc = 0x%04x\n", crc);




}

