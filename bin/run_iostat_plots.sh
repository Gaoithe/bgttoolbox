#!/bin/bash

## use something like srunPR_GETsysstat.sh to pack up and scp iostat files from hosts back
## unpack each into a seperate dir by name/ip like this:
##  for f in *.tbz; do echo f=$f; d=${f%.tbz}; mkdir $d; echo d=$d; cd $d; tar -jxvf ../$f; cd ..; done
## generate graphs by running this script run_iostat_plots.sh

for vm in $(ls); do
    if [[ -d $vm && -e $vm/etc/sysstat/iostat ]] ; then
        cd $vm/etc/sysstat/iostat
        echo vm=$vm
        if [[ ! -e ${vm}_ALLDATA ]]; then
            rm -f ${vm}_ALLDATA
            for f in $(ls -tr *-iostat); do
                echo f=$f;
                cat $f >> ${vm}_ALLDATA
            done
        fi
        ~/bin/iostat.readwrite.cass.py -i ${vm}_ALLDATA -o ${vm}_RW_ALLDATA.png -n "${vm}_RW_ALLDATA" 2>/dev/null
        ~/bin/iostat.util.CASS.py -i ${vm}_ALLDATA -o ${vm}_UTIL_ALLDATA.png -n "${vm}_UTIL_ALLDATA" 2>/dev/null
        ls -alstr Gnuplot_Stats/${vm}*ALLDATA
        cd -
    fi
    pwd
done

