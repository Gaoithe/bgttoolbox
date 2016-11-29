// https://stackoverflow.com/questions/40116073/c-duplicate-character-character-by-character
void main() {

char ch,ch2;
ch = getchar(); // getting the line of text
int i = 1;
ch2 = ch;

while (ch != '\n') // the loop will close if nothing entered
{
    if (ch == ch2[&i]) {
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
        printf("\n");
        ch = getchar();
    }
    printf("\n");
}

