// SudokuSolve.h

int solveCtr;
int onebit; // if one bit set this is it's pos
int bits(int mask){
   int i; int bc; bc=0;
   for(i=0;i<12;i++) {
      if (mask & 1) { bc++; onebit=i; }
      mask = mask >> 1;
   } return bc;
}

//for every box if our maybe mask
// shows only 1 possibility then set it
void solveW(){ solveCtr=0;
  for(i=0;i<9;i++) {
  for(j=0;j<9;j++) {
   idx=i+j*9;
   if(sudoku[idx]==0){
    if(bits(maybe[idx])==1){
      solveCtr++;
      setFocusOnBox(1,i,j);
      setBox(i,j,onebit+1);
      setFocusOnBox(0,i,j);
  }}}}
}

//for each group
// if maybe for squares is limited
// e.g. 12 and 12 and 123 in other
// square then other must be 3
// e.g. 123 12 13 and 1234 
// then last must be 4
void solveX(void){ 
   // could do this better with callback
   // use func ptr
   // 1st case only - 2 boxes same 2 ns
   int gp,i,j,ki,kj; 
   int iidx,jidx,kidx; int b; solveCtr=0;
  for(gp=0;gp<27;gp++) {
  if (grpfin[gp]!=0x1ff) {
 //puts("grp "+ gp);
  for(i=0;i<9;i++) {
   iidx=grp[gp*9+i];
 //puts(" idx "+iidx);
   if(sudoku[iidx]==0){
   b=bits(maybe[iidx]);
  if(b==2){
  for(j=0;j<9;j++) {
   jidx=grp[gp*9+j];
   if(j!=i && sudoku[jidx]==0){
     if(maybe[iidx] == maybe[jidx]){
     // all other boxes in grp
     // mask out the maybe

//puts("match j"+jidx+ "-"+hexmask(maybe[iidx],16,3)); 
  for(ki=0;ki<9;ki++) {
   kidx = grp[gp*9+ki];
   if(sudoku[kidx]==0 && kidx!=iidx && kidx!=jidx) { solveCtr++;
      setFocusOnBox(1,kidx/9,kidx%9);
//puts(" kx"+kidx+"-"+ hexmask(maybe[kidx],16,3)+"."); 
updOne(1,kidx, maybe[iidx],  0x1ff ^maybe[iidx]);
if(bits(maybe[kidx])==1) {
  setBox(kidx%9,kidx/9,onebit+1);
}
//puts(" kx"+kidx+"-"+ hexmask(maybe[kidx],16,3)+"."); 
}}}}}}}}
}}//gp
}

// for every grp, for every box
//  if our maybe mask is the only 
// one possible for a num then set it
void solveY(){ 
   int gp,i,j,gpmaybe; 
   int iidx,gidx; int idx[9]; int ct[9];
   solveCtr=0; //dumpgrp();
  for(gp=0;gp<27;gp++) {
  //puts("gp"+gp+" gpfin" +hex(grpfin[gp]));
  if (grpfin[gp]!=0x1ff) {
  gpmaybe=0; 
  gidx=grp[gp*9+0];
  setFocusOnBox(1,gidx%9, gidx/9);
  for(i=0;i<9;i++) { ct[i]=0; }
  for(i=0;i<9;i++) { // each box
    iidx=grp[gp*9+i];
    gpmaybe = gpmaybe | maybe[iidx];    //alert("gp:"+gp+" box:"+i+"gpi:"+(gp*9+i)+"idx: "+iidx+" mb:" +hex(maybe[iidx]));
      for(j=0;j<9;j++) {
      if(maybe[iidx] & (1<<j)) {
         //puts(" j "+(j+1) );
         ct[j]++;
         idx[j]=iidx; 
        //rem idx this as may be the only one
       }}} // if j i
    //puts("\n");
    for(i=0;i<9;i++) { // each box
    //if(gp>17) alert("idx:"+idx[i]+" num:"+ (i+1) +" ct:"+ct[i]);
    if(sudoku[idx[i]]==0 && ct[i]==1) {
      solveCtr++;
      setBox(idx[i]%9, idx[i]/9, i+1);
    }
}
  //puts("grp "+gp+"idx"+gidx+"-"+iidx+" mb "+gpmaybe +" solve " +solveCtr +"\n");
  setFocusOnBox(0,gidx%9, gidx/9);
  //return; //exit after 1 grp 4 dbg
  }} //gp
}

//TODO must be 1 of 2 in 1 grp
// so rule out of rest
//         200143000
// e.g  0005x7000
//         0008x9000
//         0000n0000
//         0000n0000
// one of x must be 2 so n can't be

// nihongo . . . Pitagora sui-chi

// return 0: done and valid, 1: not done and valid so far, -1*(i+j*9): invalid@i,j - first i,j found, -NEGother
int validateSudoku(){
  // check all numbers filled, all numbers from 1-9 (or 0 for unfilled)
  // foreach box check horiz line, vert line, 3x3 group for duplicate
  int done=1;
  int rc=0;
  char value;
  int x,y;

  for(i=0;i<9;i++) {
  for(j=0;j<9;j++) {
   idx=i+j*9;
   value = sudoku[idx];
   if(value<0 || value>9){
       rc = -2*(i+j*9);
       printf("bad content @%i,%i\n",i,j);
       return rc;
   } else if(sudoku[idx]==0){
       done = 0;
       rc = 1;
       printf("not done @%i,%i, ",i,j);
   } else {
       // horiz line
       for(x=0;x<9;x++) {
          if (x==i) break;
          if(sudoku[x+j*9] == value){
              rc = -10000;
              printf("duplicate on h line @%i,%i and %i,%i\n",i,j,x,j);
              return rc;
          }
       }
       // vert line
       for(y=0;y<9;y++) {
          if (y==j) break;
          if(sudoku[i+y*9] == value){
              rc = -10000;
              printf("duplicate on v line @%i,%i and %i,%i\n",i,j,i,y);
              return rc;
          }
       }
       // 3x3 group box
       int xoff=(i/3)*3;
       int yoff=(j/3)*3;
       for(x=0;x<3;x++) {
       for(y=0;y<3;y++) {
          if (x+xoff==i && y+yoff==j) break;
          if(sudoku[x+xoff+(y+yoff)*9] == value){
              rc = -10000;
              printf("duplicate in 3x3 box @%i,%i and %i,%i\n",i,j,x+xoff,y+yoff);
              return rc;
          }
       }}
   }
  }}
  printf("VALID\n");
  return rc;
}
