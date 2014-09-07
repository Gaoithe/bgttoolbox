// SudokuHint.h
int helpstatus;
sudokuHint(){ int h; 
 h=(helpstatus++)%5;
 if (h==0) 
 alert("Sudoku rules: Each row, column or 3x3 group of squares must contain each of the numbers from 1 to 9. That's all. [h] again for more hints/help/info. If I say [h] I mean type a 'h' into the Grafitti[tm] area.");
 if (h==1) 
 alert("This Sudoku solver is a funny one but more interesting maybe. You can load/save sudokus and type them in. You can solve them yourself (with a little help) or can try a couple of solver algorithms.\n[h] again for more");
 if (h==2) {
 alert("Select a square by tapping and enter a number by typing it in the numeric Grafitti[tm] area. If it is really obviously impossible the number will not be allowed and you will get a rude noise instead."); alert("When a square is selected two masks are shown. In hex. One mask for possible values. The other for values it cannot be. Masks are based on the simple sudoku rules (only depend on the 3 grps the square is in). "); alert("Bit 0 is for number 1, up to bit 8 for number 9. E.g. 1ff means all numbers possible (or impossible if not mask(actually impossible of course yes!)) 040 would mean that square must be a 7 (or must not be 7 if not mask)."); alert("Should I explain hex? Maybe I should display it more intuitively.\n[h] again for more"); }
 if (h==3) {
 alert("[h] for hint/help/info. I think you know this by now.\n[c] for clear\n[w] for write sudoku to memo TODO name and load back in\n[W][X][Y] run a different sudoku solving ruleset TODO name and describe\n "); alert("[l][m][o] load 3 default sudokus. TODO: load named sudokus from memo or pdb files (select name from drop-down list.\n "); alert("TODO prefs, various levels of help, run algos on one or selected group or square, undo tree, history & playback, stats how difficult + how much cpu or diff algos used\n[h] again for more");
alert("TODO move r/l u/d with !|_<>[]{}() or button. TODO Display name. TODO Display maybe/not mask. TODO Sel grp/sq. TODO when load make nums bold.");
 }
 if (h==4) alert("http://www.dspsrv.com/~jamesc/palm/\n[h] again for 1st hint");
}
