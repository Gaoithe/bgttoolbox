bgttoolbox Call Flow Note Example
=================================

[BrocGlasTech Toolbox](../README.md)

## Call Flow, IMS REGISTER and authenticate

WORKAROUND for Subject: Service-Route in REGISTER 200 used incorrectly by . . . 
Use iptables on phones and on IMS core side to forward s-cscf:5054 to p-cscf:5060
Use iptables on phones to forward IMS core Amazon internal 10.x.x.x address to public address.
Open port 5054 in amazon security group - not needed - I think the forwarding of port on phones is working.

@12:10:43 in log
  |   1. SIP REGISTER               |                   |
  |-------------------------------->|                   |
  |   2. SIP 401 (Unauthorized)     |<----------------->|
  |<--------------------------------|                   |
  |   3. SIP REGISTER(with response)|                   |
  |-------------------------------->|                   |
  |   4. SIP 200 (OK with Service-Route)<-------------->|
  |<--------------------------------|                   |
  |                .                |                   |
  |                .                |                   |
  |   5. SIP REGISTER(reusing old nonce,response,opaque)|
  |-------------------------------->|                   |
  |   6. SIP 401 (Unauthorized)     |<----------------->|
  |<--------------------------------|                   |
  |   7. SIP REGISTER(empty auth values)                |
  |      **PROBLEM: sent direct to s-cscf**             |
  |      **WORKAROUND: iptables map ip and port**       |
  |---------iptables--------------->|                   |
  |   8. SIP 401 (Unauthorized)     |<----------------->|
  |<--------------------------------|                   |
  |   9. SIP REGISTER(with response)|                   |
  |---------iptables--------------->|                   |
  |   10. SIP 200 (OK with Service-Route)<------------->|
  |<--------------------------------|                   |
  |                .                |                   |

FUNNY#1 - REGISTER reuses old nonce,response,opaque. Maybe because IMS core using minimal authentication (no qop). 3gpp spec says qop SHOULD be used. Talking to IMS core about this.
Silta client does the same. Old nonce,response,opaque is used. but handset behaves correctly and sends REGISTER using new nonce from the 401 and that is answered with 200. see “25-02-2014 14:29:40.096 Verbose stack.cpp:221: RX 1037 bytes Request msg REGISTER/cseq=3 (rdata0x7fb0ac04af48) from UDP xx.xx.xx.xx:5060:”

FUNNY#2 - After REGISTER 401 to the reused response the client logs a pjsip ERROR “imAvailable: false” displays “Sending Technology Changed” message. Next REGISTER sent is an initial register with empty auth values. The new nonce which was sent in the REGISTER 401 is not used.

7. FUNNY#2 REGISTER(empty of auth values this time) 
PROBLEM: sent to Service-Route s-cscf addr:port 10.x.x.x:5054! 
WORKAROUND: iptables map addr:port to p-cscf_public:5060

8. REGISTER 401 Unauthorized with new nonce
9. REGISTER (with response)
10. SIP 200 OK
The handsets can do IMS again (select the SMS/Chat tab). 

@12:13:14 in log
  |                .                |                   |
  |   11. SIP REGISTER(reusing old nonce,response,opaque)
  |----------iptables-------------->|                   |
  |   12. SIP 401 (Unauthorized)    |<----------------->|
  |<--------------------------------|                   |
  |   13. SIP REGISTER(empty auth values)               |
  |---------iptables--------------->|                   |
  |   14. SIP 200 (OK with Service-Route)<------------->|
  |<--------------------------------|                   |
  |                .                |                   |
FUNNY#1 and FUNNY#2 again.
FUNNY#3 - 13. SIP REGISTER with empty auth values gets a 200 OK response. Maybe minimal auth works this way? Auth not needed yet? It’s funny/suspicious though.

11. FUNNY#1 REGISTER(reusing old nonce,response,opaque)
12. REGISTER 401 (with new nonce)
13. FUNNY#2 REGISTER(with empty auth values)
14. FUNNY#3 SIP 200 ok in response to empty auth values

@12:15:44 in log
  |                .                |                   |
  |   15. SIP REGISTER(empty auth values)               |
  |---------iptables--------------->|                   |
  |   16. SIP 200 (OK with Service-Route)<------------->|
  |<--------------------------------|                   |
  |                .                |                   |
FUNNY#2 and FUNNY#3 again
FUNNY#4 ~~ combination of FUNNY#2 and FUNNY#3 ~~ REGISTER with empty auth values now sent
15. FUNNY#2 REGISTER(with empty auth values)
16. FUNNY#3 SIP 200 ok in response to empty auth values

@12:16:48 in log
  |                .                |                   |
  |   17. SIP OPTIONS               |                   |
  |---------iptables--------------->|                   |
  |   18. SIP 403 (Forbidden)       |                   |
  |<--------------------------------|                   |
  |                .                |                   |
FUNNY #5 OPTIONS answered with 403 forbidden. So in spite of last SIP 200 answers to REGISTER the system doesn’t regard the handset as authenticated.


