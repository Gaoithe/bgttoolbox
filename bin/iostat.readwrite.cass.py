#!/usr/bin/python

import os, sys, time
import commands
import getopt

'''
Linux 3.10.0-123.20.1.el7.x86_64 (node21)       27/03/15        _x86_64_        (32 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          24.77    0.89    9.51    0.37    0.00   64.45

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.02     0.59    0.13    0.88     3.60    29.00    64.34     0.10   98.74    3.83  112.91   4.70   0.48
sdb               0.01    30.91    0.42   13.00    11.66  1473.45   221.29     1.98  147.25    4.17  151.88   2.31   3.11
sdc               0.00     0.38    0.02   14.17     0.90  6809.74   960.10     1.89  133.44    1.92  133.59   4.79   6.80
sdd               0.01     2.69    5.49    6.90    81.71  2853.14   473.56     2.90  234.32   61.79  371.55   3.81   4.72

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

outputfile = "/tmp/io"
in_file = open(inputfile)
out_file = open(outputfile,'w+')
for line in in_file:
   line_list = line.split()
   #print line_list
   if len(line_list) == 14:
      if line_list[0] == 'sda':
         out_file.write(line_list[3])
         out_file.write(" ")
         out_file.write(line_list[4])
         out_file.write(" ")
      if line_list[0] == 'sdb':
         out_file.write(line_list[3])
         out_file.write(" ")
         out_file.write(line_list[4])
         out_file.write(" ")
      if line_list[0] == 'sdc':
         out_file.write(line_list[3])
         out_file.write(" ")
         out_file.write(line_list[4])
         out_file.write(" ")
      if line_list[0] == 'sdd':
         out_file.write(line_list[3])
         out_file.write(" ")
         out_file.write(line_list[4])
         out_file.write(" ")
      if line_list[0] == 'sde':
         out_file.write(line_list[3])
         out_file.write(" ")
         out_file.write(line_list[4])
         out_file.write(" ")
      if line_list[0] == 'sdf':
         out_file.write(line_list[3])
         out_file.write(" ")
         out_file.write(line_list[4])
         out_file.write(" ")
#      if line_list[0] == 'dm-0':
#         out_file.write(line_list[3])
#         out_file.write(" ")
#         out_file.write(line_list[4])
#         out_file.write(" ")
#      if line_list[0] == 'dm-1':
#         out_file.write(line_list[3])
#         out_file.write(" ")
#         out_file.write(line_list[4])
#         out_file.write(" ")
#      if line_list[0] == 'dm-2':
#         out_file.write(line_list[3])
#         out_file.write(" ")
#         out_file.write(line_list[4])
#         out_file.write(" ")
#      if line_list[0] == 'dm-3':
#         out_file.write(line_list[3])
#         out_file.write(" ")
#         out_file.write(line_list[4])
#         out_file.write(" ")
#      if line_list[0] == 'dm-4':
#         out_file.write(line_list[3])
#         out_file.write(" ")
#         out_file.write(line_list[4])
#         out_file.write(" ")
#      if line_list[0] == 'dm-5':
#         out_file.write(line_list[3])
#         out_file.write(" ")
#         out_file.write(line_list[4])
#         out_file.write(" ")

         out_file.write("\n")
      
 
# now create gnuplot file .. need to do this as need to set title depending on process name
gnuplot_lines_io = '''set title "%s"
set terminal png notransparent size 1200,800
set output "%s"
#set nokey
set style data lines\n''' % (scenario_name,outputfile_path)

gnuplot_lines = gnuplot_lines_io + '''set ylabel "read/write per sec"
set ytics 10
set grid xtics ytics'''

plot_string_io = 'plot "' + outputfile + '"  using 0:1 title "IO out"'
plot_string_io = 'plot "/tmp/io"  using 0:5 title "sdc /commit r/s", "/tmp/io"  using 0:6 title "sdc /commit w/s", "/tmp/io"  using 0:7 title "sdd /data r/s", "/tmp/io"  using 0:8 title "sdd /data w/s"'
plot_string_io = 'plot "/tmp/io" using 0:1 title "sda r/s", "/tmp/io"  using 0:2 title "sda w/s", "/tmp/io" using 0:3 title "sdb r/s", "/tmp/io"  using 0:4 title "sdb w/s", "/tmp/io" using 0:5 title "sdc r/s", "/tmp/io"  using 0:6 title "sdc w/s", "/tmp/io" using 0:7 title "sdd r/s", "/tmp/io"  using 0:8 title "sdd w/s", "/tmp/io" using 0:9 title "sde r/s", "/tmp/io"  using 0:10 title "sde w/s", "/tmp/io" using 0:11 title "sdf r/s", "/tmp/io"  using 0:12 title "sdf w/s", "/tmp/io" using 0:13 title "dm-0 r/s", "/tmp/io"  using 0:14 title "dm-0 w/s", "/tmp/io" using 0:15 title "dm-1 r/s", "/tmp/io"  using 0:16 title "dm-1 w/s", "/tmp/io" using 0:17 title "dm-2 r/s", "/tmp/io"  using 0:18 title "dm-2 w/s", "/tmp/io" using 0:19 title "dm-3 r/s", "/tmp/io"  using 0:20 title "dm-3 w/s", "/tmp/io" using 0:21 title "dm-4 r/s", "/tmp/io"  using 0:22 title "dm-4 w/s", "/tmp/io" using 0:23 title "dm-5 r/s", "/tmp/io"  using 0:24 title "dm-5 w/s"'

### Config filennames ##########
plot_script_name = '/tmp/io.gp'
################################

gnuplot_script = open(plot_script_name, 'w+')
# need to create something like this:
# plot "/tmp/cpu.data" using 1:2 title "User", "/tmp/cpu.data" using 1:3 title "Nice"
gnuplot_script.write(gnuplot_lines)
gnuplot_script.write('\n')
gnuplot_script.write(plot_string_io)

gnuplot_script.close()
in_file.close()
out_file.close()

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
 
