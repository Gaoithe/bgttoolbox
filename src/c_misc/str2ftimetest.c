#include <time.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    /* 2. If you want to check the time interval between 18:30 and 6:30, you can do it this way: */
    time_t t;
    struct tm *tm;
    static char ts1[1024];
    static char ts2[1024];

    time(&t);
    tm = localtime(&t);

    /* strftime(ts, sizeof(ts)-1, "%a, %d %b %Y %H:%M:%S %z", tm); */
    /* strftime(ts1, sizeof(ts1)-1, "%u", tm); */
    strftime(ts1,sizeof(ts1)-1,"%u",tm);
    strftime(ts2,sizeof(ts2)-1,"%H%M",tm);
    //strftime(ts, sizeof(ts)-1, "%a, %d %b %Y %H:%M:%S %z", tm);

    printf("After %s? %d, ","0630",strcmp(ts2,"0630"));
    printf("Before %s? %d\n","1830",strcmp(ts2,"1830"));

    /* IF on weekday, out of working hours . . . */
    if ((atoi(ts1) >= 1) &&
	(atoi(ts1) <= 5) && 
	((strcmp(ts2,"0630") < 0) || 
	 (strcmp(ts2,"1830") > 0))){
	printf("true. day of week=%s, HHMM=%s\n",ts1,ts2);
    }
    printf("day of week=%s, HHMM=%s\n",ts1,ts2);

    return 0;
}

/* 
 * From: Jan Jirmasek [mailto:jan.jirmasek@openmindnetworks.com] 
 * Sent: Tuesday, September 24, 2013 11:17 AM
 * To: Fajar Cahyadi
 * Cc: OpenMind Networks CS
 * Subject: Re: [TRQ#0109964] Using Protect to block i [...]
 *  
 * Hi Fajar,
 * 
 * yes, you can be more specific in the protect condition expression. Let's say, you want to match all the messages being processed by the platform between 6pm and 8am during Monday to Friday:
 * 
 * ((str2int(strftime("%u",time(),0)) >= 1) && (str2int(strftime("%u",time(),0)) <= 5) && ((str2int(strftime("%H",time(),0)) >= 18) || (str2int(strftime("%H",time(),0)) < 8)))
 * 
 * The %u returns number of the day within week [1..7], where Mon = 1 ... Sun = 7. The %H returns the current hour [0..23].
 * 
 * Again, please, watch out for the third parameter in strftime() function ... the zero means UTC.


What language isthat? c? Python?
from time import strftime,localtime
print int(strftime("%u"))
t=localtime()
if ((int(strftime("%u",t)) >= 1) and
    (int(strftime("%u",t)) <= 5) and
    ((strftime("%H%M",t) >= "0630") or
     (strftime("%H%M",t) < "1830"))):
    print "true"


 */



/* Find multi-line ifs:
 * find . -name *.c -exec grep -A4 "\bif\b[^)]*$" {} \;
 * 
*/
