#!/usr/bin/python

import os, sys, time
import commands
import getopt
import re
from datetime import datetime
#from dateutil import parser
from subprocess import Popen,PIPE

'''

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

addressList=[]
if not os.path.isfile(datafile):
    in_file = open(inputfile)
    out_file = open(datafile,'w+')
    first_address = "meh"
    last_address = "meh"
    address = "meh"
    ifSet=set([])
    addressSet=set([])
    #old_rx_bytes=0
    #old_tx_bytes=0
    old_rx_bytes={}
    old_tx_bytes={}

    reDate = re.compile('(Sun|Mon|Tue|Wed|Thu|Fri|Sat)')
    currentDate = ""

    for line in in_file:
       line_list = line.split()
       #print line_list     # get device or inet address . . . 
       if len(line_list) >= 4:
          #print "split: %s+%s+%s+%s" % (line_list[0],line_list[1],line_list[2],line_list[3])
          #Sun Oct  4 07:48:48 UTC 2015
          if reDate.match(line_list[0]):
             currentDateStr = line.rstrip()
             #print currentDateStr
             #currentDateX = datetime.strptime(currentDateStr, "%a %b %d %H:%M:%S UTC %Y")
             currentDateX = datetime.strptime(currentDateStr, "%a %b %d %H:%M:%S %Z %Y")
             #currentDateX = parser.parse(currentDateStr);
             currentDate = currentDateX.strftime('%Y-%m-%d %H:%M:%S')
             print(currentDate + "\r"),

             if last_address != "meh":
                out_file.write("\n")
             out_file.write("\"" + currentDate + "\" ")

          if line_list[0] == 'inet':
             if line_list[1].startswith("10.109."):
                address = line_list[1]
                ifSet.add(address)
             else:
                address = "meh"

          if address and address != "meh" and line_list[0] == 'RX' and line_list[1] == 'packets':

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

             rx_bytes = line_list[4]
             delta = 0
             if int(old_rx_bytes[address]) > 0:
                delta = int(rx_bytes) - int(old_rx_bytes[address])
             #print "DEBUG addr:%s rx:%s old:%s d:%s" % (address,rx_bytes,old_rx_bytes[address],delta)
             old_rx_bytes[address] = rx_bytes
             #out_file.write(rx_bytes)
             #out_file.write(" ")
             out_file.write(str(delta))
             out_file.write(" ")
          if address and address != "meh" and line_list[0] == 'RX' and line_list[1] == 'errors':
             out_file.write(line_list[2])
             out_file.write(" ")
             out_file.write(line_list[4])
             out_file.write(" ")
          if address and address != "meh" and line_list[0] == 'TX' and line_list[1] == 'packets':
             tx_bytes = line_list[4]
             delta = 0
             if int(old_tx_bytes[address]) > 0:
                delta = int(tx_bytes) - int(old_tx_bytes[address])
             old_tx_bytes[address] = tx_bytes
             #out_file.write(tx_bytes)
             #out_file.write(" ")
             out_file.write(str(delta))
             out_file.write(" ")
          if address and address != "meh" and line_list[0] == 'TX' and line_list[1] == 'errors':
             out_file.write(line_list[2])
             out_file.write(" ")
             out_file.write(line_list[4])
             out_file.write(" ")
             out_file.write(address)
             out_file.write(" ")

             ##if address and address != "meh" and address.startswith("10.109.22.10"):
             #if address and address == last_address:
             #   #out_file.write("\"" + currentDate + "\"")
             #   out_file.write("\n")

    in_file.close()
    out_file.close()

#        inet 10.109.6.109  netmask 255.255.255.240  broadcast 10.109.6.111
#        RX packets 1558965986  bytes 3778946234671 (3.4 TiB)
#        RX errors 0  dropped 0  overruns 0  frame 0
#        TX packets 1558965986  bytes 3778946234671 (3.4 TiB)
#        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

#      if line_list[0] == 'sdd':
#         out_file.write(line_list[13])
#         out_file.write(" ")
#      if line_list[0] == 'dm-5':
#         out_file.write(line_list[13])
#         out_file.write(" ")

      
 
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
set ytics ("bottom" 0, "" 10 1, "1e4" 1e4, "1e5" 1e5, "1e6" 1e6, "1e7" 1e7)
#set ytics ("bottom" 0, "" 10, "top" 20)
#set ytics ("bottom" 0, "" 10 1, "top" 20)
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

# we do not get addressList if datafile not regenerated
#gnuplot_lines += '''set xlabel "%s"\n''' % addressList[1]

gnuplot_lines += ''' 
set xdata time
set timefmt '"%Y-%m-%d %H:%M:%S"'
#set timefmt "\\"%a %b %d %H:%M:%S UTC %Y\\""
#set timefmt "%a %b %d %H:%M:%S UTC %Y"
#set format x "%m-%d\\n%H:%M"
set autoscale y  
set autoscale x
#set xrange ["2013-07-21 16:00":"2013-07-22 16:00"]
'''

# edit each item to plot:
# format "<date>" [ <rxdelta> <rxerr> <rxdrop> <txdelta> <txerr> <txdrop> <address> ] * N 
#   first i = 0 2,5,3,4,6,7
#   2nd   i = 1 9,12,10,11,13,14 

plot_string_io = 'plot "%s"  using 0:2 title "RX bytes delta", "%s"  using 0:5 title "TX bytes delta"' % (datafile,datafile)
plot_string_io = 'plot "%s"  using 0:9 title "RX bytes delta", "%s"  using 0:12 title "TX bytes delta"' % (datafile,datafile)

if not addressList:
   #firstrow = os.system('''head -1 "%s"|sed "s/\\"[^\\"]*\\"/QUOTED/g"''' % datafile)
   firstrow = Popen('''head -1 "%s"|sed "s/\\"[^\\"]*\\"/QUOTED/g"''' % datafile, shell=True, stdout=PIPE).stdout.read()
   print "DEBUG:" + firstrow
   line_list = firstrow.split()
   i = 0
   while i*7+8 <= len(line_list):
       print "address:%s" % line_list[i*7+7]
       addressList.append(line_list[i*7+7])
       i += 1

# address offset, start at 0 . . . 
i = 0
for address in addressList:
   outputfile_path = directory + '/' + str(address) + "_" + outputfile

   plot_string_io = 'plot "%s" using 1:%d title "RX bytes delta", "%s" using 1:%d title "TX bytes delta"' % (datafile,i*7+2,datafile,i*7+5)
   plot_string_io += ', "%s" using 1:%d title "RX err", "%s" using 1:%d title "RX drop"' % (datafile,i*7+3,datafile,i*7+4)
   plot_string_io += ', "%s" using 1:%d title "TX err", "%s" using 1:%d title "TX drop"' % (datafile,i*7+6,datafile,i*7+7)

   gnuplot_xlabel = 'set xlabel "%s"\n' % addressList[i]
   gnuplot_xlabel += 'set output "%s"' % outputfile_path

   ### Config filennames ##########
   #plot_script_name = '/tmp/netdatforplot.gp'
   plot_script_name = directory + '/' + str(address) + "_" + inputfile + '.gp'
   ################################

   gnuplot_script = open(plot_script_name, 'w+')
   # need to create something like this:
   # plot "/tmp/cpu.data" using 1:2 title "User", "/tmp/cpu.data" using 1:3 title "Nice"
   gnuplot_script.write(gnuplot_lines)
   gnuplot_script.write('\n')
   gnuplot_script.write(gnuplot_xlabel)
   gnuplot_script.write('\n')
   gnuplot_script.write(plot_string_io)
   gnuplot_script.write('\n')
   gnuplot_script.close()

   while not os.path.isfile(plot_script_name):
      time.sleep(1)
      print 'gnuplot script not created'

   gnuplot_binary = '/usr/bin/gnuplot'
   import subprocess as sub
   try:
      sub.call([gnuplot_binary,plot_script_name])
   except OSError:
      print 'error running gnuplot command - is gnuplot installed ? Exiting ...'
      sys.exit()

   i+=1

