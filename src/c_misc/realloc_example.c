/* realloc example: rememb-o-matic */
#include <stdio.h>      /* printf, scanf, puts */
#include <stdlib.h>     /* realloc, free, exit, NULL */

int main ()
{
  int input,n;
  int count = 0;
  int* numbers = NULL;
  int* more_numbers = NULL;
  int* porig = NULL;
  int* p = NULL;
  int* m = NULL;

  do {
      //printf ("Enter an integer value (0 to end): ");
      //scanf ("%d", &input);
      input = count + 1;
     count++;
     //if (count % 100 == 0) printf("count=%d %p %p %p\n",count,numbers,m,p);
     //if (count % 100 == 0) printf(".");

     more_numbers = (int*) realloc (numbers, count * sizeof(int));

     ////if (m!=NULL) free(m);
     //m = (int*) malloc(100);
     ////if (p!=NULL) p = (int*) realloc(p,count * sizeof(int));
     

     if (more_numbers!=NULL) {
       numbers=more_numbers;

       if (porig != numbers) {
           printf("REALLOC ptr change old=%p new=%p count=%6d\n",porig,numbers,count);
           porig=numbers;
       }

       numbers[count-1]=input;
     }
     else {
       free (numbers);
       if (m!=NULL) free(m);
       if (p!=NULL) free(p);
       puts ("Error (re)allocating memory");
       exit (1);
     }

     //if (m!=NULL) free(m);

  } while (input!=0);

  printf ("Numbers entered: ");
  for (n=0;n<count;n++) printf ("%d ",numbers[n]);
  free (numbers);

  return 0;
}

/* http://www.cplusplus.com/reference/cstdlib/realloc/
[james@nebraska c]$ gcc realloc_example.c -o realloc_example
[james@nebraska c]$ ./realloc_example 
REALLOC ptr change old=(nil) new=0x8bd8008 count=     1
REALLOC ptr change old=0x8bd8008 new=0xb7741008 count= 33788
REALLOC ptr change old=0xb7741008 new=0xb7713008 count= 33790
REALLOC ptr change old=0xb7713008 new=0xb773f008 count= 34814
REALLOC ptr change old=0xb773f008 new=0xb7711008 count= 35838
REALLOC ptr change old=0xb7711008 new=0xb773d008 count= 36862
REALLOC ptr change old=0xb773d008 new=0xb770f008 count= 37886
REALLOC ptr change old=0xb770f008 new=0xb773b008 count= 38910
REALLOC ptr change old=0xb773b008 new=0xb770d008 count= 39934
REALLOC ptr change old=0xb770d008 new=0xb7739008 count= 40958
REALLOC ptr change old=0xb7739008 new=0xb770b008 count= 41982
REALLOC ptr change old=0xb770b008 new=0xb7737008 count= 43006
REALLOC ptr change old=0xb7737008 new=0xb7709008 count= 44030
REALLOC ptr change old=0xb7709008 new=0xb76dc008 count= 45054
REALLOC ptr change old=0xb76dc008 new=0xb7682008 count= 91134
REALLOC ptr change old=0xb7682008 new=0xb75ce008 count=183294
REALLOC ptr change old=0xb75ce008 new=0xb7466008 count=367614
REALLOC ptr change old=0xb7466008 new=0xb7196008 count=736254
REALLOC ptr change old=0xb7196008 new=0xb6bf6008 count=1473534
REALLOC ptr change old=0xb6bf6008 new=0xb60b6008 count=2948094
REALLOC ptr change old=0xb60b6008 new=0xb4a36008 count=5897214
REALLOC ptr change old=0xb4a36008 new=0xb1d36008 count=11795454
REALLOC ptr change old=0xb1d36008 new=0xac336008 count=23591934
REALLOC ptr change old=0xac336008 new=0xa0f36008 count=47184894


REALLOC ptr change old=0xa0f36008 new=0x8a736008 count=94370814
REALLOC ptr change old=0x8a736008 new=0x5d736008 count=188742654
Error (re)allocating memory
*/
