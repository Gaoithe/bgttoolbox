/*

   // INTERPRET escstr and charstr - just convert \" to " for now 
    // should interpret: \\ \" \' \n \r \b \t \f \a \v \? %% \ooo \hxx
    char *cstr = tbx_string_interpret(charstr);
    char *estr = tbx_string_interpret(escstr);
    FREE(cstr);
    FREE(estr);


http://en.wikipedia.org/wiki/C_syntax#Backslash_escapes

If you wish to include a double quote inside the string, that can be done by escaping it with a backslash (\), for example, "This string contains \"double quotes\".". To insert a literal backslash, one must double it, e.g. "A backslash looks like this: \\".

Backslashes may be used to enter control characters, etc., into a string:

Escape	Meaning
\\	Literal backslash
\"	Double quote
\'	Single quote
\n	Newline (line feed)
\r	Carriage return
\b	Backspace
\t	Horizontal tab
\f	Form feed
\a	Alert (bell)
\v	Vertical tab
\?	Question mark (used to escape trigraphs)
%%	Percentage mark, printf format strings only (Note \% is non standard and is not always recognised)
\ooo	Character with octal value ooo
\xhh	Character with hexadecimal value hh
The use of other backslash escapes is not defined by the C standard, although compiler vendors often provide additional escape codes as language extensions.

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int CTOHEX(char c, int vi){
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    else if (c >= 'a' && c <= 'f') {
        return 0xa + (c - 'a');
    } 
    else if (c >= 'A' && c <= 'F') {
        return 0xa + (c - 'A');
    } else {
        if (vi==0) {
            printf("syntax error, non-hex char 0x%02x '%c'\n",c,c);
        }
        return -1;
    }
}

int CTOOCT(char c){
    if (c >= '0' && c <= '7') {
        return c - '0';
    } else {
        printf("syntax error, non-octal char 0x%02x '%c'\n",c,c);
        return -1;
    }
}

char *interpret_c_str(char *s, int *rv)
{
  char *p1 = malloc(strlen(s)+1);
  char *p2 = p1;
  int v,v1,vi;
  *rv = 0;
  while (*s) {
    if (*s != '\\') {
      // copy next char back
      *p2++ = *s++;
    } else {
      // skip slash
      s++;
      switch(*s) {
      case '\\':
	*p2++ = '\\';
	break;
      case '\"':
	*p2++ = '\"';
	break;
      case '\'':
	*p2++ = '\'';
	break;
      case 'r':
	*p2++ = '\r';
	break;
      case 'n':
	*p2++ = '\n';
	break;
      case 'b':
	*p2++ = '\b';
	break;
      case 't':
	*p2++ = '\t';
	break;
      case 'f':
	*p2++ = '\f';
	break;
      case 'a':
	*p2++ = '\a';
	break;
      case 'v':
	*p2++ = '\v';
	break;
      case '?':
	*p2++ = '?';
	break;
      case 'x':
	// read hex digits and convert
	// max of 2 digits allowed
	s++; 
	v = 0;
        v1=CTOHEX(*s++,0);
        if (v1==-1) { *rv=-1; break; }
        v*=16;
        v+=v1;
        v1=CTOHEX(*s,1);
        if (v1==-1) { 
            // not a hex char, single digit
        } else {
            v*=16;
            v+=v1;
            s++;
        }
	/*vi=0;
	while ((v1=CTOHEX(*s++,vi)) > 0) {
            if (vi==0 && v1==-1) { *rv=-1; break; }
            v*=16;
            v+=v1;
            vi++;
	}
	s--;*/
	s--;
	*p2++ = v;
        printf ("DEBUG HEX:%x\n",v);
	break;
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
	// read octal digits and convert
	// max of 3 digits allowed
	v=v1=CTOOCT(*s++);
	v*=8;
	v+=v1=CTOOCT(*s);
        if (v1==-1) { *rv=-1; break; } else { s++; }
	v*=8;
	v+=v1=CTOOCT(*s);
        if (v1==-1) { *rv=-1; break; } else { s++; }
	s--;
	*p2++ = v;
        printf ("DEBUG OCT:%x\n",v);
	break;
      case 0:
	printf("syntax error, solo slash at end of string\n");
	*p2++ = 0;
        s--;
        *rv=-1; // error
	break;
      default:
	*p2++ = *s;
      }
      s++;
    }
  }
  // copy terminating char
  *p2 = *s;
  return p1;
}

int main(int argv, char **argc) 
{
  char *s[9][3] = {
      { "\\\"", "\"", "", },
      { "abcd efgh", "abcd efgh", "",},
      { "abcd efgh\\r\\n", "abcd efgh\r\n", "",},
      { "slash \\\\ dquote \\\" squote \\\' CRLF \\r\\n", "slash \\ dquote \" squote \' CRLF \r\n", "",},
      { "BS \\b TAB \\t FF \\f BELL \\a VTAB \\v Q? \\? HEXQuote \\x22 OCTQuote \\042", "BS \b TAB \t FF \f BELL \a VTAB \v Q? \? HEXQuote \x22 OCTQuote \042", "",},
      { "\\\\\\\"\\\'\\r\\n\\b\\t\\f\\a\\v\\?\\xa\\xab\xcd\\xefghij\\042\\111\\x22\\\\\\\"\\\'\\r\\n", "\\\"\'\r\n\b\t\f\a\v\?\xa\xab\xcd\xefghij\042\111\x22\\\"\'\r\n", "",},
      { "oct too short \\07", "", "meh", },
      { "oct too short(chars 8,9 invalid in oct) \\089 meh", "", "meh", },
      { "hex too long \\xabc", "hex too long \xab""c", "", },   
      // actually not detected as an error - interpreted as \xab followed by 'c'.  
      // in gcc though you get "hex escape sequence out of range" error
      // in gcc "\xab\c" gives you warning: unknown escape sequence: '\c'
      // in gcc "\xab" "c" gives you \xab followed by char c without warning or error 
  };

/*
/home/james/c/interpret_c_str.c:173:98: warning: hex escape sequence out of range [enabled by default]
     "\\\\\\\"\\\'\\r\\n\\b\\t\\f\\a\\v\\?\\xa\\xabcd\\xefghij\\042\\111\\x22\\\\\\\"\\\'\\r\\n", "\\\"\'\r\n\b\t\f\a\v\?\xa\xabcd\xefghij\042\111\x22\\\"\'\r\n",
                                                                                                  ^                           #### max of 2 hex chars.
*/

  int i,rv;
 
  for(i=0;i<6;i++) {
    printf("%50s ### %s\n",s[i][1],s[i][0]);
  }

  for(i=0;i<6;i++) {
      char *si = interpret_c_str(s[i][0],&rv);
      if (rv==-1 && s[i][2][0] != 0) {
          printf("FAIL :-( syntax error in string\n");
      }
      
      printf("%5s ### %50s ### %s\n", 
             strcmp(s[i][1],si)?"FAIL":"PASS",
             s[i][1],
             s[i][0]
          );
      
      if (strcmp(s[i][1],si)) {
          // fail info
          int j;
          for(j=0;j<strlen(s[i][1]);j++) {
              if (s[i][1][j] != si[j]) {
                  printf("char %d no match: expected %02x != %02x\n", j, s[i][1][j], si[j]);
              }
          }
      }
      
  }


  for(i=6;i<9;i++) {
      char *si = interpret_c_str(s[i][0],&rv);
      if (rv==-1 && s[i][1][0] != 0) {
          printf("FAIL :-( unexpected syntax error in string\n");
      } else if (rv==-1) {
          printf("PASS. expected a syntax error in string\n");
      } else {
          // PASS. no error expected and no error happened.
      }
      
      printf("%5s ### %50s ### %s\n", 
             (rv==-1 && s[i][1][0] != 0)?"FAIL":"PASS",
             s[i][1],
             s[i][0]
          );      
  }
  
}
