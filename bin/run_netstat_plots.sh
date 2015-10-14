#!/bin/bash

source srunPRHOSTS.sh


#10.109.6.4_sysstat.tbz
#[james@nebraska 201510091205]$ get_name 10.109.22.13
#tc_app_11
for f in *.tbz; do
  ip=${f%%_sysstat.tbz}
  d=$ip
  name=$(get_name $ip)
  [[ ! -z $name ]] && d=$name
  echo FILE $f ip=$ip name=$name making dir $d
  if [[ ! -d $d ]] ; then
    mkdir $d;
    cd $d
    tar -jxvf ../$f
    cd -
    name=
  fi
done


## use something like srunPR_GETsysstat.sh to pack up and scp iostat files from hosts back
## unpack each into a seperate dir by name/ip like this:
##  for f in *.tbz; do echo f=$f; d=${f%.tbz}; mkdir $d; echo d=$d; cd $d; tar -jxvf ../$f; cd ..; done
## generate graphs by running this script: run_iostat_plots.sh
## run_iostat_plots.sh looks at each directory in current dir for <dir>/etc/sysstat/iostat/ files
## run_netstat_plots.sh looks at each directory in current dir for <dir>/etc/sysstat/ifconfig/ files

for vm in $(ls); do
    if [[ -d $vm && -e $vm/etc/sysstat/ifconfig ]] ; then
        cd $vm/etc/sysstat/ifconfig
        echo vm=$vm
        if [[ ! -e ${vm}_ALLDATA ]]; then
            rm -f ${vm}_ALLDATA
            for f in $(ls -tr *-ifconfig); do
                echo f=$f;
                cat $f | sed -r "s/(packets|errors|dropped|overruns|frame|bytes):/\1 /g" >> ${vm}_ALLDATA
            done
        fi
        #~/bin/iostat.readwrite.cass.py -i ${vm}_ALLDATA -o ${vm}_RW_ALLDATA.png -n "${vm}_RW_ALLDATA" 2>/dev/null
        #~/bin/ifconfig.plot.py -i ${vm}_ALLDATA -o ${vm}_ifconfig_ALLDATA.png -n "${vm}_ifconfig_ALLDATA" 2>/dev/null
        echo ~/bin/ifconfig.plot.py -i ${vm}_ALLDATA -o ${vm}_ifconfig_ALLDATA.png -n "${vm}_ifconfig_ALLDATA" 2>&1 |tee -a Gnuplot_Stats/run_plots.log
        ~/bin/ifconfig.plot.py -i ${vm}_ALLDATA -o ${vm}_ifconfig_ALLDATA.png -n "${vm}_ifconfig_ALLDATA" 2>&1 |tee -a Gnuplot_Stats/run_plots.log
        #ls -alstr Gnuplot_Stats/${vm}*ALLDATA
        ls -alstr Gnuplot_Stats/
        cd -
    fi

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
        ~/bin/iostat.readwrite.cass.py -i ${vm}_ALLDATA -o ${vm}_RW_ALLDATA.png -n "${vm}_RW_ALLDATA"  2>&1 |tee -a Gnuplot_Stats/run_plots.log
        ~/bin/iostat.plot.py -i ${vm}_ALLDATA -o ${vm}_iostat_ALLDATA.png -n "${vm}_iostat_ALLDATA"  2>&1 |tee -a Gnuplot_Stats/run_plots.log
        ls -alstr Gnuplot_Stats/
        cd -
    fi

    pwd
done


#[james@nebraska ifconfig]$  ~/bin/ifconfig.plot.py -i 10.109.22.13_ALLDATA -o 10.109.22.13_ALLDATA_TIME_x.png -n 1443539516-Tue-29-15:11:56-ifconfig

