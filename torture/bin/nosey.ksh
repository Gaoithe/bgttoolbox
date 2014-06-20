#!/bin/bash

TIME=`date +%S`
if [[ $TIME = 00 ]]
 then 
  echo "Hi";
 else
  if [[ $TIME = 01 ]]
   then 
    echo "Goedendag";
   else
    if (($TIME < 7))
     then 
      /home/jcoleman/util/poet/ep
     else
      if  (($TIME < 10))
       then 
        /home/jcoleman/util/poet/quotes /home/jcoleman/util/poet/trek.dat
       else
        if  (($TIME < 12)) 
         then 
          date +"It's the %a the %d of %h in 19%y  (day %j of the year)"
         else
          if  (($TIME < 20))
           then 
            /home/jcoleman/c/yow -f /home/jcoleman/c/personal.lines
           else
            if  (($TIME < 30)) 
             then 
              /home/jcoleman/c/yow -f /home/jcoleman/info
             else
              if  (($TIME < 45)) 
               then 
                /home/jcoleman/c/yow -f /home/jcoleman/c/misc.lines
               else
                  if  (($TIME < 50)) 
                   then 
                    /home/jcoleman/c/yow -f /home/dfrench/bin/smiley
                   else
                    /home/jcoleman/c/yow
                  fi
               fi
             fi
           fi
         fi
       fi
     fi
   fi
 fi
