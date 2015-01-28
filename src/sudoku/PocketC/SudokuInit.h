// SudokuInit.h

#include "pocketc.h"

init(){oldi=oldj=-1;
  for(i=0;i<9;i++) {
  for(j=0;j<9;j++) {
  sudoku[i+j*9]=0;
  maybe[i+j*9]=0x1ff;
  not[i+j*9]=0;
  }}
}

dumpgrp(){ int gp,i,iidx;
 for(gp=18;gp<27;gp++) {
  //if (grpfin[gp]!=0x1ff) {
     //puts("\ngrp:"+ gp);
  for(i=0;i<9;i++) {
   iidx=grp[gp*9+i];
   //puts(" gi:"+(gp*9+i)+" idx:"+iidx);
  }}
}

initgrps(){
   int gi,gj,gt; // group, grp type
   int i,j; int gp,gidx; 
  for(gp=0;gp<27;gp++) {
    grpfin[gp]=0; //mask 1ff done
  }
  for(gi=0;gi<9;gi++) {
  for(gj=0;gj<9;gj++) {
    gt=0; gidx=gi*9+gj;
    grp[0+gidx]=gidx;
    gt=1;
    grp[81+gidx]=gi+9*gj;
    gt=2;
    grp[162+gidx]=((gi%3)*3) + ((gi/3)*27)+9*(gj/3) + (gj%3);
  }}
  //dumpgrp();
}

updGrp(int un, int ki, int maskin, int maskout){ int i,j,gi,gj; 
  int gpx,gpy,gpb;
  i=ki%9; j=ki/9; gi=j; gj=i;
  gpx=gi; gpy=9+gj; gpb=18+3*(gi%3)+(gj%3);
  //gpx=gi*9+gj;
  //gpy=81+gpx; gpb=81+gpy;
  if(un){
grpfin[gpx] = grpfin[gpx] & maskout;
grpfin[gpy] = grpfin[gpy]  & maskout;
grpfin[gpb] = grpfin[gpb]  & maskout;
  } else {
grpfin[gpx] = grpfin[gpx] | maskin;
grpfin[gpy] = grpfin[gpy]  | maskin;
grpfin[gpb] = grpfin[gpb]  | maskin;
  }

}

ctext(int x, int y, string s, string c){
   textattr(0, 0, 0);
   text(x, y, c);
   textattr(0, 1, 0);
   text(x, y, s);
}
