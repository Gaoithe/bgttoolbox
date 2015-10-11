#!/usr/bin/python

import os, sys, time
import commands
import re
from datetime import datetime
#import subprocess as sub

'''
Read multiple gnuplot space seperated .dat files (date + ifconfig datfiles), space seperated.
Combine rows from same date + time.
 DONE. finally. phew. KISS first use small data files work out library/pandas functions.
Add TX and RX bytes total.
Write out a combined dat file.

e.g. usage:

   ~/bin/dat_merge2.py t*ifconfig_ALLDATA.dat -o ifconfig_ALLDATA.dat -c "datetime 0 RX 1 TX 4 RX 8 TX 11"

e.g. input dat file
"Tue Sep 29 15:11:56 UTC 2015" 0 0 112 0 0 0 10.109.22.13 0 0 112 0 0 0 10.109.22.109 
"Tue Sep 29 15:12:06 UTC 2015" 39729 0 112 1729110 0 0 10.109.22.13 2510142 0 112 3229940 0 0 10.109.22.109 
"Tue Sep 29 15:12:16 UTC 2015" 10825 0 112 14082 0 0 10.109.22.13 2145828 0 112 2430365 0 0 10.109.22.109 

'''

# options for script
outputfile = 'dat_merge.dat'

import argparse

parser = argparse.ArgumentParser(description='Merge data files and add column values.')
parser.add_argument('inputfiles', metavar='inputfile', nargs='+', help='input data files')
parser.add_argument('-o', '--outfile', help='output file')
parser.add_argument('-c', '--columns', help='string of col name and number')
#                   help='dat_merge2.py <inputfiles> -o <outputfile> -c <columns>'

args = parser.parse_args()
print args.inputfiles
print args.outfile
print args.columns

if args.outfile:
    outputfile = args.outfile

print "DEBUG inputfiles:" + str(args.inputfiles)

# make dictionary of columns
from itertools import izip
i = iter(args.columns.split(' '))
coldict = dict(izip(i, i))

print "DEBUG coldict:" + str(coldict)

def write_data(dat,value):
    """ Write data point string to a gnuplot .dat and to a .csv file. 
        .dat seperator is " "
        if value is "\n" then just write end of line
    """
    dat.write(value)
    if not value == "\n":
       dat.write(" ")


outvalues=[]
totals={}
data={}
for key in coldict:
    totals[key]=0 
#import csv
from pandas import concat, merge, ordered_merge, read_table, read_csv, groupby
mergedB = False

rxcols = []
txcols = []

for file in args.inputfiles:

    data[file] = read_table(file, sep=r" ", header=None)
    #data[file] = read_table(file, sep=r" ", header=None, names=['rx','rxerr','rxdrop','tx','txerr','txdrop','ip'])
    #data[file].columns = data[file].columns.str.join(file)
    #data[file] = data[file].rename(columns=lambda x: str(x)+"_foo", inplace=True)
    
    #data[file] = read_csv(file, index_col=0, sep=r" ", header=None)

    print "FILE " + file + ":" + str(data[file])
    #print data[file].describe()

    #rx = data[file].groupby(1)
    #print rx
    #print rx.describe()

    #tx = data[file].groupby(4)
    #print tx
    #print tx.describe()


    if mergedB:
        # Merge in by date(0,0). outer merge to keep all data points.
        merged = merge(merged, data[file], how='outer', left_on=0, right_on=0)##, ignore_index=True)
        print "merge in " + file + ":" + str(merged)

    else:
        merged = data[file]
        mergedB = True

    rxcols.append(list(merged)[1])
    txcols.append(list(merged)[4])

print rxcols
print txcols

merged['SUMALL'] = merged.sum(axis=1)
print list(merged)
allcols = list(merged)

import re

rxcols = [1]
print rxcols
print rxcols
rxcols += filter(lambda x:re.search(r'^1_', x), allcols)
print rxcols

txcols = [4]
txcols += filter(lambda x:re.search(r'^4_', x), allcols)
print txcols

rxcols_int = [8]
rxcols_int += filter(lambda x:re.search(r'^8_', x), allcols)
print rxcols_int

txcols_int = [11]
txcols_int += filter(lambda x:re.search(r'^11_', x), allcols)
print txcols_int

merged['rxsum'] = merged[[1,'1_x','1_y']].sum(axis=1)
merged['rxtot'] = merged[rxcols].sum(axis=1)
merged['txtot'] = merged[txcols].sum(axis=1)
print merged.describe()

merged.to_csv(args.outfile, sep=' ', na_rep=0, index=False, header=False)


if not os.path.isfile(args.outfile):
    out_file = open(args.outfile,'w+')



# Open files in the succession and 
# store the file_name as the first
# element followed by the elements of
# the third column.
for afile in file_names:
    file_h = open(afile)
    a_list = []
    a_list.append(afile)
    csv_reader = csv.reader(file_h, delimiter=' ')
    for row in csv_reader:
        a_list.append(row[2])
    # Convert the list to a generator object
    o_data.append((n for n in a_list))
    file_h.close()

# Use zip and csv writer to iterate
# through the generator objects and 
# write out to the output file
with open('output', 'w') as op_file:
    csv_writer = csv.writer(op_file, delimiter=' ')
    for row in list(zip(*outvalues)):
        csv_writer.writerow(row)
op_file.close()



if True:
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
set label 4 sprintf("TX_mean:%%2.3g", TX_mean) center at graph 0.5,first TX_mean point pt 7 ps 1 offset 0,0.8 front
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
set label 4 sprintf("TX_mean:%%2.3g", TX_mean) center at graph 0.5,first TX_mean point pt 7 ps 1 offset 0,0.8 front

set datafile sep whitespace
''' % (datafile,csvfile,i*7+2,i*7+3)

plot_string_tot = ' datafile using 1:%d title "RX bytes total", datafile using 1:%d title "TX bytes total"' % (i*7+2,i*7+3)
#plot_script_name = write_gnuplot_script("combitot",plot_string_tot + plot_strings_all):
plot_script_name = write_gnuplot_script("",plot_string_tot + "," + plot_strings_all,before_gnuplot_lines)

run_gnuplot_script(plot_script_name)

