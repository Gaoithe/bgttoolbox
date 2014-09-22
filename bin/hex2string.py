#!/usr/bin/python

'''
[james@nebraska vmware]$ hex2string.py ../perimeta_capture_options_and_invite.txt  |less

2014-09-01 12:08:16.069100 IP (tos 0x0, ttl 49, id 7592, offset 0, flags [DF], proto TCP (6), length 1236)
    10.1.2.63.42778 > 10.1.2.60.6060: Flags [P.], cksum 0x8737 (correct), seq 1:1185, ack 1668, win 8011, options [nop,nop,TS val 17328516 ecr 237442751], length 1184
ASCII: E.....@.1...
ASCII: ..?
ASCII: ..<....E.)<.^L.B...K.7.....
ASCII: ..i..'..SIP/2.0 200 OK
ASCII: Via: SIP/2.0/TCP 10.1.2.60:6060;received=83.71.251.187;branch=z9hG4bK+30802d8f614114b8d72a5d9450d66f241+sip+1+a64e7919
ASCII: Record-Route: <sip:83.71.251.187:6060;lr>
ASCII: Call-ID: 0gQAAC8WAAACBAAALxYAABocc+WSwN3H3ir1ObmGz4OdXKV+yTn2dx9L7yoW6PAo6pm4GQxY5q7FaE0n3x5G1A--@10.1.2.60
ASCII: From: <sip:+353861953134@openims.test>;tag=10.1.2.60+1+b5954781+a4a984b3
ASCII: To: <sip:+353894468340@openims.test;user=phone>;tag=z9hG4bK+30802d8f614114b8d72a5d9450d66f241+sip+1+a64e7919
ASCII: CSeq: 422 OPTIONS
ASCII: Allow: PRACK, INFO, INVITE, ACK, BYE, CANCEL, UPDATE, SUBSCRIBE, NOTIFY, REFER, MESSAGE, OPTIONS
ASCII: 
ASCII: Supported: replaces, 100rel, timer, norefersub
ASCII: 
ASCII: User-Agent: IM-client/OMA1.0 HTC/saga-2.3.5 RCSAndrd/2.5.2 COMLib/3.5.5
ASCII: Contact: <sip:+353894468340@192.168.128.211:42778;transport=TCP;ob>;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.joyn.intmsg,urn%3Aurn-7%3A3gpp-application.ims.iari.rcs.fthttp,urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.ft,urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.im,urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.stickers";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.mmtel";+g.gsma.rcs.ipcall;video
ASCII: Accept: application/sdp
ASCII: Content-Length:  0

'''

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


