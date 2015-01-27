#!/usr/bin/python

'''
'''


import sys
import getopt
import binascii
import re

import os.path

class options:
    def __init__(self):
        self.file = ''

    def string2hex(self, filename):
        with open(filename, 'rb') as f:
            content = f.read()
        out = binascii.hexlify(content)
            
        f = open('out.txt', 'wb')
        f.write(out)
        f.close()


#~/proj_facebook/perimeta_capture_options_and_invite.txt
#        0x0000:  4500 0034 8d45 4000 4006 9502 0a01 023c

def hex2string(filename):

    str = ""
    with open(filename, 'r') as f:
        for line in f:
            m = re.match("\s*0x([0-9a-fA-F])+:\s+([0-9a-fA-F\s]+)",line)
            if m:
                hstr = re.sub(r'[^0-9a-fA-F]', r'', m.group(2))
                str += hstr.decode("hex")
            else:
                if str and str != "":
                    # sanitize, remove non-printables
                    pstr = re.sub(r'[^\s!-~]', r'.', str)
                    print "ASCII: %s"%pstr;
                    str = "";

                # print just non-hex lines
                sys.stdout.write(line)

            # don't print every line
            #sys.stdout.write(line)

            if str and str != "":
                while re.search("[\r\n]",str):
                    m2 = re.match("(.*)[\r\n]+(.*)",str)
                    str = m2.group(1);
                    # sanitize, remove non-printables
                    pstr = re.sub(r'[^\s!-~]', r'.', str)
                    print "ASCII: %s"%pstr;
                    str = m2.group(2);

    if str and str != "":
        # sanitize, remove non-printables
        pstr = re.sub(r'[^\s!-~]', r'.', str)
        print "ASCII: %s"%str;


def get_backtrace(filename):
    # TODO: is it a file?
    # run gdb on file, get binary
    # file binary to load symbols
    # core corefile to load symbols with core again
    # bt full, grep backtrace and write to backtrace file name
    
    print "file is %s" % filename
    print "bn is %s" % os.path.basename(filename)
    print "dn is %s" % os.path.dirname(filename)

    print "Get backtrace on %s . . . " % filename

    backtracefile = filename + "_backtrace"
    if os.path.exists(backtracefile):
        print "Warning: backtracefile %s already exists" % backtracefile
    else:
        print "Getting backtrace on backtracefile %s . . . " % backtracefile
        # run gdb -c backtracefile, interact, load binary-symbols, get backtrace, parse
        from subprocess import Popen, PIPE, STDOUT
        p = Popen(['gdb', '-c', filename], stdout=PIPE, stdin=PIPE, stderr=STDOUT)

        # First grep for lines like these
        '''
        Core was generated by `eog /home/james/.cache/.fr-SttTfA/clouds-it_s_gonna_rain-2011/clouds-it_s_gonna'.
        Program terminated with signal 11, Segmentation fault.
        '''

        gdbinfo1 = ""
        binaryfile = None
        progline = None
        while p.poll() is None and (binaryfile is None or progline is None):
            gdbinfo1 = p.stdout.readline()
            #print gdbinfo1
            import re
            m=re.match("^Core .* by .(\w+)\s*.*..$",gdbinfo1)
            if m:
                coreline = m.group()
                binaryfile = m.group(1)
                print coreline
            m=re.match("^Program .*$",gdbinfo1)
            if m:
                progline = m.group()
                print progline
        #gdbinfo1 = p.communicate()[0]
        #print gdbinfo1

        ## read until no more input . . . doesn't work, blocks.
        #gdbinfo2 = "meh"
        #while gdbinfo2:
        #    gdbinfo2 = p.stdout.readline().rstrip()
        #    print "RUNT: " + gdbinfo2

        ## make subprocess stdout a non-blocking file
        #import fcntl
        #fd = p.stdout.fileno()
        #fl = fcntl.fcntl(fd, fcntl.F_GETFL)
        #fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)
        ##fd = p.stderr.fileno()
        ##fl = fcntl.fcntl(fd, fcntl.F_GETFL)
        ##fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

        print "Load binary %s . . . " % binaryfile
        #gdbinfo2 = p.communicate('file '+ binaryfile)#[0].rstrip() # p.communicate waits for eof and process is terminated
        p.stdin.write('file '+ binaryfile + "\n")
 
        gdbinfo2 = p.stdout.readline()
        print gdbinfo2
        gdbinfo2 = p.stdout.readline()
        print gdbinfo2
        gdbinfo2 = p.stdout.readline()
        print gdbinfo2
 
        ## read if subprocess stdout a non-blocking file works . . . it doesn't :-(
        #gdbinfo2 = "meh"
        #while gdbinfo2 != "":
        #    try:
        #        gdbinfo2 = p.stdout.read().strip()
        #        print "RUNT: " + gdbinfo2
        #        gdberr2 = p.stderr.read().strip()
        #        print "RUNTE: " + gdberr2
        #    except:
        #        gdbinfo2 = ""

        print "Load core %s . . . " % filename
        #gdbinfo3 = p.communicate('core '+ filename)#[0].rstrip()
        p.stdin.write('core '+ filename + "\n")

        ### read if subprocess stdout a non-blocking file works . . . it doesn't :-(
        #gdbinfo3 = "meh"
        #while gdbinfo2 != "":
        #    try:
        #        gdbinfo3 = p.stdout.read().strip()
        #        print "RUNT: " + gdbinfo2
        #    except:
        #        gdbinfo3 = ""

        gdbinfo3 = p.stdout.readline()
        print gdbinfo3
        gdbinfo3 = p.stdout.readline()
        print gdbinfo3
        gdbinfo3 = p.stdout.readline()
        print gdbinfo3
        gdbinfo3 = p.stdout.readline()
        print gdbinfo3
        gdbinfo3 = p.stdout.readline()
        print gdbinfo3

        gdbinfobt = p.communicate('bt full')#[0].rstrip()
        #print "BACKTRACE: %s" % gdbinfobt
        print "BACKTRACE: "
        print gdbinfobt


def usage(msg,status=1):
    print msg
    print "Usage:"
    print "    %s <filewithhex>" % sys.argv[0]
    sys.exit(status)

def main():
    
    opt = options()

    optlist,args = getopt.getopt(sys.argv[1:],'h')
    for (field,val) in optlist:
        if field == '-h':
            usage()

    if args:

        print "SELECTED files: " % args;
        for (file) in args:
            #hex2string(file)
            get_backtrace(file);

    else:

        import glob

        files = glob.glob("core-dumps/core*")
        #print files;
        #print len(files);
        if len(files) == 0:
            files = glob.glob("/apps/omn/core-dumps/core*")

        if len(files) == 0:
            files = glob.glob("core*")

        print "SELECTED files: %s" % files;
        for file in files:
            # get directory, get core file name, skip if backtrace already exists 
            get_backtrace(file);

    #print opt.data

if __name__ == '__main__':
    main()

