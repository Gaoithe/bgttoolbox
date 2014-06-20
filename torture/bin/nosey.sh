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
      echo "Hello Daire"
     else
      if  (($TIME < 10))
       then 
          date +"It's the %a the %d of %h in 19%y  (day %j of the year)"
       else 
          echo "feh"
       fi
     fi
   fi
 fi
