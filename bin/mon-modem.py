#!/usr/bin/python

"""gtk-photo-slideshow.py [-hwrd] [dirs]
 -h --help
 -w --window
 -r --repeat
 -d --delay (TODO: doesn't take a number yet)

python script quick and simplish photo slideshow of directories
"""

"""
192.168.1.255/255.255.255.255   255.255.255.255 Ethernet 100BT        Bcast
224.0.0.0/224.0.0.0             0.0.0.0         --                    Other
224.0.0.9/255.255.255.255       0.0.0.0         --                    Other
224.0.0.251/255.255.255.255     0.0.0.0         --                    Other
224.0.0.252/255.255.255.255     0.0.0.0         --                    Other
239.192.83.80/255.255.255.255   0.0.0.0         --                    Other
239.255.255.250/255.255.255.255 0.0.0.0         --                    Other
255.255.255.255/255.255.255.255 255.255.255.255 --                    Bcast

Ethernet IP ARP table:
0: IP 192.168.1.8 Hardware 00-08-9b-bf-e4-67/(if[66]/vid[1]) flags VALID 
1: IP 192.168.1.46 Hardware 8c-77-12-a6-65-eb/(if[73]/vid[1]) flags VALID 
2: IP 192.168.1.18 Hardware a0-0b-ba-d9-14-6a/(if[73]/vid[1]) flags VALID 
3: IP 192.168.1.3 Hardware 00-13-02-a6-2d-1c/(if[73]/vid[1]) flags VALID 
4: IP 192.168.1.40 Hardware c0-65-99-39-d7-8f/(if[73]/vid[1]) flags VALID 
5: IP 192.168.1.33 Hardware 00-22-58-5b-c4-72/(if[73]/vid[1]) flags VALID 
6: IP 192.168.1.25 Hardware 00-1f-3c-cd-00-3b/(if[73]/vid[1]) flags VALID 

LAN Host Discovery Table:
Host-Name        IP               MAC               Interface State
jamesc-laptop    192.168.1.3      00-13-02-a6-2d-1c Wireless  online
GreenSpace       192.168.1.8      00-08-9b-bf-e4-67 Eth 100BT online
android-620bf34  192.168.1.18     a0-0b-ba-d9-14-6a Wireless  online
User-PC          192.168.1.25     00-1f-3c-cd-00-3b Wireless  online
BRW0022585BC472  192.168.1.33     00-22-58-5b-c4-72 Wireless  online
192.168.1.39     192.168.1.39     78-9e-d0-f9-a3-97 Wireless  offline
android-f342923  192.168.1.40     c0-65-99-39-d7-8f Wireless  online
android-99ec341  192.168.1.46     8c-77-12-a6-65-eb Wireless  online

Firewall information:
Low Level Statistics:
        Blocked ICMP Packets:            5
        Blocked TCP Packets:            29
        Blocked UDP Packets:             1
        Packets with no route:           0
IP NAT used list, total = 48
Key Inside_Address :Port     Outside_Address:Port     OPort  Life   Prot
044 192.168.001.025:52150    091.190.216.065:12350    50214  14195  TCP  
109 192.168.001.025:52392    159.134.172.161:00443    50826  14355  TCP  
119 192.168.001.018:59341    199.167.177.042:01227    49915  14353  TCP  
120 192.168.001.018:36770    069.171.235.048:00443    49158  13763  TCP  
127 192.168.001.039:36951    074.125.024.188:05228    50128  12825  TCP  
160 192.168.001.040:33863    046.137.127.127:00443    50143  14393  TCP  
166 192.168.001.018:42574    074.125.024.102:00443    50942  14283  TCP  
172 192.168.001.046:36288    074.125.024.102:00443    50948  14242  TCP  
173 192.168.001.003:59358    074.125.024.101:00443    50950  14387  TCP  
179 192.168.001.025:52458    074.125.024.101:00443    50956  14397  TCP  
181 192.168.001.025:52451    074.125.024.120:00443    50939  00009  TCP  
185 192.168.001.018:36207    074.125.024.188:05228    49162  14282  TCP  
190 192.168.001.025:52448    074.125.024.132:00443    50936  14399  TCP  
205 192.168.001.025:52418    159.134.196.177:00443    50906  14368  TCP  
226 192.168.001.025:52439    159.134.196.177:00443    50927  14368  TCP  
231 192.168.001.025:52437    023.002.024.184:00443    50925  14368  TCP  
232 192.168.001.025:52438    023.002.024.184:00443    50926  14368  TCP  
308 192.168.001.046:49071    074.125.024.188:05228    49285  13930  TCP  
319 192.168.001.040:49062    074.125.024.188:05228    49296  14047  TCP  
328 192.168.001.039:51858    054.247.185.131:05223    50135  12841  TCP  
378 192.168.001.025:52412    075.098.009.100:00443    50900  00016  TCP  
379 192.168.001.025:52413    075.098.009.100:00443    50901  00016  TCP  
474 192.168.001.025:52153    194.132.198.051:04070    50234  14341  TCP  
483 192.168.001.039:50533    192.237.150.036:05223    50129  13717  TCP  
592 192.168.001.039:50031    192.237.150.040:05223    49210  09607  TCP  
641 192.168.001.025:52238    074.125.024.138:00443    50357  14398  TCP  
675 192.168.001.046:48688    173.194.138.144:00443    50897  14399  TCP  
716 192.168.001.025:52157    173.194.078.125:05222    50274  14394  TCP  
760 192.168.001.040:35166    069.171.233.033:00443    49301  13924  TCP  
767 192.168.001.025:52149    064.004.061.152:00443    50213  14315  TCP  
769 192.168.001.254:02873    159.134.000.001:00053    02873  00021  UDP  
770 192.168.001.254:02874    159.134.000.001:00053    02874  00021  UDP  
771 192.168.001.254:02875    159.134.000.001:00053    02875  00025  UDP  
772 192.168.001.254:02876    159.134.000.001:00053    02876  00025  UDP  
773 192.168.001.254:02877    159.134.000.001:00053    02877  00054  UDP  
774 192.168.001.254:02878    159.134.000.001:00053    02878  00055  UDP  
775 192.168.001.254:02879    159.134.000.001:00053    02879  00057  UDP  
776 192.168.001.254:02880    159.134.000.001:00053    02880  00066  UDP  
777 192.168.001.254:02881    159.134.000.001:00053    02881  00088  UDP  
778 192.168.001.254:02882    159.134.000.001:00053    02882  00176  UDP  
779 192.168.001.254:02883    159.134.000.001:00053    02883  00179  UDP  
780 192.168.001.025:52220    173.194.078.125:05222    50338  14355  TCP  
786 192.168.001.018:44290    054.225.250.247:04244    49152  13912  TCP  
802 192.168.001.040:52288    054.195.243.043:05223    49161  13327  TCP  
891 192.168.001.025:52147    064.004.023.142:40003    50211  14392  TCP  
914 192.168.001.025:52423    008.025.035.113:00443    50911  00016  TCP  
915 192.168.001.025:52424    008.025.035.113:00443    50912  00016  TCP  
1009 192.168.001.025:52393    074.125.024.017:00443    50846  14391  TCP  

==== Lan Switch/Wan bridge interfaces  ====

Link Id  Physical Address  Mask       Exclusive  Port
-------  ----------------- ---------- ---------- ----------
  0      00-00-00-00-00-00 0x00000002            eth0.1(p[0]fd[63])
  1      00-24-93-6c-59-c0 0x00000002     uplink eth-0-lan-uplink
  2      00-00-00-00-00-00 0x00000002            eth0.1(p[1]fd[64])
  3      00-00-00-00-00-00 0x00000002            eth0.1(p[2]fd[65])
  4      00-00-00-00-00-00 0x00000002            eth0.1(p[3]fd[66])
  5      00-00-00-00-00-00 0x00000002            wrlss.1(p[0]fd[73])

==== Lan Switch/Wan bridge table  ====

Station  MAC Address       Mask       Port
-------  ----------------- ---------- ----------
001.     00-24-93-6c-59-c0 0x00000002 (eth-0-lan-uplink)
002.     00-08-9b-bf-e4-67 0x00000002 (eth0.1(p[3]fd[66]))
003.     c0-65-99-39-d7-8f 0x00000002 (wrlss.1(p[0]fd[73]))
004.     00-13-02-a6-2d-1c 0x00000002 (wrlss.1(p[0]fd[73]))
005.     01-00-5e-00-00-fc 0x00000002 (wrlss.1(p[0]fd[73]))
006.     8c-77-12-a6-65-eb 0x00000002 (wrlss.1(p[0]fd[73]))
007.     01-00-5e-7f-ff-fa 0x00000002 (wrlss.1(p[0]fd[73]))
008.     01-00-5e-00-00-fb 0x00000002 (wrlss.1(p[0]fd[73]))
009.     a0-0b-ba-d9-14-6a 0x00000002 (wrlss.1(p[0]fd[73]))
010.     00-1f-3c-cd-00-3b 0x00000002 (wrlss.1(p[0]fd[73]))
011.     01-00-5e-40-53-50 0x00000002 (wrlss.1(p[0]fd[73]))

The number of WAN users is unlimited.
When the number of WAN users is unlimited, this information
is not available.

DHCP: No Lease for client on interface WAN 1a

DHCP server lease table:
Host Name          IP Address       Hardware Address  Status     Timeout  
                                                                 (dd:hh:mm:ss)
jamesc-laptop      192.168.1.3      00-13-02-a6-2d-1c Active     00:00:54:17
GreenSpace         192.168.1.8      00-08-9b-bf-e4-67 Active     00:00:45:31
android-620bf34bbfce835d192.168.1.18     a0-0b-ba-d9-14-6a Active     00:00:39:37
User-PC            192.168.1.25     00-1f-3c-cd-00-3b Active     00:00:45:09
BRW0022585BC472    192.168.1.33     00-22-58-5b-c4-72 Active     00:00:43:58
                   192.168.1.39     78-9e-d0-f9-a3-97 Active     00:00:33:43
android-f342923955b92ba5192.168.1.40     c0-65-99-39-d7-8f Active     00:00:39:24
android-99ec341726a65197192.168.1.46     8c-77-12-a6-65-eb Active     00:00:46:43

PPP driver information:
PPP: (WAN 1a)

  NCP Protocol: (c021) LCP
  NCP state: OPEN

  LCP Options:
   Local MRU:  1492                      Remote MRU:  1492
   Local to Peer ACC map: 0x00000000     Peer to Local ACC map: 0x00000000
   Local authentication type:  NONE      Remote authentication type:  CHAP
   Local magic number: 0xe56ef094        Remote magic number: 0x29010559
   Transmit FCS size (in bits):  16      Receive FCS size (in bits):  16
   Local to Remote protocol compression: Disabled
   Remote to Local protocol compression: Disabled
   Local to Remote header and address compression: Disabled
   Remote to Local header and address compression: Disabled

  Packets in:          944        Packets Out:             0

  NCP Protocol: (8021) IPCP
  NCP state: OPEN

  IP Information:
   IP operation status: OPEN
   IP local to remote compression protocol: NONE
   IP remote to local compression protocol: NONE
  Packets in:       111264        Packets Out:         79187

PPPoE information for PPP(0) running over ENET:
   Session State                   : PPPoE session is active
   Host Uniq                       : 0x1
   Server Mac Address              : 00-90-1a-42-5a-1b
   Session ID                      : Ox0ecc


BACKUP:
     Current Port:         Primary
     Current State:        Not Enabled

Crash of Netopia-2000/157092174272 (Netopia-2000, rev 1), HwID 0x0, Model 2247-62
running version 7.8.2r2, SKU: Eircom



Crash PC       : 0x94073768

Frame Pointers:
 9403ccf8
 94041244
 94200730
 94193c18
 9436e044
 9435e7d8
 94361f64

Registers:
  r1_at     = 94610000  r2_v0     = 00000000  r3_v1     = 948e2f90  r4_a0     = 00000018
  r5_a1     = ffffffff  r6_a2     = ffffffff  r7_a3     = 948e474c  r8_t0     = 0000ff01
  r9_t1     = ffff00ff  r10_t2    = 000000dd  r11_t3    = 00000000  r12_t4    = 948e4700
  r13_t5    = 00000000  r14_t6    = 00000010  r15_t7    = 949136b4  r16_s0    = 0000020c
  r17_s1    = 00000004  r18_s2    = 948e474c  r19_s3    = 94c3d328  r20_s4    = 00000001
  r21_s5    = 00000000  r22_s6    = 00000000  r23_s7    = 949847d4  r24_t8    = 00000001
  r25_t9    = 94c3fcd0  r26_k0    = 943c5730  r28_gp    = 94504b20  r29_sp    = 948e4728
  r30_fp    = 00000001  r31_ra    = 94073760  hi        = 00000000  lo        = 00000800
  index     = 2608edb8  entrylo0  = 22c9f00f  context   = 78800000  badvaddr  = 00000020
  compare   = 2f8ad6d6  status    = 0000ff03  cause     = 1080000c  epc       = 94073768

Message Log:
3/1/14 05:16:45 PM L5      KS: Using configured options found in flash
3/1/14 05:16:45 PM L5      KS: Customer default options found in flash - using
3/1/14 05:16:45 PM L3      BOOT: Warm start v7.8.2 ----------------------------------
3/1/14 05:16:45 PM L3       
3/1/14 05:16:45 PM L3      IP address server initialization complete 
3/1/14 05:16:45 PM L3      HB: heartbeat service initializing
3/1/14 05:16:45 PM L3      HB: heartbeat option disabled
3/1/14 05:16:45 PM L4      BR: Using saved configuration options
3/1/14 05:16:45 PM L4      BR: Netopia SOC OS version 7.8.2 (build r2)
3/1/14 05:16:45 PM L4      BR: Netopia-2000/157092174272 (Netopia-2000, rev 1), PID 1225
3/1/14 05:16:45 PM L4      BR: last install status: 
3/1/14 05:16:45 PM L4      BR: memory sizes - 4096K Flash, 16384K RAM
3/1/14 05:16:45 PM L3      BR: Starting kernel
3/1/14 05:16:45 PM L3      AAL5: initializing service
3/1/14 05:16:45 PM L4      ATM: Waiting for PHY layer to come up
3/1/14 05:16:45 PM L3      POE: Initializing PPP over Ethernet service
3/1/14 05:16:45 PM L4      POE: Binding to Ethernet (ether/vcc1)
3/1/14 05:16:45 PM L3      BRDG: Configuring port (10/100BT-LAN)
3/1/14 05:16:45 PM L3      BRDG: Bridge not enabled for WAN.
3/1/14 05:16:45 PM L3      BRDG: Bridging from one WAN port to another is disabled
3/1/14 05:16:45 PM L3      BRDG: Initialization complete
3/1/14 05:16:45 PM L4      IP: Routing between WAN ports is disabled
3/1/14 05:16:45 PM L4      IP: IPSec client pass through is enabled
3/1/14 05:16:45 PM L4      IP: Address mapping enabled on interface PPP over Ethernet vcc1
3/1/14 05:16:45 PM L3      IP: Adding default gateway over PPP over Ethernet vcc1
3/1/14 05:16:45 PM L3      IP: Initialization complete
3/1/14 05:16:45 PM L3      IPSec: initializing service
3/1/14 05:16:45 PM L3      IPSec: No feature key available - service disabled
3/1/14 05:16:45 PM L3      PPP: PPP over Ethernet vcc1 binding to PPPoE
3/1/14 05:16:45 PM L3      PPP: PPP over Ethernet vcc1 Port listening for PPP requests
3/1/14 05:16:45 PM L3      BRDG: (10/100BT-LAN) Port Physical Link Active
3/1/14 05:16:45 PM L3      IP: (10/100BT-LAN) Ethernet Physical Link Active
3/1/14 05:16:45 PM L3      IP: (10/100BT-LAN) IP Protocol Up
3/1/14 05:16:45 PM L3      RIP: initializing
3/1/14 05:16:45 PM L3      DHCP: Initializing Service
3/1/14 05:16:45 PM L3      DHCP: Setup Server On UDP Port 67
3/1/14 05:16:45 PM L3      DHCP: Setup Client On UDP Port 68
3/1/14 05:16:45 PM L3      DNS: initializing service
3/1/14 05:16:45 PM L4      DNS: nameserver address is 0.0.0.0
3/1/14 05:16:45 PM L3      SNMP: initializing service over UDP
3/1/14 05:16:45 PM L3      DIA: Diagnostics service initializing
3/1/14 05:16:45 PM L3      FW: initializing service
3/1/14 05:16:45 PM L3      SSL: Initializing Service
3/1/14 05:16:45 PM L3      SSL: Installed Verisign, Equifax & Thawte Root CA certificates
3/1/14 05:16:45 PM L3      SSL: Initialization Success
3/1/14 05:16:46 PM L3      LHD: IP  192.168.1.8, MAC 00-08-9b-bf-e4-67
3/1/14 05:16:46 PM L3      LHD: Interface  Eth 100BT, State online
3/1/14 05:16:53 PM L3      Wireless: Driver Initialized
3/1/14 05:17:01 PM L3      LHD: IP  192.168.1.39, MAC 78-9e-d0-f9-a3-97
3/1/14 05:17:01 PM L3      LHD: Interface  Wireless, State online
3/1/14 05:17:08 PM L3      LHD: IP  192.168.1.40, MAC c0-65-99-39-d7-8f
3/1/14 05:17:08 PM L3      LHD: Interface  Wireless, State online
3/1/14 05:17:18 PM L3      LHD: IP  192.168.1.18, MAC a0-0b-ba-d9-14-6a
3/1/14 05:17:18 PM L3      LHD: Interface  Wireless, State online
3/1/14 05:17:49 PM L4      RFC1483-1 up 
3/1/14 05:17:50 PM L3       AC-Name=bbh1.bras
3/1/14 05:17:50 PM L3       Host-Uniq 00000001
3/1/14 05:17:50 PM L3       Service-Name=ANY
3/1/14 05:17:50 PM L3       AC-Cookie 3287D093E38568A8614C8F3153432C15
3/1/14 05:17:55 PM L3      lcp: LCP Send Config-Request+
3/1/14 05:17:55 PM L3       MRU 0x5d4+ MAGIC 0xe56ef094+
3/1/14 05:17:55 PM L3      lcp: LCP Recv Config-Req:+
3/1/14 05:17:55 PM L3       MRU(1492) (ACK) AUTHTYPE(c223) (CHAP) (ACK) MAGICNUMBER
3/1/14 05:17:55 PM L3      (29010559) (ACK)
3/1/14 05:17:55 PM L3      lcp: returning Configure-Ack
3/1/14 05:17:55 PM L3      chap: received challenge, id 247
3/1/14 05:17:55 PM L3      chap: received success, id 247
3/1/14 05:17:55 PM L3      ipcp: IPCP Config-Request+
3/1/14 05:17:55 PM L3       ADDR(0.0.0.0) DNS(0.0.0.0) DNS2(0.0.0.0) WINS(0.0.0.0)
3/1/14 05:17:55 PM L3       WINS2(0.0.0.0)
3/1/14 05:17:55 PM L3      ipcp: IPCP Config-Request+
3/1/14 05:17:55 PM L3       ADDR(0.0.0.0) DNS(0.0.0.0) DNS2(0.0.0.0)
3/1/14 05:17:55 PM L3      ipcp: IPCP Config-Request+
3/1/14 05:17:55 PM L3       ADDR(86.42.135.129) DNS(159.134.0.1) DNS2(159.134.0.2)
3/1/14 05:17:55 PM L3      ipcp: IPCP Recv Config-Req:+
3/1/14 05:17:55 PM L3       ADDR(159.134.155.19) (ACK)
3/1/14 05:17:55 PM L3      ipcp: returning Configure-ACK
3/1/14 05:17:55 PM L3      ipcp: negotiated remote IP address 159.134.155.19
3/1/14 05:17:55 PM L3      ipcp: negotiated IP address 86.42.135.129
3/1/14 05:17:55 PM L3      ipcp: negotiated TCP hdr commpression off
3/1/14 05:18:00 PM L3      NTP: Update system date & time 
3/1/14 05:18:00 PM L4      TR-069: Resolving ACS URL - Retry 0
3/1/14 05:18:00 PM L4      TR-069: ACS URL resolved
3/1/14 05:18:00 PM L3      TR-069: Connect to 86.43.56.195 Retry 0
3/1/14 05:18:01 PM L3      SSL: Handshake Success
3/1/14 05:18:01 PM L3      SSL: Connect Success: nbbs.eircom.ie
3/1/14 05:18:01 PM L3      SSL: Certificate Verify Success: nbbs.eircom.ie
3/1/14 05:18:01 PM L3      TR-069: Post Inform - reason 1 BOOT 
3/1/14 05:18:02 PM L3      TR-069: Server auth challenge received
3/1/14 05:18:04 PM L3      TR-069: Closing connection on HTTP 204
3/1/14 05:18:04 PM L3      SSL: Closing Connection: nbbs.eircom.ie
3/1/14 05:20:24 PM L3      LHD: IP  192.168.1.3, MAC 00-13-02-a6-2d-1c
3/1/14 05:20:24 PM L3      LHD: Interface  Wireless, State online
3/1/14 05:21:55 PM L3      LHD: IP  192.168.1.33, MAC 00-22-58-5b-c4-72
3/1/14 05:21:55 PM L3      LHD: Interface  Wireless, State online
3/1/14 05:22:48 PM L4      HTTP: "admin" host 192.168.1.18 logging out (timing out)
3/1/14 05:23:03 PM L4      HTTP: "admin" host 192.168.1.40 logging out (timing out)
3/1/14 05:23:19 PM L4      HTTP: "admin" host 192.168.1.39 logging out (timing out)
3/1/14 05:23:58 PM L3      LHD: IP  192.168.1.46, MAC 8c-77-12-a6-65-eb
3/1/14 05:23:58 PM L3      LHD: Interface  Wireless, State online
3/1/14 05:32:02 PM L3      LHD: IP  192.168.1.39, MAC 78-9e-d0-f9-a3-97
3/1/14 05:32:02 PM L3      LHD: Interface  Wireless, State suspect
3/1/14 05:32:03 PM L3      LHD: IP  192.168.1.39, MAC 78-9e-d0-f9-a3-97
3/1/14 05:32:03 PM L3      LHD: Interface  Wireless, State offline
3/1/14 06:17:26 PM L3      LHD: IP  192.168.1.40, MAC c0-65-99-39-d7-8f
3/1/14 06:17:26 PM L3      LHD: Interface  Wireless, State suspect
3/1/14 06:17:26 PM L3      LHD: IP  192.168.1.40, MAC c0-65-99-39-d7-8f
3/1/14 06:17:26 PM L3      LHD: Interface  Wireless, State online
3/1/14 06:48:05 PM L3      LHD: IP  192.168.1.25, MAC 00-1f-3c-cd-00-3b
3/1/14 06:48:05 PM L3      LHD: Interface  Wireless, State online
3/1/14 06:57:47 PM L3      LHD: IP  192.168.1.25, MAC 00-1f-3c-cd-00-3b
3/1/14 06:57:47 PM L3      LHD: Interface  Wireless, State suspect
3/1/14 06:57:47 PM L3      LHD: IP  192.168.1.25, MAC 00-1f-3c-cd-00-3b
3/1/14 06:57:47 PM L3      LHD: Interface  Wireless, State offline
3/1/14 07:06:39 PM L3      LHD: IP  192.168.1.39, MAC 78-9e-d0-f9-a3-97
3/1/14 07:06:39 PM L3      LHD: Interface  Wireless, State online
3/1/14 07:07:53 PM L3      LHD: IP  192.168.1.39, MAC 78-9e-d0-f9-a3-97
3/1/14 07:07:53 PM L3      LHD: Interface  Wireless, State suspect
3/1/14 07:07:53 PM L3      LHD: IP  192.168.1.39, MAC 78-9e-d0-f9-a3-97
3/1/14 07:07:53 PM L3      LHD: Interface  Wireless, State offline
3/1/14 07:11:35 PM L3      LHD: IP  192.168.1.25, MAC 00-1f-3c-cd-00-3b
3/1/14 07:11:35 PM L3      LHD: Interface  Wireless, State online
3/1/14 07:21:55 PM L2      lcp: Sending LCP echo request
3/1/14 07:21:55 PM L2      lcp: Received LCP echo reply
3/1/14 07:22:05 PM L2      lcp: Sending LCP echo request
3/1/14 07:22:05 PM L2      lcp: Received LCP echo reply
3/1/14 07:22:15 PM L2      lcp: Sending LCP echo request
3/1/14 07:22:15 PM L2      lcp: Received LCP echo reply
3/1/14 07:22:25 PM L2      lcp: Sending LCP echo request
3/1/14 07:22:25 PM L2      lcp: Received LCP echo reply
3/1/14 07:22:35 PM L2      lcp: Sending LCP echo request
3/1/14 07:22:35 PM L2      lcp: Received LCP echo reply
3/1/14 07:22:45 PM L2      lcp: Sending LCP echo request
3/1/14 07:22:45 PM L2      lcp: Received LCP echo reply
3/1/14 07:22:55 PM L2      lcp: Sending LCP echo request
3/1/14 07:22:55 PM L2      lcp: Received LCP echo reply
3/1/14 07:23:02 PM L3      LHD: IP  192.168.1.40, MAC c0-65-99-39-d7-8f
3/1/14 07:23:02 PM L3      LHD: Interface  Wireless, State suspect
3/1/14 07:23:02 PM L3      LHD: IP  192.168.1.40, MAC c0-65-99-39-d7-8f
3/1/14 07:23:02 PM L3      LHD: Interface  Wireless, State online
3/1/14 07:23:05 PM L2      lcp: Sending LCP echo request
3/1/14 07:23:05 PM L2      lcp: Received LCP echo reply
3/1/14 07:23:15 PM L2      lcp: Sending LCP echo request
3/1/14 07:23:15 PM L2      lcp: Received LCP echo reply
3/1/14 07:23:25 PM L2      lcp: Sending LCP echo request
3/1/14 07:23:25 PM L2      lcp: Received LCP echo reply
3/1/14 07:23:35 PM L2      lcp: Sending LCP echo request
3/1/14 07:23:35 PM L2      lcp: Received LCP echo reply

Netopia-2000/157092174272> show ?
Use "show" to show system information.
Follow it with:
all-info                      to display all system information at once
atm                           to display ATM information (detail with "all")
backup                        to display Backup interface
bridge                        followed by:
    interfaces                to display bridge interfaces (detail with "all")
    table                     to display bridge table
config                        to display current configuration
crash                         to display current crash-dump information
dsl                           to display DSL statistics
daylight-savings              to display daylight saving info
diffserv                      to print out the diffserv stats
dhcp                          followed by:
    server                    followed by:
        leases                to display DHCP server lease table  *
        store                 to display DHCP server non-volatile storage
    agent                     to display DHCP relay-agent leases
    client                    to display DHCP client leases
dslf                          followed by:
    device-association        to display DSLF Device Association
enet                          to display ethernet statistics (detail with "all")
features                      to display available features
group-mgmt                    to display IGMP Snooping Group Addresses
ip                            followed by:
    interfaces                to display IP interfaces
    routes                    to display IP route tables
    arp                       to display IP ARP cache
    igmp                      to display IGMP Group Addresses
    ipsec                     to display IPSec Tunnel statistics
    firewall                  to display Firewall statistics
    state-insp                to display Stateful inspection statistics
    lan-discovery             to display LAN Discovery table
ipmap                         to dump IP map table
log                           to display next segment of the log (or "all")
memory                        to display memory usage (detail with "all")
ppp                           to display PPP information  *
pppoe                         to display PPPoE information  *
rtsp                          to display current RTSP session info
security-log                  to display security log
status                        to show basic status of unit
summary                       to show summary of current configuration
wan-users                     to show WAN users (detail with "all")
wireless                      to display wireless stats (more with "commands")
vlan                          to show vlan segments

 * More complete help is available for these commands.

Netopia-2000/157092174272> help
arp                           to send ARP request
atmping                       to send ATM OAM loopback
clear                         to erase all stored configuration information
clear_certificate             to clear stored SSL certificate
clear_log                     to clear stored log data
configure                     to configure unit's options
diagnose                      to run self-test
download                      to download config file
exit                          to quit this shell
help                          to get more: "help all" or "help help"
hotspot                       to set or show hotspot authentication info
install                       to download and program an image into flash
license                       to enter an upgrade key to add a feature
log                           to add a message to the diagnostic log
loglevel                      to report or change diagnostic log level
netstat                       to show IP information
nslookup                      to send DNS query for host
ping                          to send ICMP Echo request
quit                          to quit this shell
reset                         to reset subsystems
restart                       to restart unit
show                          to show system information
start                         to start subsystem
status                        to show basic status of unit
telnet                        to telnet to a remote host
traceroute                    to send traceroute probes
upload                        to upload config file
view                          to view configuration summary
wan_type                      to Set WAN interface type
who                           to show who is using the shell
wol                           to Wake On LAN
wps                           to issue Wireless Protected Setup commands
?                             to get help: "help all" or "help help"

Netopia-2000/157092174272> show ipmap
IP NAT used list, total = 54
Key Inside_Address :Port     Outside_Address:Port     OPort  Life   Prot
044 192.168.001.025:52150    091.190.216.065:12350    50214  14125  TCP  
109 192.168.001.025:52392    159.134.172.161:00443    50826  14361  TCP  
119 192.168.001.018:59341    199.167.177.042:01227    49915  14284  TCP  
120 192.168.001.018:36770    069.171.235.048:00443    49158  13694  TCP  
127 192.168.001.039:36951    074.125.024.188:05228    50128  12755  TCP  
160 192.168.001.040:33863    046.137.127.127:00443    50143  14387  TCP  
166 192.168.001.018:42574    074.125.024.102:00443    50942  14393  TCP  
172 192.168.001.046:36288    074.125.024.102:00443    50948  14172  TCP  
173 192.168.001.003:59358    074.125.024.101:00443    50950  14362  TCP  
179 192.168.001.025:52458    074.125.024.101:00443    50956  14397  TCP  
185 192.168.001.018:36207    074.125.024.188:05228    49162  14392  TCP  
200 192.168.001.018:47520    074.125.024.095:00443    50983  14397  TCP  
215 192.168.001.025:52462    074.125.024.132:00443    50961  14379  TCP  
216 192.168.001.025:52463    074.125.024.132:00443    50962  00015  TCP  
223 192.168.001.025:52482    074.125.024.120:00443    50981  14376  TCP  
224 192.168.001.025:52483    074.125.024.120:00443    50982  00005  TCP  
226 192.168.001.025:52473    074.125.024.132:00443    50972  00017  TCP  
227 192.168.001.025:52474    074.125.024.132:00443    50973  00017  TCP  
229 192.168.001.025:52476    074.125.024.132:00443    50975  00017  TCP  
230 192.168.001.025:52477    074.125.024.132:00443    50976  00017  TCP  
245 192.168.001.046:51554    074.125.024.139:00443    50984  14395  TCP  
246 192.168.001.046:59796    074.125.024.139:00443    50985  14395  TCP  
269 192.168.001.025:52459    074.125.024.189:00443    50958  14384  TCP  
307 192.168.001.018:40821    199.016.156.199:00443    50986  14399  TCP  
308 192.168.001.046:49071    074.125.024.188:05228    49285  13861  TCP  
319 192.168.001.040:49062    074.125.024.188:05228    49296  13977  TCP  
328 192.168.001.039:51858    054.247.185.131:05223    50135  12771  TCP  
474 192.168.001.025:52153    194.132.198.051:04070    50234  14391  TCP  
483 192.168.001.039:50533    192.237.150.036:05223    50129  13648  TCP  
592 192.168.001.039:50031    192.237.150.040:05223    49210  09537  TCP  
641 192.168.001.025:52238    074.125.024.138:00443    50357  14380  TCP  
716 192.168.001.025:52157    173.194.078.125:05222    50274  14384  TCP  
760 192.168.001.040:35166    069.171.233.033:00443    49301  13854  TCP  
767 192.168.001.025:52149    064.004.061.152:00443    50213  14365  TCP  
777 192.168.001.254:02881    159.134.000.001:00053    02881  00019  UDP  
778 192.168.001.254:02882    159.134.000.001:00053    02882  00107  UDP  
779 192.168.001.254:02883    159.134.000.001:00053    02883  00110  UDP  
780 192.168.001.254:02884    159.134.000.001:00053    02884  00119  UDP  
780 192.168.001.025:52220    173.194.078.125:05222    50338  14387  TCP  
781 192.168.001.254:02885    159.134.000.001:00053    02885  00154  UDP  
782 192.168.001.254:02886    159.134.000.001:00053    02886  00154  UDP  
783 192.168.001.254:02887    159.134.000.001:00053    02887  00154  UDP  
784 192.168.001.254:02888    159.134.000.001:00053    02888  00154  UDP  
785 192.168.001.254:02889    159.134.000.001:00053    02889  00154  UDP  
786 192.168.001.254:02890    159.134.000.001:00053    02890  00155  UDP  
786 192.168.001.018:44290    054.225.250.247:04244    49152  13842  TCP  
787 192.168.001.254:02891    159.134.000.001:00053    02891  00155  UDP  
788 192.168.001.254:02892    159.134.000.001:00053    02892  00155  UDP  
789 192.168.001.254:02893    159.134.000.001:00053    02893  00156  UDP  
790 192.168.001.254:02894    159.134.000.001:00053    02894  00174  UDP  
791 192.168.001.254:02895    159.134.000.001:00053    02895  00176  UDP  
802 192.168.001.040:52288    054.195.243.043:05223    49161  13257  TCP  
891 192.168.001.025:52147    064.004.023.142:40003    50211  14365  TCP  
1009 192.168.001.025:52393    074.125.024.017:00443    50846  14395  TCP  

Netopia-2000/157092174272> show ip lan-discovery

LAN Host Discovery Table:
Host-Name        IP               MAC               Interface State
jamesc-laptop    192.168.1.3      00-13-02-a6-2d-1c Wireless  online
GreenSpace       192.168.1.8      00-08-9b-bf-e4-67 Eth 100BT online
android-620bf34  192.168.1.18     a0-0b-ba-d9-14-6a Wireless  online
User-PC          192.168.1.25     00-1f-3c-cd-00-3b Wireless  online
BRW0022585BC472  192.168.1.33     00-22-58-5b-c4-72 Wireless  online
192.168.1.39     192.168.1.39     78-9e-d0-f9-a3-97 Wireless  offline
android-f342923  192.168.1.40     c0-65-99-39-d7-8f Wireless  offline
android-99ec341  192.168.1.46     8c-77-12-a6-65-eb Wireless  online

Netopia-2000/157092174272>         

Unrecognized command. Try "help".

Netopia-2000/157092174272> 
telnet> quit
Connection closed.
jamesc@jamesc-laptop:~$ telnet 192.168.1.254 
jamesc@jamesc-laptop:~$ nc -vvvvvv 192.168.1.254 1-24
"""

dDeviceOwners = {'android-f342923':'james-mobile', 
                 'android-620bf34':'fionn-mobile?', 
                 'android-99ec341':'daire-mobile?',
                 'jamesc-laptop':'james-laptop',
                 'User-PC':'fionn-laptop?',
                 '192.168.1.39':'?',
                 '192.168.1.254':'modem',
                 'TODO?':'kate-mobile',
                 'TODO?':'desktop',
                 'TODO?':'xbox',
                 'RODO?':'wii',
                 'android-99ec341':'daire-mobile?',
                 'BRW0022585BC472':'daire-slab?',
                 }
dOwnIPMap = {}

class Device:
    def __init__(self,args):
        self.name = args.group(1)
        self.owner = "unknown-"+self.name
        if self.name in dDeviceOwners:
            self.owner = dDeviceOwners[self.name]
        self.ip = args.group(2)
        dOwnIPMap[self.ip] = self.owner
        self.mac = args.group(3)
        self.interface = args.group(4)
        self.state = args.group(5)
        print "DEVICE:" + self.name + " owner:"+self.owner+ " ip:"+self.ip

import re
conr1 = re.compile(r'\.0+(\d)')
conr2 = re.compile(r'^0+(\d)')
class Connection:
    def __init__(self,args):
        self.fromip = args.group(2)
        self.fromport = args.group(3)
        self.toip = args.group(4)
        self.toport = args.group(5)
        ## translate prefix 0s on ip numbers or port numbers 192.168.001.025
        self.fromip = conr1.sub(r'.\1',self.fromip)
        self.fromip = conr2.sub(r'\1',self.fromip)
        self.fromport = conr2.sub(r'\1',self.fromport)
        self.toip = conr1.sub(r'.\1',self.toip)
        self.toip = conr2.sub(r'\1',self.toip)
        self.toport = conr2.sub(r'\1',self.toport)

        self.oport = args.group(6)
        self.life = args.group(7)
        self.protocol = args.group(8)
        print "CON:" + self.fromip + ":"+self.fromport+ \
            " to:" + self.toip + ":"+self.toport


import sys
import telnetlib


tn = telnetlib.Telnet("192.168.1.254")

TELNET_PROMPT="Netopia.*>"
TIMEOUT=1
#tn.write("term len 0" + "\n")
output = tn.read_until(TELNET_PROMPT, TIMEOUT)

tn.write("show ip lan-discovery"+"\n")
output = tn.read_until(TELNET_PROMPT, TIMEOUT)
print output

lDevices = []
print "DEVICES"
r1 = re.compile(r'(\S+)\s+([\d.]+)\s+([\w-]+)\s+(\S.{8}\w*)\s+(\w+)\s+')
#jamesc-laptop    192.168.1.3      00-13-02-a6-2d-1c Wireless  online
for line in output.splitlines(True):
    #print "LINE >" + line + "<"
    m = r1.match(line)
    if m:
        print 'Device: ', m.group(1)
        lDevices.append(Device(m))

#for d in lDevices:
#    print "Device: " + d.group(1)

lConnections = []
lCons = []
tn.write("show ipmap"+"\n")
output = tn.read_until(TELNET_PROMPT, TIMEOUT)
print output
# TODO open file and print output to it, compare files with diff -u
#  or else print the sorted list

r2 = re.compile(r'(\d+)\s+([\d.]+):(\d+)\s+([\d.]+):(\d+)\s+(\d+)\s+(\d+)\s+(\w+)')
#Key Inside_Address :Port     Outside_Address:Port     OPort  Life   Prot
#008 192.168.001.025:53035    074.125.024.148:00080    49586  14368  TCP  
for line in output.splitlines(True):
    #print "LINE >" + line + "<"
    m = r2.match(line)
    if m:
        print 'CONNECTION: ', m.group(2)
        c = Connection(m)
        lConnections.append(c)
        o = c.fromip
        if c.fromip in dOwnIPMap:
            o = dOwnIPMap[c.fromip]
        lCons.append("" + o + "->" + c.toip + ":" + c.toport)


lCons = sorted(set(lCons))
print lCons


###
# * List connections
#   sort by internal device, UNIQuify
# * show what to ip and port are (build a cache - whois/...)
# 
# * Warn on new/unknown devices
#
# * List connections, show update on any changes // diff -u ?
###

#tn.write("show version" + "\n")
#print tn.read_until(TELNET_PROMPT, TIMEOUT)
tn.write("exit"+"\n")
tn.close()

exit

import os

class DemoGtk:

    SECONDS_BETWEEN_PICTURES = slide_time
    FULLSCREEN = fullscreen
    WALK_INSTEAD_LISTDIR = True

    def __init__(self,args):
        self.window = gtk.Window()
        self.window.connect('destroy', gtk.main_quit)
        self.window.set_title('Slideshow')

        self.image = ResizableImage( True, True, gtk.gdk.INTERP_BILINEAR)
        self.image.show()
        self.window.add(self.image)

        self.load_file_list(args)

        if len(self.files) > 0:
            self.window.show_all()

            if self.FULLSCREEN:
                self.window.fullscreen()
            else: 
                self.window.maximize()
                print "window size:", self.window.get_size()

            glib.timeout_add_seconds(self.SECONDS_BETWEEN_PICTURES, self.on_tick)
            self.display()
        else:
            print "%d images found."% len(self.files)
            print __doc__
            sys.exit(0)

    def load_file_list(self,args):
        """ Find all images """
        self.files = []
        self.index = 0

        for arg in args:
          print "arg:", arg
          if self.WALK_INSTEAD_LISTDIR:    
            for directory, sub_directories, files in os.walk(arg):
                print "dir:", directory
                for filename in files:
                    #print "allfile:", filename
                    filepath = os.path.join(directory, filename)
                    if is_image(filepath):
                        self.files.append(filepath)
                        print "dirFile:", filename
                print "%d images."% len(self.files)
          else:
            for filename in os.listdir(arg):
                if is_image(filename):
                    self.files.append(filename)
                    print "File:", filename
                    #print "Images:", self.files

        #print "Images:", self.files
        print "TOTAL: %d images."% len(self.files)
        # sort in order of date of file
        self.files.sort(key=lambda s: os.path.getmtime(s))

    def display(self):
        """ Sent a request to change picture if it is possible """
        if 0 <= self.index < len(self.files):
            self.image.set_from_file(self.files[self.index])
            print "display index", self.index
            print "display true", self.files[self.index]
            return True
        else:
            print "display false"
            return False

    def on_tick(self):
        """ Skip to another picture.

        If this picture is last, go to the first one. """

        # TODO: check did we manage to show the last image?
        if lastpainted == self.files[self.index]:
            print "happiness"
        else:
            print "much SADness, we should wait some more", lastpainted
            print "much SADness, we should wait some more", self.index
            print "much SADness, we should wait some more", self.files[self.index]

        self.index += 1
        if self.index >= len(self.files):
            if repeat:
                print "wrap"
                self.index = 0
            else:
                # end of show
                sys.exit(0)

        return self.display()


import sys
import getopt

def process_args():
    # parse command line options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hwrdf", ["help","window","repeat","delay"] )
    except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(2)
    # process options
    #global fullscreen
    for o, a in opts:
        if o in ("-h", "--help"):
            print __doc__
            sys.exit(0)
        if o in ("-w", "--window"):
            fullscreen = False
        if o in ("-f", "--fullscreen"):
            fullscreen = True
        if o in ("-r", "--repeat"):
            repeat = True
        if o in ("-d", "--delay"):
            slide_time = 3
    # e.g. process arguments
    #for arg in args:
    #    process(arg) # process() is defined elsewhere
    return args

if __name__ == "__main__":
    args = process_args()
    gui = DemoGtk(args)
    gtk.main()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
