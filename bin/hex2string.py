#!/usr/bin/python

import sys
import getopt
import binascii
import re

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

    def hex2string(self, filename):

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
    for (file) in args:
        opt.hex2string(file)

    #print opt.data

if __name__ == '__main__':
    main()


