bgttoolbox Call Flow Note Example
=================================

[BrocGlasTech Toolbox](../README.md)

## Call Flow, IMS REGISTER and authenticate

Subject: Service-Route in REGISTER 200 used incorrectly by client in subsequent REGISTER . . . 

      +--------------+                 +--------+         +--------+
      | IMS client   |                 | P-CSCF |         | S-CSCF |
      +--------------+                 +--------+         +--------+
       |                                 |                   |
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
       |                .                |                   |
       |   5. SIP REGISTER               |                   |
       |-------------------------------->|                   |
       |   6. SIP 401 (Unauthorized)     |<----------------->|
       |<--------------------------------|                   |
       |   7. SIP REGISTER(with response, with Route:, **PROBLEM: sent direct to s-cscf**)
       |--------------------------------->xxxxxxxxxxxxxxxxxxx|
       |                .                |                   |


Initially: 1. REGISTER, 2. REGISTER 401, 3. REGISTER(with response), 4. REGISTER 200 OK are exchanged using p-cscf port 5060. All fine. There is a Service-Route in the REGISTER 200 OK with sprout port 5054 in it.

After this OPTIONS and INVITE messages from client are sent with Route like this:
   Route: <sip:<publicip>:5060;lr>
   Route: <sip:<publicname>:5054;transport=TCP;lr;orig>
That is correct. Route contains p-cscf, s-cscf.

About 2 minutes later the subsequent 5. REGISTER, 6. REGISTER 401 are exchanged (REGISTER sent using p-cscf port 5060). All okay up to this point.

Then the client tries to send 7. a REGISTER(with response) but it is sending it to port 5054! 
**This is the main PROBLEM. It should not be sent direct to s-cscf**
This REGISTER message also has Route: with just the s-cscf:5054 inside it.
The REGISTER messages should not use the use the Service-Route in Route:.

+--------------------------------------------------------------------+

IMS core is behaving correctly, sending the correct Service-Route.
The s-cscf address:port is sent in the Service-Route.
This is an internal address:port in IMS core.
  Service-Route: <sip:<publicname>:5054;transport=TCP;lr;orig> 
The client should put that route in Route: header in initial messages which are not REGISTER messages.
The client is doing that okay.
The client should not try to send any messages direct to s-cscf using that address:port.

We can see In another system(bics/SMX) Service-Route in REGISTER 200 OK is like this:
   Service-Route: <sip:+353898888888@xx.xx.xx.xx:5060;transport=udp;lr;p_orig>;ob
The IP address and port used there is the same as the p-cscf.
If that was incorrectly used as address:port to send a message to it would not cause a problem.

+--------------------------------------------------------------------+

http://tools.ietf.org/html/rfc3608

    3.  Discussion of Mechanism, 6.1. Procedures at the UA
    The client should use that Service-Route in Route headers on initial requests other than REGISTERS.

from 3GPP 24.229

    On receiving the 200 (OK) response to the REGISTER request, the UE shall:
    a)	store the expiration time of the registration for the public user identities found in the To header field value and bind it either to the respective contact address of the UE or to the registration flow and the associated contact address (if the multiple registration mechanism is used);
    	NOTE 6:	If the UE supports RFC 6140 [191] and performs the functions of an external attached network, the To header field will contain the main URI of the UE.
    b)	store as the default public user identity the first URI on the list of URIs present in the P-Associated-URI header field and bind it to the respective contact address of the UE and the associated set of security associations or TLS session;
    NOTE 7:	When using the respective contact address and associated set of security associations or TLS session, the UE can utilize additional URIs contained in the P-Associated-URI header field and bound it to the respective contact address of the UE and the associated set of security associations or TLS session, e.g. for application purposes.
    c)	treat the identity under registration as a barred public user identity, if it is not included in the P-Associated-URI header field;
    d)	store the list of service route values contained in the Service-Route header field and bind the list either to the contact address or to the registration flow and the associated contact address (if the multiple registration mechanism is used), and the associated set of security associations or TLS session over which the REGISTER request was sent;
    NOTE 8:	When multiple registration mechanism is not used, there will be only one list of service route values bound to a contact address. However, when multiple registration mechanism is used, there will be different list of service route values bound to each registration flow and the associated contact address.
    NOTE 9:	The UE will use the stored list of service route values to build a proper preloaded Route header field for new dialogs and standalone transactions (other than REGISTER method) when using either the respective contact address or to the registration flow and the associated contact address (if the multiple registration mechanism is used), and the associated set of security associations or TLS session.
    
## Call Flow, REGISTER and Subsequent REGISTER with iptables WORKAROUND

WORKAROUND for Subject: Service-Route in REGISTER 200 used incorrectly by . . . 
Use iptables on phones and on IMS core side to forward s-cscf:5054 to p-cscf:5060
Use iptables on phones to forward IMS core Amazon internal 10.x.x.x address to public address.
Open port 5054 in amazon security group - not needed - I think the forwarding of port on phones is working.

@12:10:43 in log

    +--------------+             +--------+         +--------+
    | IMS client   |             | P-CSCF |         | S-CSCF |
    +--------------+             +--------+         +--------+
    |                                 |                   |
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
    Other client does the same. Old nonce,response,opaque is used. but handset behaves correctly and sends REGISTER using new nonce from the 401 and that is answered with 200. see “25-02-2014 14:29:40.096 Verbose stack.cpp:221: RX 1037 bytes Request msg REGISTER/cseq=3 (rdata0x7fb0ac04af48) from UDP xx.xx.xx.xx:5060:”

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


