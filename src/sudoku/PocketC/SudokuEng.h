// SudokuEng.h

// TODO BUG UNdo not work
updOne(int un, int ki, int maskin, int maskout){
  updGrp(un,ki,maskin, maskout);
  if(un){
   maybe[ki] = maybe[ki] & maskout;
   not[ki] = not[ki] | maskin;
  } else {
   maybe[ki] = maybe[ki] | maskin;
   not[ki] = not[ki] & maskout;
  }
}

updMaybeNot(int i, int j, int v, int un){
   //also handles v=0 clear
   int k,ki,kj,kg,kgx,kgy; int gx,gy;
   int maskin,maskout;
   int idx; idx=i+j*9;
   maskin = 1 << (v-1); 
   maskout = 0x1ff ^ maskin;
   if(un && v!=0) {
     maybe[idx]=maskin;
     not[idx]=maskout;
  } else { // TODO
     //not[idx]=0;
     //maybe[idx]=0x1ff;
  }
  gx = 3 * (i/3); gy  = 3 * (j/3); //blk
  for(k=0;k<9;k++) {
  // groups: horiz, vert, block 
    if (k!=i) { ki = k+j*9;
      updOne(un, ki, maskin, maskout);
    }
    if (k!=j) { kj = i+k*9;
      updOne(un, kj, maskin, maskout);
    }
    kgx = gx+(k%3);
    kgy = gy+(k/3);
    kg = kgx+9*kgy;
    if (i!= kgx && j!=kgy){ 
      updOne(un, kg, maskin, maskout);
    }
  }
}

setBox(int i, int j, char v){
  if (valid(i,j)){ idx=i+j*9;
  //don't allow if simple not
  // this is quite imperfect but prevents really obvious mistakes
  if (not[idx] & (1<<(v-1))) {
    tone(4000,100);
    return;
  }
  if(sudoku[idx]) updMaybeNot(i,j,sudoku[idx],0);
  sudoku[idx]=v;
  textattr(font, 1, 0);
  if (!v) textattr(font, 0, 0);
  text(25+i*12,21+j*12,(int)v);
  if (!v) textattr(font, 1, 0);
  // upd maybe|not for all groups
  // make optional, calc effort
  updMaybeNot(i,j,(int)v,1);
  }
}
