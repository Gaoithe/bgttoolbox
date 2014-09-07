#!/usr/bin/python

import sys
import getopt
import socket
import select

dataTemplate = \
"""OPTIONS sip:+353894468340@openims.test;user=phone SIP/2.0\r
To: <sip:+353894468340@openims.test;user=phone>\r
From: <sip:+353861953134@openims.test>;tag=1yBBhOUWXA\r
Call-ID: 1yBBhOUVXA@192.168.127.133\r
CSeq: 1 OPTIONS\r
Max-Forwards: 70\r
Via: SIP/2.0/TCP 192.168.127.239:5060;branch=z9hG4bK5549b80ac1eb08716ce8269b872ad427363638;rport
Route: <sip:orig@scscf.openims.test:6060;lr>\r
Contact: <sip:+353861953134@192.168.127.133:5060;transport=udp>\r
Accept: application/sdp\r
Accept-Contact: *;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.im,urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.ft,urn%3Aurn-7%3A3gpp-application.ims.iari.rcs.geopush"\r
Content-Length: 0\r
\r
"""

dataTemplate1 = \
"""OPTIONS sip:someone@here.com SIP/2.0\r
To: someone@example.com\r
From: someoneelse@example.com\r
Call-ID: blahblahblah\r
CSeq: 1 OPTIONS\r
Max-Forwards: 70\r
Route: <sip:orig@scscf.open-ims.test:5060;lr>\r
Contact: someone@10.226.203.42\r
\r
"""

dataTemplate2 = \
"""OPTIONS sip:+353894468340@openims.test;user=phone SIP/2.0
Call-ID: 1yBBhOUVXA@192.168.127.133
CSeq: 1 OPTIONS
From: <sip:+353861953134@openims.test>;tag=1yBBhOUWXA
To: <sip:+353894468340@openims.test;user=phone>
Via: SIP/2.0/UDP 192.168.127.133:5060;branch=z9hG4bK8b7ada4eb24246fad1c952e5b9883e2a383538;rport
Max-Forwards: 70
Contact: <sip:+353861953134@192.168.127.133:5060;transport=udp>;+sip.instance="<urn:uuid:ee388fc4-f9e1-3dd6-90d8-48c2947787fb>";+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.im,urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.ft,urn%3Aurn-7%3A3gpp-application.ims.iari.rcs.geopush"
Accept: application/sdp
Accept-Contact: *;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.im,urn%3Aurn-7%3A3gpp-application.ims.iari.rcse.ft,urn%3Aurn-7%3A3gpp-application.ims.iari.rcs.geopush"
Allow: INVITE,UPDATE,ACK,CANCEL,BYE,NOTIFY,OPTIONS,MESSAGE,REFER
Route: <sip:54.216.45.243:4060;transport=udp;lr>,<sip:orig@scscf.openims.test:6060;lr>
P-Preferred-Identity: <sip:+353861953134@openims.test>
User-Agent: IM-client/OMA1.0 Neusoft-Silta-RCSe-client/2.0.1344.33_TR
Content-Length: 0
\r
"""

dataRegister1 = \
"""REGISTER sip:openims.test SIP/2.0\r
Call-ID: d0gl5OUcSA@192.168.127.133\r
CSeq: 1 REGISTER\r
From: <sip:+353861953134@openims.test>;tag=o0gl5OUeSA\r
To: <sip:+353861953134@openims.test>\r
Via: SIP/2.0/TCP 192.168.127.133:5060;branch=z9hG4bK76a660ac0980d32aa1c2826140ca8b85393130;rport\r
Max-Forwards: 70\r
Contact: <sip:+353861953134@192.168.127.133:5060;transport=udp>;+sip.instance="<urn:uuid:ee388fc4-f9e1-3dd6-90d8-48c2947787fb>";+g.oma.sip-im;+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is,urn%3Aurn-7%3A3gpp-application.ims.iari.rcs.geopush"\r
Supported: path, gruu\r
Allow: INVITE,UPDATE,ACK,CANCEL,BYE,NOTIFY,OPTIONS,MESSAGE,REFER\r
Route: <sip:54.216.45.243:4060;transport=udp;lr>\r
Expires: 3600\r
User-Agent: IM-client/OMA1.0 Neusoft-Silta-RCSe-client/2.0.1344.33_TR\r
Content-Length: 0\r
\r
"""


class options:
    def __init__(self):
        self.port = 0
        self.host = ''
        self.data = ''
        self.sock = 0

    def setPort(self,port):
        self.port = int(port)

    def setHost(self,host):
        self.host = host

    def checkVars(self):
        if self.port == 0:
            usage("No port specified")
        if self.host == '':
            usage ("No host specified")
        print "All required variables set"

    def send(self, msg):
        totalsent = 0
        while totalsent < len(msg):
            sent = self.sock.send(msg[totalsent:])
            if sent == 0:
                raise RuntimeError("socket connection broken")
            totalsent = totalsent + sent
            print "Sent tot:%d sent:%d"%(totalsent,sent)
        return totalsent

    def receive(self,l):
        msg = ''
        maxtimes = 10
        loop = 0
        while len(msg) < l and loop < maxtimes:
            print 'wait. select.'
            inputs = [ self.sock ]
            outputs = [ ]
            readable, writable, exceptional = select.select(inputs, outputs, inputs)
            chunk = self.sock.recv(l-len(msg))
            #if chunk == '':
            #    self.sock.close()
            #    raise RuntimeError("socket connection broken")
            msg = msg + chunk
            loop += 1
        return msg

    def createSIPOptions(self):
        self.data = dataRegister1

    def sendSIPOptions(self):
        if self.data == '':
            usage("Cannot send: no data assigned")
        #self.sock = s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock = s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
        #s.setblocking(0)

	print "Connect to: %s:%d"%(self.host,self.port)
        s.connect((self.host,self.port))

	print "Sending to: %s:%d"%(self.host,self.port)
	print "Sending: %s"%self.data
        #srsp = s.sendto(self.data,(self.host,self.port))
        srsp = self.send(self.data)
        print "Send resp:%d"%srsp

        #rsp,addr = s.recvfrom(2048)
        rsp = self.receive(2)
        print "received:%s"%rsp
        rsp = self.receive(4)
        print "received:%s"%rsp
        rsp = self.receive(16)
        print "received:%s"%rsp
        rsp = self.receive(128)
        print "received:%s"%rsp
        rsp = self.receive(2048)
        print "received:%s"%rsp

        s.close()

def usage(msg,status=1):
    print msg
    print "Usage:"
    print "    %s -p <port> -h <host>" % sys.argv[0]
    sys.exit(status)

def main():
    
    opt = options()

    optlist,args = getopt.getopt(sys.argv[1:],'p:-h:')
    for (field,val) in optlist:
        if field == '-p':
            opt.setPort(val)
        if field == '-h':
            opt.setHost(val)

    opt.checkVars()
    opt.createSIPOptions()
    opt.sendSIPOptions()
    #print opt.data

if __name__ == '__main__':
    main()


