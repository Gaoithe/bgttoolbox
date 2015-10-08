#!/usr/bin/python

import os, sys, time
import commands
import getopt
import re
from datetime import datetime
#from dateutil import parser
import subprocess as sub
#from subprocess import Popen,PIPE,call

'''
Read in an ifconfig + date logfile (collected from /apps/omn/etc/sysstat/ifconfig).
Write out a gnuplot space seperated .dat file. 
Write out a .csv file.
Write out data just for selected addresses, edit this line to select different:
  if line_list[1].startswith("10.109."):
Do not re-write .dat file if it already exists.

Write out gnuplot script for each address and a combbined + total fnuplot script ".gp" files.
Run gnuplot and generate .png for each plot.

e.g. usage:

   ~/bin/ifconfig.plot.py -i ${vm}_ALLDATA -o ${vm}_UTIL_ALLDATA.png -n "${vm}_UTIL_ALLDATA" 2>/dev/null

[james@nebraska 10.109.6.13]$ less etc/sysstat/ifconfig/*-Sun-04-07* 

Sun Oct  4 07:48:48 UTC 2015

eno16780032: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.109.6.13  netmask 255.255.255.224  broadcast 10.109.6.31
        ether 00:50:56:96:68:96  txqueuelen 1000  (Ethernet)
        RX packets 14633197  bytes 28276332496 (26.3 GiB)
        RX errors 0  dropped 188  overruns 0  frame 0
        TX packets 19084622  bytes 4121498235 (3.8 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eno16780032:1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.109.6.15  netmask 255.255.255.224  broadcast 10.109.6.31
        ether 00:50:56:96:68:96  txqueuelen 1000  (Ethernet)

eno33559296: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.48.182.71  netmask 255.255.254.0  broadcast 10.48.183.255
        ether 00:50:56:96:39:b7  txqueuelen 1000  (Ethernet)
        RX packets 39657  bytes 3506756 (3.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 39  bytes 1750 (1.7 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eno50338560: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.4.81.13  netmask 255.255.255.192  broadcast 10.4.81.63
        ether 00:50:56:96:4d:5d  txqueuelen 1000  (Ethernet)
        RX packets 11286205  bytes 1306952049 (1.2 GiB)
        RX errors 0  dropped 140  overruns 0  frame 0
        TX packets 13465072  bytes 1837855224 (1.7 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eno67109888: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.4.81.77  netmask 255.255.255.240  broadcast 10.4.81.79
        ether 00:50:56:96:02:3f  txqueuelen 1000  (Ethernet)
        RX packets 17085615  bytes 2162006414 (2.0 GiB)
        RX errors 0  dropped 140  overruns 0  frame 0
        TX packets 18646207  bytes 2005950757 (1.8 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eno83889152: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.109.6.109  netmask 255.255.255.240  broadcast 10.109.6.111
        ether 00:50:56:96:5d:2c  txqueuelen 1000  (Ethernet)
        RX packets 635929898  bytes 316679728700 (294.9 GiB)
        RX errors 0  dropped 187  overruns 0  frame 0
        TX packets 577633579  bytes 328519347574 (305.9 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eno83889152:2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.109.6.111  netmask 255.255.255.240  broadcast 10.109.6.111
        ether 00:50:56:96:5d:2c  txqueuelen 1000  (Ethernet)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 0  (Local Loopback)
        RX packets 1558965986  bytes 3778946234671 (3.4 TiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1558965986  bytes 3778946234671 (3.4 TiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


[james@nebraska ifconfig]$ head /tmp/netdatforplot
"Tue Sep 29 15:11:56 UTC 2015" 0 0 112 0 0 0 10.109.22.13 0 0 112 0 0 0 10.109.22.109 
"Tue Sep 29 15:12:06 UTC 2015" 39729 0 112 1729110 0 0 10.109.22.13 2510142 0 112 3229940 0 0 10.109.22.109 
"Tue Sep 29 15:12:16 UTC 2015" 10825 0 112 14082 0 0 10.109.22.13 2145828 0 112 2430365 0 0 10.109.22.109 

# generating datafile takes a while
# we only re-generate it if it doesn't already exist.
# re-plots can be done then quickly off of the same data
# remove the .dat file to regenerate .csv and the .dat file


'''

# options for script
outputfile = ''
inputfile = ''
argv = sys.argv[1:]
try:
   opts, args = getopt.getopt(argv,"hi:o:n:",["input file=","scenario name="])
except getopt.GetoptError:
   print 'iostat.rewrite.py -i <inputfile> -o <inputfile> -n <scenario name>'
   sys.exit(2)
for opt, arg in opts:
   if opt == '-h':
      print 'iostat-rewrite.py -i <inputfile> -o <outputfile> -n <scenario name>'
      sys.exit()
   elif opt in ("-i", "--inputfile"):
      inputfile = arg
   elif opt in ("-o", "--outputfile"):
      outputfile = arg
   elif opt in ("-n"):
      scenario_name = arg

# create dir for gnuplot output
traffic_gnuplot_dir = 'Gnuplot_Stats'
current_dir = os.getcwd()

directory = current_dir + '/' + traffic_gnuplot_dir
if not os.path.exists(directory):
    os.makedirs(directory)
outputfile_path = directory + '/' + outputfile

#datafile = "/tmp/netdatforplot"
datafile = directory + '/' + inputfile + '.dat'
csvfile = directory + '/' + inputfile + '.csv'
def write_data(dat,csv,value):
    """ Write data point string to a gnuplot .dat and to a .csv file. 
        .dat seperator is " "
        .csv seperator is ","
        if value is "\n" then just write end of line
    """
    dat.write(value)
    csv.write(value)
    if not value == "\n":
       dat.write(" ")
       csv.write(",")

addressList=[]
# generating datafile takes a while
# we only re-generate it if it doesn't already exist.
# re-plots can be done then quickly off of the same data
# remove the .dat file to regenerate .csv and the .dat file
if not os.path.isfile(datafile):
    in_file = open(inputfile)
    out_file = open(datafile,'w+')
    csv_file = open(csvfile,'w+')
    first_address = "meh"
    last_address = "meh"
    address = "meh"
    ifSet=set([])
    addressSet=set([])
    #old_rx_bytes=0
    #old_tx_bytes=0
    old_rx_bytes={}
    old_tx_bytes={}
    totals={}
    totals['RX']=0
    totals['TX']=0

    reDate = re.compile('(Sun|Mon|Tue|Wed|Thu|Fri|Sat)')
    currentDate = ""

    for line in in_file:
       line_list = line.split()
       #print line_list     # get device or inet address . . . 
       if len(line_list) >= 4:
          #print "split: %s+%s+%s+%s" % (line_list[0],line_list[1],line_list[2],line_list[3])
          #Sun Oct  4 07:48:48 UTC 2015
          if reDate.match(line_list[0]):
             currentDateStr = line.rstrip() # chomp
             #print currentDateStr
             #currentDateX = datetime.strptime(currentDateStr, "%a %b %d %H:%M:%S UTC %Y")
             currentDateX = datetime.strptime(currentDateStr, "%a %b %d %H:%M:%S %Z %Y")
             #currentDateX = parser.parse(currentDateStr);
             currentDate = currentDateX.strftime('%Y-%m-%d %H:%M:%S')
             print(currentDate + "\r"),

             #### END of one chunk detect. Write totals, END OF LINE, next date
             if last_address != "meh":
                 write_data(out_file,csv_file,str(totals['RX']))
                 write_data(out_file,csv_file,str(totals['TX']))
                 write_data(out_file,csv_file,"\n")
             write_data(out_file,csv_file,"\"" + currentDate + "\"")
             totals['RX']=0
             totals['TX']=0

          if line_list[0] == 'inet':
             if line_list[1].startswith("10.109."):
                address = line_list[1]
                ifSet.add(address)
             else:
                address = "meh"

          if address and address != "meh" and line_list[0] == 'RX' and line_list[1] == 'packets':

             # build up list of addresses, initialise old values for delta calc
             if address not in addressSet:
                last_address = address
                addressList.append(address)
             addressSet.add(address)
             #print address
             if not address in old_rx_bytes:
                old_rx_bytes[address]=0
             if not address in old_tx_bytes:
                old_tx_bytes[address]=0
             if not first_address or first_address == "meh":
                first_address = address

             # TODO: min and max and average RX calc ?here or better/more generic in gnuplot script

             rx_bytes = line_list[4]
             delta = 0
             if int(old_rx_bytes[address]) > 0:
                delta = int(rx_bytes) - int(old_rx_bytes[address])
             #print "DEBUG addr:%s rx:%s old:%s d:%s" % (address,rx_bytes,old_rx_bytes[address],delta)
             old_rx_bytes[address] = rx_bytes
             totals['RX'] += delta
             #write_data(out_file,csv_file,rx_bytes)
             write_data(out_file,csv_file,str(delta))

          if address and address != "meh" and line_list[0] == 'RX' and line_list[1] == 'errors':
             write_data(out_file,csv_file,line_list[2])
             write_data(out_file,csv_file,line_list[4])
          if address and address != "meh" and line_list[0] == 'TX' and line_list[1] == 'packets':
             tx_bytes = line_list[4]
             delta = 0
             if int(old_tx_bytes[address]) > 0:
                delta = int(tx_bytes) - int(old_tx_bytes[address])
             old_tx_bytes[address] = tx_bytes
             totals['TX'] += delta
             #write_data(out_file,csv_file,tx_bytes)
             write_data(out_file,csv_file,str(delta))
          if address and address != "meh" and line_list[0] == 'TX' and line_list[1] == 'errors':
             write_data(out_file,csv_file,line_list[2])
             write_data(out_file,csv_file,line_list[4])
             write_data(out_file,csv_file,address)


    in_file.close()
    out_file.close()
    csv_file.close()

#        inet 10.109.6.109  netmask 255.255.255.240  broadcast 10.109.6.111
#        RX packets 1558965986  bytes 3778946234671 (3.4 TiB)
#        RX errors 0  dropped 0  overruns 0  frame 0
#        TX packets 1558965986  bytes 3778946234671 (3.4 TiB)
#        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

#      if line_list[0] == 'sdd':
#         write_data(out_file,csv_file,line_list[13])
#      if line_list[0] == 'dm-5':
#         write_data(out_file,csv_file,line_list[13])

      
 
# now create gnuplot file .. need to do this as need to set title depending on process name
gnuplot_lines_io = '''set title "%s"
set terminal png notransparent size 1200,800
set output "%s"
#set nokey
#set style data lines
#set style data points
#set style data dots
set style data linespoints
''' % (scenario_name,outputfile_path)

gnuplot_lines = gnuplot_lines_io + '''set ylabel "bytes"
set ytics 1000
#set logscale y; set ytics 1,10,1e12
#set ytics ("0" 0, "1e3" 1e3, "1e4" 1e4, "1e5" 1e5, "1e6" 1e6, "1.5e6" 1.5e6, "1e7" 1e7, "1e8" 1e8, "1e9" 1e9)
set ytics ("0" 0, "1e6" 1e6, "2e6" 2e6, "3e6" 3e6, "4e6" 4e6, "5e6" 5e6, "6e6" 6e6, "7e6" 7e6, "8e6" 8e6, "9e6" 9e6, "1e7" 1e7, "2e7" 2e7, "3e7" 3e7, "4e7" 4e7, "5e7" 5e7, "6e7" 6e7, "7e7" 7e7, "8e7" 8e7, "9e7" 9e7, "1e8" 1e8)
set mytics 10
#show mytics
# minor tics cannot be used if major tics are explicitly `set`.
set grid xtics ytics'''

#[james@nebraska ifconfig]$ head /tmp/netdatforplot
#"Tue Sep 29 15:11:56 UTC 2015" 0 0 112 0 0 0 10.109.22.13 0 0 112 0 0 0 10.109.22.109 
#"Tue Sep 29 15:12:06 UTC 2015" 39729 0 112 1729110 0 0 10.109.22.13 2510142 0 112 3229940 0 0 10.109.22.109 
#"Tue Sep 29 15:12:16 UTC 2015" 10825 0 112 14082 0 0 10.109.22.13 2145828 0 112 2430365 0 0 10.109.22.109 

gnuplot_lines += ''' 
datafile = "%s"
firstrow = system('head -1 ' . datafile . '|sed "s/\\"[^\\"]*\\"/QUOTED/g"')
set xlabel word(firstrow, 15)
''' % datafile


gnuplot_lines += ''' 
set xdata time
set timefmt '"%Y-%m-%d %H:%M:%S"'
#set timefmt '"%a %b %d %H:%M:%S UTC %Y"'
#set format x "%m-%d\\n%H:%M"
set autoscale y  
set autoscale x
# bring legend to front in case it is hidden
#set key opaque
'''


# we do not get addressList if datafile not regenerated
# so we get it from .dat file
#gnuplot_lines += '''set xlabel "%s"\n''' % addressList[1]
if not addressList:
   #firstrow = os.system('''head -1 "%s"|sed "s/\\"[^\\"]*\\"/QUOTED/g"''' % datafile)
   firstrow = sub.Popen('''head -1 "%s"|sed "s/\\"[^\\"]*\\"/QUOTED/g"''' % datafile, shell=True, stdout=sub.PIPE).stdout.read()
   print "DEBUG:" + firstrow
   line_list = firstrow.split()
   i = 0
   while i*7+8 <= len(line_list):
       print "address:%s" % line_list[i*7+7]
       addressList.append(line_list[i*7+7])
       i += 1


def write_gnuplot_script(identifier,plot_string_io,before_gnuplot_lines="",after_gnuplot_lines=""):
    """ Write script for gnuplot. General gnuplot vars set for plot. Plot specific command. """

    outputfile_path = directory + '/' + identifier + outputfile
    
    gnuplot_xlabel = 'set xlabel "%s"\n' % identifier
    gnuplot_xlabel += 'set output "%s"' % outputfile_path

    plot_script_name = directory + '/' + identifier + inputfile + '.gp'

    gnuplot_script = open(plot_script_name, 'w+')
    gnuplot_script.write(before_gnuplot_lines + "\n")
    gnuplot_script.write(gnuplot_lines + "\n")
    gnuplot_script.write(gnuplot_xlabel+"\n")
    gnuplot_script.write("plot " + plot_string_io + "\n")
    gnuplot_script.write(after_gnuplot_lines + "\n")
    gnuplot_script.close()

    #return outputfile_path
    return plot_script_name


def run_gnuplot_script(plot_script_name):
    """ Run script for gnuplot. Wait for it to exist. Run it. Basic check for error returned. """

    while not os.path.isfile(plot_script_name):
        time.sleep(1)
        print 'gnuplot script not created'

    gnuplot_binary = '/usr/bin/gnuplot'
    import subprocess as sub
    try:
        print "call$ %s %s" % (gnuplot_binary,plot_script_name)
        sub.call([gnuplot_binary,plot_script_name])
        # gnuplot output """, line 33: ';' expected""" means there is a comma missing!
    except OSError:
        print 'error running gnuplot command - is gnuplot installed ? Exiting ...'
        sys.exit()


# PLOT: TWO plots, one for each interface
# address offset, start at 0 . . . used to calculate position of  each item to plot:
# format "<date>" [ <rxdelta> <rxerr> <rxdrop> <txdelta> <txerr> <txdrop> <address> ] * N 
#   first i = 0 2,5,3,4,6,7
#   2nd   i = 1 9,12,10,11,13,14 
#   tot   i = 2 16,17
# e.g. hardcoded 0:;5 0:12 is time versus RX for each address
# plot_string_io = 'plot "%s"  using 0:2 title "RX bytes delta", "%s"  using 0:5 title "TX bytes delta"' % (datafile,datafile)
# plot_string_io = 'plot "%s"  using 0:9 title "RX bytes delta", "%s"  using 0:12 title "TX bytes delta"' % (datafile,datafile)

#plot_strings={}
plot_strings_all=""

i = 0
for address in addressList:

    # RX_max and TX_max
    # nuts. Stats command not available in timedata mode, can do it with csv though
    before_gnuplot_lines = ''' 
datafile = "%s"
csvfile = "%s"
set datafile sep ','

# Get RX_max RX_min TX_max TX_min
stats csvfile using %d name 'RX_'
stats csvfile using %d name 'TX_'

## Find x time position of _max values
#stats csvfile using 1 every ::RX_index_max::RX_index_max nooutput
#RX_X_max = STATS_max
#stats csvfile using 1 every ::TX_index_max::TX_index_max nooutput
#TX_X_max = STATS_max
## unfortunately x position RX_X_max/TX_X_max date/time format we get year "2015" only
##info = sprintf("RX_X_max:%%d", RX_X_max)
##print info

unset border

set label 1 sprintf("RX_max:%%2.3g", RX_max) center at graph 0.2,first RX_max nopoint offset 0,-1.5 front
set label 2 sprintf("TX_max:%%2.3g", TX_max) center at graph 0.5,first TX_max nopoint offset 0,-1.5 front
set label 3 sprintf("RX_mean:%%2.3g", RX_mean) center at graph 0.2,first RX_mean point pt 7 ps 1 offset 0,0.8 front
set label 4 sprintf("TX_mean:%%2.3g", TX_mean) center at graph 0.2,first TX_mean point pt 7 ps 1 offset 0,0.8 front
#set label 1 sprintf("RX_max:%%2.3g mean:%%2.3g", RX_max, RX_mean) center at graph 0.2,first RX_max point pt 7 ps 1 offset 0,-1.5 front
#set label 2 sprintf("TX_max:%%2.3g mean:%%2.3g", TX_max, TX_mean) center at graph 0.2,first TX_max point pt 7 ps 1 offset 0,-1.5 front
#set label 1 sprintf("RX_max:%%2.3g mean:%%2.3g", RX_max, RX_mean) center at graph 0.2,first RX_mean point pt 7 ps 1 offset 0,1.5 front
#set label 2 sprintf("TX_max:%%2.3g mean:%%2.3g", TX_max, TX_mean) center at graph 0.2,first TX_mean point pt 7 ps 1 offset 0,1.5 front
#set label 2 sprintf("TX_max:%%.2f mean:%%.2f", TX_max, TX_mean) center at graph 0.2,first TX_mean point pt 7 ps 1 offset 0,1.5

a = sprintf("RX_max:%%.2f mean:%%.2f", RX_max, RX_mean)
print a
b = sprintf("TX_max:%%.2f mean:%%.2f", TX_max, TX_mean)
print b
#print RX_X_max,RX_max,RX_mean,TX_X_max,TX_max,TX_mean

set datafile sep whitespace
#set datafile sep ' '
#unset datafile sep ' '

''' % (datafile,csvfile,i*7+2,i*7+5)

    plot_string_io = ' datafile using 1:%d title "RX bytes delta %s", datafile using 1:%d title "TX bytes delta"' % (i*7+2,str(address),i*7+5)
    #plot_string_io += ', RX_max title "RX max" w l lt 1, TX_max title "TX max" w l lt 2'
    plot_string_io += ', RX_mean title "RX mean" w l lt 1, TX_mean title "TX mean" w l lt 2'
    plot_string_io += ', datafile using 1:%d title "RX err", datafile using 1:%d title "RX drop"' % (i*7+3,i*7+4)
    plot_string_io += ', datafile using 1:%d title "TX err", datafile using 1:%d title "TX drop"' % (i*7+6,i*7+7)   
    #plot_strings[address] = plot_string_io
    if plot_strings_all != "":
       plot_strings_all += ","
    plot_strings_all += plot_string_io
    plot_script_name = write_gnuplot_script(str(address)+"_",plot_string_io,before_gnuplot_lines)
    run_gnuplot_script(plot_script_name)
    i+=1



# PLOT: total RX and TX.
    before_gnuplot_lines = ''' 
datafile = "%s"
csvfile = "%s"
set datafile sep ','

# Get RX_max RX_min TX_max TX_min
stats csvfile using %d name 'RX_'
stats csvfile using %d name 'TX_'

unset border

set label 1 sprintf("RX_max:%%2.3g", RX_max) center at graph 0.2,first RX_max nopoint offset 0,-1.5 front
set label 2 sprintf("TX_max:%%2.3g", TX_max) center at graph 0.5,first TX_max nopoint offset 0,-1.5 front
set label 3 sprintf("RX_mean:%%2.3g", RX_mean) center at graph 0.2,first RX_mean point pt 7 ps 1 offset 0,0.8 front
set label 4 sprintf("TX_mean:%%2.3g", TX_mean) center at graph 0.2,first TX_mean point pt 7 ps 1 offset 0,0.8 front

set datafile sep whitespace
''' % (datafile,csvfile,i*7+2,i*7+3)

plot_string_tot = ' datafile using 1:%d title "RX bytes total", datafile using 1:%d title "TX bytes total"' % (i*7+2,i*7+3)
#plot_script_name = write_gnuplot_script("combitot",plot_string_tot + plot_strings_all):
plot_script_name = write_gnuplot_script("",plot_string_tot + "," + plot_strings_all,before_gnuplot_lines)

run_gnuplot_script(plot_script_name)

