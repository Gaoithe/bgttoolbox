// https://stackoverflow.com/questions/40116073/c-duplicate-character-character-by-character
#include <stdio.h> // printf
#include <ctype.h> // ispunct

int main() {

  char ch,ch2;
  ch = getchar(); // does not get the line of text, just gets one char
  int i = 1;
  printf("ch2 not init is:%02x %c\n",ch2,ch2);
  ch2 = 0; // for the first iteration of loop
  printf("ch2[&ch]:%p:%02x\n",&ch,ch2[&ch]);
  printf("ch2[&ch2]:%p:%02x\n",&ch2,ch2[&ch2]);

  while (ch != '\n') // the loop will close if nothing entered
  {
    if (ch == ch2) {// change from ch2[&i] - wow :-) very confused!
        printf("%c-duplicate", ch);
    }
    i++;
    if (ch == 'A' || ch == 'E' || ch == 'I' || ch == 'O' || ch == 'U') { // checking for uppaercase vowel
        printf("%c-upper case vowel", ch);
    }
    else if (ch == 'a' || ch == 'e' || ch == 'i' || ch == 'o' || ch == 'u') { // checking for lowecase vowel
        printf("%c-lower case vowel", ch);
    }
    else if (ispunct(ch)) {          // checking for punctuation
        printf("%c-punctuation", ch);
    }
    else
        putchar(ch);

    // FIX the indentation!
    printf("\n");
    ch2 = ch; // set ch2 to the last char read before reading new
    ch = getchar(); // read one new char
  }
  printf("\n");

  printf("ch2[&ch]:%p:%02x\n",&ch,ch2[&ch]);
  printf("ch2[&ch2]:%p:%02x\n",&ch2,ch2[&ch2]);
  for(i=0;i<10;i++)  
    // c/so_cq_char_v2.c:39:52: error: subscripted value is neither array nor pointer nor vector
    //printf("i:%d ch2[i]:%02x ch2[&i]:%02x\n",i, ch2[i], ch2[&i]);
    printf("i:%d ch2[&i]:%p:%02x\n",i,&i,ch2[&i]);
  printf("ch2[&i]:ch2=%02x:p=%p:%02x\n",ch2,&i,ch2[&i]);
  printf("ch2[&ch]:ch2=%02x:p=%p:%02x\n",ch2,&ch,ch2[&ch]);
  printf("ch2[&ch2]:ch2=%02x:p=%p:%02x\n",ch2,&ch2,ch2[&ch2]);
  //printf("ch2[&main]:%02x\n",ch2[&main]);
  //printf("ch2[&printf]:%02x\n",ch2[&printf]);

  printf("END\n");

  return 0;
}

