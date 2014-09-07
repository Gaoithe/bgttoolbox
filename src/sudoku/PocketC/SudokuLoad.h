// SudokuLoad.h

writeit(string file){ int j9; int ok; ok=1;
if(!mmfind(file)) {
  if(ok=mmnew()){
   mmputs(file);mmputs("\n"); // filename
  }
}
//if(mmfind(file) || mmnew(file)){
if(ok){
   mmputs("\nit=\"");
  for(j=0;j<9;j++) { j9=j*9;
  for(i=0;i<9;i++) {
    mmputs((char) (sudoku[i+j9]+'0'));
  }mmputs("\n");}
   mmputs("\";\n");
   mmclose();
}}

loadit(string it){ int j10; char c; int s;
  init(); initgrps();
  drawSudokuBackground();
  font=1;
  //setBox(3,1,9); //y,x 
  for(j=0;j<9;j++) { j10=j*10;
  for(i=0;i<9;i++) {
    c=substr(it,i+j10,1);
    s=c-'0';
    if(s)setBox(i,j,s);
  }}   font=0;
}

load(){
  string it;
  it="000000000\
 000902000\
 069708140\
 200000004\
 900654008\
 050000030\
 300090007\
 027000510\
 090517020\
";
 loadit(it);
}

load1(){
  string it;
  it="000000001\
 003009060\
 004851000\
 090500106\
 008000050\
 060300807\
 005163000\
 001007020\
 000000009\
";
 loadit(it);
}

load2(){
  string it;
  it="000000000\
 000902000\
 069708140\
 200000004\
 900654008\
 050000030\
 300090007\
 027000510\
 090517020\
";
 loadit(it);
}

load3(){ //it hard 10092005
  string it;
  it="800506003\
 000000000\
 109804205\
 280000059\
 000708000\
 040090030\
 400000006\
 005201400\
 700000008\
";
 loadit(it);
}

load4(){ //it hard 10092005
  string it;
  it="000006095\
 000450002\
 000103400\
 070000006\
 208000704\
 900000050\
 007302000\
 300094000\
 680500000\
";
 loadit(it);
}

