#include <stdlib.h>     /* atoi */

/*
// atoi.h
int atoi_O(string s,int b){
 int i,r,p; char c; string a; r=0;
 a=strlwr(s);
 for(i=0;i<strlen(a);i++){
  r=r*b;
  c=substr(a,i,1); p=(int)c;
  if (p>0x60){//>a
   r=r+p-87; //0x61-10
  } else { r=r+p-0x30; }
 }
 return r;
}
*/
