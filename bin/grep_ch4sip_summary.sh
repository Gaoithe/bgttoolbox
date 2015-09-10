#!/bin/bash
grep -A1 -E "   : (INVITE sip:|From: |History-Info)" cause_487_change.ch4 |sed "s/.*   : //" |grep -vE "^--$|Call-ID" |grep -A4 ^INVITE |
   sed -r "s/^(INVITE|History-Info|From|To):* <*sip:(.*)\@.*/\1: \2 PU/;s/^\s+<*sip:<*([^;>]*)(.*)cause=([^;>]*).*/hist=\1 cause=\3/" |
   sed ':a;N;$!ba;s/PU\n/ /g;'|grep -v ^--$
