#!/bin/bash

if [[ ("$1" == "") || ("$2" == "") ]] ; then
  echo "usage: rename <AppName> <Long App Name>"
  echo James, Jul 2003
  read
  exit
fi

sed "s/testtemp/$1/g" testtemp.c | sed "s/Test Template/$2/g" > $1.c 
sed "s/testtemp/$1/g" testtemp.h | sed "s/Test Template/$2/g" > $1.h 
sed "s/testtemp/$1/g" testtempRsc.h | sed "s/Test Template/$2/g" > $1Rsc.h 
sed "s/testtemp/$1/g" testtemp.rcp | sed "s/Test Template/$2/g" |sed "s/TestTemp/$1/g" > $1.rcp 
mv Makefile Makefile.old
sed "s/testtemp/$1/g" Makefile.old | sed "s/Test Template/$2/g" > Makefile 

mv testtemp.pbm $1.pbm
#mv testtemp.c $1.c
#mv testtemp.h $1.h
#mv testtempRsc.h ${1}Rsc.h
#mv testtemp.rcp $1.rcp
rm testtemp.c testtemp.h testtempRsc.h testtemp.rcp Makefile.old


