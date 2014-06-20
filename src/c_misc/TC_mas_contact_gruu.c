
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
//#define SBUG_SOME printf
//#define SBUG_SOME(format, ...) { printf("%s:%d ",__FILE__,__LINE__); printf(format, ## __VA_ARGS__); printf("\n"); }
#define SBUG_SOME(format, ...) { printf("%s:%d ",__FILE__ ":" ,__LINE__); printf(format, ## __VA_ARGS__); printf("\n"); }

#include <string.h>
#define STRDUP strdup
#define RESTRDUP(a,b) strdup(b)


char *tbx_strcatf_va(char *dest, char *format, ...)
{
    va_list ap;
    va_start(ap, format);
    int l = strlen(dest);
    sprintf(dest+l,format,ap);
    va_end(ap);
    return dest;
}

char *tbx_strcatf(char *dest, char *format, char *src)
{
    int l = strlen(dest);
    sprintf(dest+l,format,src);
    return dest;
}

char *tbx_strcatf_2(char *dest, char *format, char *src1, char *src2)
{
    int l = strlen(dest);
    sprintf(dest+l,format,src1,src2);
    return dest;
}

void tbx_free(void *addr)
{
    //if(addr != tbx_empty_string)
        free(addr);
}

void old_contact_test(char *contact_from_invite)
{
// void mcs_ac_set_contact_uri_fn(struct mcs_state_machine_instance *mcs_smi)   from mas/ims/chat_session_actions.c

    const char *tmpPtr = NULL;
    static char *tokBuf = NULL;
    char *tokStr = NULL;
    char *contact = NULL;

    tmpPtr = contact_from_invite; //imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
        if (strlen(tmpPtr) > 0) {
	    SBUG_SOME("contact from invite [%s]", tmpPtr);
            tokBuf = RESTRDUP(tokBuf, tmpPtr);
            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

                contact = strtok(tokStr, ":>");
                SBUG_SOME("1st token [%s]", contact);
                if ((contact = strtok(NULL, ":>")) != NULL)
                {
                    SBUG_SOME("Contact [%s]", contact);
                    printf("Result:\nContact: <sip:%s>", contact);
                    //mcs_smi->contact_uri = STRDUP(contact);
                }
            }
            else {
                // Is this default correct ?
                //mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
                SBUG_SOME("No sip: in contact, using as_uri");
            }
        }
}

void do_contact_test_untidyworking(char *contact_from_invite, char *expected)
{
// void mcs_ac_set_contact_uri_fn(struct mcs_state_machine_instance *mcs_smi)   from mas/ims/chat_session_actions.c

    const char *tmpPtr = NULL;
    static char *tokBuf = NULL;
    static char *conBuf = NULL;
    char *tokStr = NULL;
    char *contact = NULL;
    char *semi = NULL;
    char *seminext = NULL;

    tmpPtr = contact_from_invite; //imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
        if (strlen(tmpPtr) > 0) {
	    SBUG_SOME("contact from invite [%s]", tmpPtr);
            tokBuf = RESTRDUP(tokBuf, tmpPtr);
	    // 1. find sip: (may or may not be within <>s) 
            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

		printf("DEBUG tokStr:%s\n", tokStr);
		// 2. start after sip:, contact is string up to next > or end(strtok sets > to nul)
                contact = strtok(tokStr+4, ">");
                SBUG_SOME("1st token [%s]", contact);
		// 3. next get string up to semi-colon (or end)
		// test is there actually a ';' first
		seminext = strchr(contact, ';');   // strchr returns NULL if char not found
		if (seminext == NULL) printf("just checkin' NULL returned if no semi-colon present\n");
		if (seminext != NULL && seminext[0] == 0) seminext = NULL;
		if (seminext != NULL) seminext++;  // INCREMENT to just after semicolon
		semi = strtok(contact, ";");
		SBUG_SOME("semi token [%s], seminext [%s]", semi, seminext==NULL?"NULL":seminext+1); // +1 because strtok would've just cleared it
		// 4. next get string up to colon (if present)
		contact = strtok(semi, ":");
		
		// 5. put contact back together without the port, if there was one or more ; that bit needs to be added back
		if (seminext != NULL) {

		    // doesn't work in case port stripped
		    // *seminext=';';
		    
		    // doesn't work strcat func gets confused (copying into end of contact FROM ptrs in same area!)
		    //contact = tbx_strcatf(contact,";%s",seminext);

		    //contact = tbx_strcatf(contact,"%s;%s",contact,seminext);
//extern struct tbx_string *tbx_strcat_multi(struct tbx_string *dst,
//extern struct tbx_string *tbx_strcpy_multi(struct tbx_string *dst,
		    char *newcontact = RESTRDUP(blehcontact,newcontact);
		    tbx_strcatf_2(newcontact,"%s;%s",contact,seminext);		    
		    //contact = tbx_strcatf_2(newcontact,"%s;%s",contact,seminext);		    
		    SBUG_SOME("STRCAT newcontact [%s] = contact [%s] + ';' + seminext [%s]", newcontact, contact, seminext);
		    contact = newcontact;

		    // 5. copy back in from semi-colon to end(the > or real end)  (might be doing nothing if semi-colon was not present)
		    // careful now, the contact and seminext strings are pointers into tokBuf area
		}

                {
                    SBUG_SOME("Contact [%s]", contact);
                    printf("Result:\nContact: <sip:%s>", contact);

		    if (expected[0] != 0) { // no test result if blank compare
			if (strcmp(expected,contact) == 0) {
			    printf("Test Result: PASS\n\n");
			} else {
			    printf("Test Result: FAIL\n");
			    printf("Expected Contact: <sip:%s>\n\n",expected);
			}
		    }

                    //mcs_smi->contact_uri = STRDUP(contact);
                }

            }
            else {
                // Is this default correct ?
                //mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
                SBUG_SOME("No sip: in contact, using as_uri");
            }
        }
}



void do_contact_test_duhrr(char *contact_from_invite, char *expected)
{
// void mcs_ac_set_contact_uri_fn(struct mcs_state_machine_instance *mcs_smi)   from mas/ims/chat_session_actions.c

    const char *tmpPtr = NULL;
    static char *tokBuf = NULL;
    char *tokStr = NULL;
    char *contact = NULL;
    char *gtpos = NULL;
    char *semipos = NULL;

    tmpPtr = contact_from_invite; //imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
        if (strlen(tmpPtr) > 0) {
	    SBUG_SOME("contact from invite [%s]", tmpPtr);
            tokBuf = RESTRDUP(tokBuf, tmpPtr);
	    // 1. find sip: (may or may not be within <>s) 
            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

		printf("DEBUG tokStr:%s\n", tokStr);
		// 2. start after sip:, find next > (or ; if no >)
                contact = tokStr+4;
                SBUG_SOME("1st token [%s]", contact);
		// 3. next get string up to semi-colon (or end)
		// test is there actually a ';' first
		gtpos = strchr(contact, '>');   // strchr returns NULL if char not found
		if (gtpos != NULL) { 
		    gtpos[0] = 0;
		    // end the string at >.
		} else {
		    // no >
		    semipos = strchr(contact, ';');   // strchr returns NULL if char not found
		    if (semipos != NULL) {
			semipos[0] = 0;
		    }
		}

                {
                    SBUG_SOME("Contact [%s]", contact);
                    printf("Result:\nContact: <sip:%s>", contact);

		    if (expected[0] != 0) { // no test result if blank compare
			if (strcmp(expected,contact) == 0) {
			    printf("Test Result: PASS\n\n");
			} else {
			    printf("Test Result: FAIL\n");
			    printf("Expected Contact: <sip:%s>\n\n",expected);
			}
		    }

                    //mcs_smi->contact_uri = STRDUP(contact);
                }

            }
            else {
                // Is this default correct ?
                //mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
                SBUG_SOME("No sip: in contact, using as_uri");
            }
        }
}



// tidy up
void do_contact_test(char *contact_from_invite, char *expected)
{
// void mcs_ac_set_contact_uri_fn(struct mcs_state_machine_instance *mcs_smi)   from mas/ims/chat_session_actions.c

    const char *tmpPtr = NULL;
    static char *tokBuf = NULL;
    char *tokStr = NULL;
    char *contact = NULL;
    char *gtpos = NULL;
    char *semipos = NULL;

    tmpPtr = contact_from_invite; //imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
        if (strlen(tmpPtr) > 0) {
	    SBUG_SOME("contact from invite [%s]", tmpPtr);
            tokBuf = RESTRDUP(tokBuf, tmpPtr);


	    // 1. find sip: (may or may not be within <>s) 
            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

		printf("DEBUG tokStr:%s\n", tokStr);
		// 2. start after sip:, find next > (or ; if no >)
                contact = tokStr+4;
                SBUG_SOME("1st token [%s]", contact);
		// 3. next get string up to semi-colon (or end)
		// test is there actually a ';' first
		gtpos = strchr(contact, '>');   // strchr returns NULL if char not found
		if (gtpos != NULL) { 
		    gtpos[0] = 0;
		    // end the string at >.
		} else {
		    // no >
		    semipos = strchr(contact, ';');   // strchr returns NULL if char not found
		    if (semipos != NULL) {
			semipos[0] = 0;
		    }
		}

                {
                    SBUG_SOME("Contact [%s]", contact);
                    printf("Result:\nContact: <sip:%s>", contact);

		    if (expected[0] != 0) { // no test result if blank compare
			if (strcmp(expected,contact) == 0) {
			    printf("Test Result: PASS\n\n");
			} else {
			    printf("Test Result: FAIL\n");
			    printf("Expected Contact: <sip:%s>\n\n",expected);
			}
		    }

                    //mcs_smi->contact_uri = STRDUP(contact);
                }

            }
            else {
                // Is this default correct ?
                //mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
                SBUG_SOME("No sip: in contact, using as_uri");
            }
        }
}


// Fri 6/6/2014 change mind! we want to keep the port in.
// NOTE Contact: sip:stuff;params;params2  the params are assoc with Contact in that case not with the sip: so they should be removed when taking contact
// contractor john did the strtok stuff.
// also where :5060 is hardcoded into contact need to fix . . . - review any strtok stuff
// unit test contacts  (original and expected (all after > stripped is expected))
char *contact_tests[] = {
    "Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>;+g.oma.sip-im",
    "+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7",
    "Contact: <sip:+353894017257@omn-ims.test>",
    "+353894017257@omn-ims.test",
    "Contact: <sip:10.220.105.213:60860>",
    "10.220.105.213:60860",
    "Contact: <sip:10.220.105.213>",
    "10.220.105.213",
    "Contact: <sip:10.220.105.213:5054>;expires=300",
    "10.220.105.213:5054",
    "Contact: <sip:+353861953134@192.168.127.239:48865;ob>;q=0.5;+sip.instance=\"<urn:gsma:imei:35287606-388013-9>\";+g.3gpp.cs-voice;+g.3gpp.iari-ref=\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is\";+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg\";+g.oma.sip-im",
    "+353861953134@192.168.127.239:48865;ob",
    "Contact: <sip:+353894017258@192.168.127.78:55750;ob>;+g.oma.sip-im;+sip.instance=\"<urn:gsma:imei:35592104-358960-3>\"",
    "+353894017258@192.168.127.78:55750;ob",
    "Contact: sip:+353894017258@192.168.127.78:4444;ob;q=0.5",
    "+353894017258@192.168.127.78:4444",
    "Contact: sip:+353894017258@192.168.127.78:41876;ob;q=0.5;expires=300;+sip.instance=\"<urn:gsma:imei:35592104-358960-3\";+g.3gpp.cs-voice;+g.3gpp.iari-ref=\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is\";+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg\";+g.oma.sip-im",
    "+353894017258@192.168.127.78:41876",
    "",
};

int main(int argc, char**argv)
{
    char *contact_from_invite = "Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>;+g.oma.sip-im";
    do_contact_test(contact_from_invite,"");

    if (argc>=2) {
	char *c = NULL;
	size_t len = 0;
	ssize_t read;

	FILE *f=fopen(argv[1],"r");
	if (f == NULL)
	    exit(-3);

	while ((read = getline(&c, &len, f)) != -1) {
	    printf("contact length %zu :\n", read);
	    printf("%s\n", c);
	    do_contact_test(c,"");
	}
	if (c) free(c);   // free here - getline does the initial malloc, realloc if needed during loops
	
	fclose(f);
    } else {

	char *c,*e;
	int i = 0;
	while((c = contact_tests[i++]) != NULL && (e = contact_tests[i++]) != NULL) {
	    printf("TEST %s\n", c);
	    do_contact_test(c,e);
	}
    }

    return 0;
}


#if 0

Hi Garv,

Thanks for pointing directly to where change is needed :)
 from chat_session_actions.c in mcs_ac_set_contact_uri_fn the contact is set . . .

Simple change I think but it probably is in a place which could break things so I have looked at a selection of Contact: samples.
The main thing is we want to strip out :<port> after the <user>@<server> part in sip and we want to keep all parameters.
I assume we wish to keep all parameters inside <> and outside.
Right? :)

The intent(I think) is to just strip off the :<port> in sip contact.
The strtok looks for ":>" and anything after either : or > is stripped. 
2 problems:
1. any param with : is corrupted (the gr=urn param contains : so it is chopped).
2. If there is a :<port> then all parameters after it (and before >) are stripped too. Probably not intended.
Later on everything after > is put back
(from o_invite.c str_create_invite the contact that is set is used and anything after the > is added back)

The way to fix is do first strtok on ";>" instead of ":>" . . .
Then strip off :<port> from the first part.
Then add anything that was between ; and > if there was something there.




i.e. with the gruu contact 
Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>;+g.oma.sip-im
Which do we want?
Contact: <sip:+353894017257@omn-ims.test>
Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>
Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>;+g.oma.sip-im   <=  I think we want this one.
What we get:
Contact: <sip:+353894017257@omn-ims.test;gr=urn>;+g.oma.sip-im

e.g. for other contacts
Contact: <sip:10.220.105.213:60860>
Result:
Contact: <sip:10.220.105.213>
no problem

Contact: <sip:10.220.105.213:5054>;expires=300
Result:
Contact: <sip:10.220.105.213>;expires=300
no problem

Contact: <sip:+353861953134@192.168.127.239:48865;ob>;q=0.5;+sip.instance="<urn:gsma:imei:35287606-388013-9>";+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg";+g.oma.sip-im
Result: (;ob unintentionally stripped)
Contact: <sip:+353861953134@192.168.127.239>;q=0.5;+sip.instance="<urn:gsma:imei:35287606-388013-9>";+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg";+g.oma.sip-im

I can see this heppened on my clearwater setup:
from clearwater(sprout) to mas:
Contact: <sip:+353894017258@192.168.127.78:55750;ob>;+g.oma.sip-im;+sip.instance="<urn:gsma:imei:35592104-358960-3>"
from mas to clearwater(sprout) on other leg:
Contact: <sip:+353894017258@192.168.127.78>;+g.oma.sip-im;+sip.instance="<urn:gsma:imei:35592104-358960-3>"


Interesting side-note I see this in a clearwater register response.
Handsets handle these responses fine I think.
1. sip in Contact: without <>s at all at all at all
2. interesting to see that : is htmlerized (%3A) in some strings 
REGISTER: 
Contact: <sip:+353894017258@192.168.127.78:55750;ob>;q=0.5;+sip.instance="<urn:gsma:imei:35592104-358960-3>";+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg";+g.oma.sip-im
REGISTER 200 ok:  (expires=300 is added and <>s are gone)
Contact: sip:+353894017258@192.168.127.78:41876;ob;q=0.5;expires=300;+sip.instance="<urn:gsma:imei:35592104-358960-3>";+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg";+g.oma.sip-im


code to change:

            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

                contact = strtok(tokStr, ":>");
                SBUG_SOME("1st token [%s]", contact);
                if ((contact = strtok(NULL, ":>")) != NULL)
                {
                    SBUG_SOME("Contact [%s]", contact);
                    printf("Result:\nContact: <sip:%s>", contact);
                    //mcs_smi->contact_uri = STRDUP(contact);
                }
            }

            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

                contact = strtok(tokStr, ";>");
                SBUG_SOME("1st token [%s]", contact);
                if ((contact = strtok(NULL, ":>")) != NULL)
                {
                    SBUG_SOME("Contact [%s]", contact);
                    printf("Result:\nContact: <sip:%s>", contact);
                    //mcs_smi->contact_uri = STRDUP(contact);
                }
            }




Contact: <sip:+353894017258@192.168.127.78:55750;ob>;q=0.5;+sip.instance="<urn:gsma:imei:35592104-358960-3>";+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3g
pp-application.ims.iari.gsma-is";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg";+g.oma.sip-im
Expires: 600000
Allow: PRACK, INFO, INVITE, ACK, BYE, CANCEL, UPDATE, SUBSCRIBE, NOTIFY, REFER, MESSAGE, OPTIONS
Supported: gruu
Authorization: Digest username="+353894017258@openims.test", realm="openims.test", nonce="7549197f398abaa6", uri="sip:openims.test", response="7cb3cc52a3f1b3a39
abd4f5fa16a16c5", algorithm=MD5, opaque="1f1ea06f7e4a0fbd"
Route: <sip:10.124.51.133:5054;transport=TCP;lr;orig>
Content-Length:  0


--end msg--
03-03-2014 18:03:36.028 Error httpconnection.cpp:390: http://localhost:7253/timers failed at server 127.0.0.1 : HTTP response code said error (22 405) : fatal
03-03-2014 18:03:36.029 Error httpconnection.cpp:429: cURL failure with cURL error code 22 (see man 3 libcurl-errors) and HTTP error code 405
03-03-2014 18:03:36.029 Verbose stack.cpp:237: TX 1009 bytes Response msg 200/REGISTER/cseq=61712 (tdta0x7fcd0c39e6b0) to TCP 10.124.51.133:44716:
--start msg--

SIP/2.0 200 OK
Service-Route: <sip:10.124.51.133:5054;transport=TCP;lr;orig>
Via: SIP/2.0/TCP 10.124.51.133:44716;rport=44716;received=10.124.51.133;branch=z9hG4bKPjX2g5v7r-p45vl7rUMHV6w5Di6pwYt7rV
Via: SIP/2.0/UDP 192.168.127.78:55750;rport=55750;received=89.101.214.194;branch=z9hG4bKPjYGUiSsSlFIOsVi38eqRkL74iPAH3fqft
Call-ID: QEDja3BlVsbqlQuha2qzlJrPSRBgyJke
From: <sip:+353894017258@openims.test>;tag=xQmMC-Bn51FoY6-SXwMg0AF57B4jMB3i
To: <sip:+353894017258@openims.test>;tag=z9hG4bKPjX2g5v7r-p45vl7rUMHV6w5Di6pwYt7rV
CSeq: 61712 REGISTER
Supported: outbound
Contact: sip:+353894017258@192.168.127.78:55750;ob;q=0.5;expires=300;+sip.instance="<urn:gsma:imei:35592104-358960-3>";+g.3gpp.cs-voice;+g.3gpp.iari-ref="urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is";+g.3gpp.icsi-ref="urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg";+g.oma.sip-im









[james@nebraska mas]$ gcc /home/james/c/TC_mas_contact_gruu.c -o /home/james/c/TC_mas_contact_gruu
[james@nebraska mas]$ find ../.. -name "*.h" -exec grep RESTRDUP {} +^C
[james@nebraska mas]$ ^C
[james@nebraska mas]$ /home/james/c/TC_mas_contact_gruu
/home/james/c/TC_mas_contact_gruu.c::24 contact from invite [Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>;+g.oma.sip-im]
/home/james/c/TC_mas_contact_gruu.c::29 1st token [sip]
/home/james/c/TC_mas_contact_gruu.c::32 Contact [+353894017257@omn-ims.test;gr=urn]





from o_invite.c str_create_invite the contact that is set is used and anything after the > is added back:

    // Contact
    c1 = imf_hdr_get(oa_imf, corrib_sip_ihd_contact_num, 0);
    if(mcs_smi->contact_uri){
        SBUG_SOME("Contact URI already [%s]", mcs_smi->contact_uri);

        str = tbx_strcatf(str, "Contact: <sip:%s>", mcs_smi->contact_uri);

        // copy extra bits from original contact.
        c1 = imf_hdr_get(oa_imf, corrib_sip_ihd_contact_num, 0);
        if(((c2 = strchr(c1, '>')) != NULL) ||
                ((c2 = strchr(c1, ';')) != NULL)){
            str = tbx_strcat(str, (*c2 == ';') ? c2 : c2+1);
        }
        str = tbx_strcat(str, "\r\n"); 
    }
    else {
        str = tbx_strcatf(str, "Contact: %s\r\n", c1);
        SBUG_SOME("Contact set to contact from oa_imf [%s]", c1);
    }





// ../../libtbx/libtbx_inc/mem.h:#define RESTRDUP(a, b)     tbx_restrdup(a, b, __FILE__ ":" __LINE_STR__, __LINE__)
//#define STRDUP(a)          tbx_strdup(a, __FILE__ ":" __LINE_STR__, __LINE__)
//#define TMPSTRDUP(a)       tbx_tmpstrdup(a, __FILE__ ":" __LINE_STR__, __LINE__)
//#define RESTRDUP(a, b)     tbx_restrdup(a, b, __FILE__ ":" __LINE_STR__, __LINE__)



char *tbx_strdup(const char *str,
                 char *file,
                 int line)
{
    char *new_str ;
    int len;

    tbx_strdup_count++;

    if(str != tbx_empty_string){
        len = strlen(str) + 1;
        new_str = tbx_malloc(len, file, line);
        memcpy(new_str, str, len);
    }
    else{
        new_str = (char *)tbx_empty_string;
    }
    
    return new_str;
}

#define TBX_TMP_STR_ARR_SIZE 128
static char *tmp_str_arr[TBX_TMP_STR_ARR_SIZE] = {
    NULL,
};

static int tmp_str_arr_idx = 0;

char *tbx_tmpstrdup(const char *str,
                    char *file,
                    int line)
{
    char *new_str, *old_str;

    new_str = tbx_strdup(str, file, line);

    if((old_str = tmp_str_arr[tmp_str_arr_idx]) != NULL){
        tbx_free(old_str, file, line);
    }

    tmp_str_arr[tmp_str_arr_idx++] = new_str;

    if(tmp_str_arr_idx == TBX_TMP_STR_ARR_SIZE){
        tmp_str_arr_idx = 0;
    }
    
    return new_str;
}

char *tbx_restrdup(char *old,
                   const char *str,
                   char *file,
                   int line)
{
    char *new_str;

    new_str = tbx_strdup(str, file, line);

    if(old != NULL){
        tbx_free(old, file, line);
    }
    
    return new_str;
}





perl /slingshot/sbe/v2/31/37/scripts/gcw  -pipe -O2 -g -W -Wall -Wno-unused -Wstrict-prototypes -Wno-unknown-pragmas -Werror -fno-strict-aliasing -fPIC -march=pentium -DSYS_ARCH_LINUX_X86 -DSBE_LINUX_VER=FC9 -DSBE_LINUX_VER_FC9  -fno-zero-initialized-in-bss -Wno-unused-parameter -Wno-array-bounds -Wno-sign-compare  -ggdb -gdwarf-3 -sbug_dir=/slingshot/sbug/v1/36/97 -DMAS_SRC -c -o obj/linux.fc9/chat_session_actions.o chat_session_actions.c

gmake: *** [obj/linux.fc9/chat_session_actions.o] Error 255


===================================================================
RCS file: /homes/bob/cvsroot/ims/mas/chat_session_actions.c,v
retrieving revision 1.91
diff -u -r1.91 chat_session_actions.c
--- chat_session_actions.c	27 May 2014 11:34:29 -0000	1.91
+++ chat_session_actions.c	6 Jun 2014 11:40:55 -0000
@@ -663,6 +663,8 @@
     static char *tokBuf = NULL;
     char *tokStr = NULL;
     char *contact = NULL;
+    char *contactb4semi = NULL;
+    char *seminext = NULL;
 
     if (mcs_smi->is_group_chat_leg){
         SBUG_SOME("Group chat leg");
@@ -724,19 +726,45 @@
         SBUG_SOME("oa_user_tel_uri [%s]", mcs_smi->oa_user_tel_uri);
 
         // Only need number@host from this contact
+        // convert sip:number@host<:port><;params> to sip:number@host<;params>
         tmpPtr = NULL;
         tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
+
         if (strlen(tmpPtr) > 0) {
+	    SBUG_SOME("contact from invite [%s]", tmpPtr);
             tokBuf = RESTRDUP(tokBuf, tmpPtr);
+	    // 1. find sip: (may or may not be within <>s) 
             if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {
 
-                contact = strtok(tokStr, ":>");
+		// 2. start after sip:, take contact from string up to next > or end (strtok tokenised sets > char to nul)
+                contact = strtok(tokStr+4, ">");
                 SBUG_SOME("1st token [%s]", contact);
-                if ((contact = strtok(NULL, ":>")) != NULL)
-                {
-                    SBUG_SOME("Contact [%s]", contact);
-                    mcs_smi->contact_uri = STRDUP(contact);
-                }
+		// 3. now take that contact and check are there parameters (find semi-colon)
+		seminext = strchr(contact, ';');
+		// check was there a semi-colon, split string and prepare seminext pointer to be added back if so
+                // set semicolon to end-of-string and INCREMENT ptr to just after semicolon
+		if (seminext != NULL) { *seminext=0; seminext++; }  
+		// 4. tokenize contact on colon (if present), this removes :<port> part
+		contactb4semi = strtok(contact, ":");
+		SBUG_SOME("b4 semi [%s], seminext [%s]", contactb4semi, seminext==NULL?"NULL":seminext);
+		
+		// 5. put contact back together without the port, if there was one (or more) semi-colon that bit needs to be added back
+		if (seminext != NULL) {
+		    char *newcontact = NULL;
+		    newcontact = RESTRDUP(newcontact,contactb4semi);
+                    //newcontact = tbx_strcat_multi(newcontact, contact, ";", seminext);
+		    //tbx_strcatf_2(newcontact,"%s;%s",contactb4semi,seminext);		    
+		    tbx_strcatf(newcontact,";%s",seminext);		    
+		    SBUG_SOME("STRCAT newcontact [%s] = contact [%s] + ';' + seminext [%s]", newcontact, contactb4semi, seminext);
+		    // do we need to free the contact? what happened up there with 2 RESTRDUPs
+		    contact = newcontact;
+		    // careful now, the contact and seminext strings are pointers into tokBuf area
+		    // contact = RESTRDUP(contact,newcontact); ??? 
+		}
+
+		SBUG_SOME("Contact [%s]", contact);
+		mcs_smi->contact_uri = STRDUP(contact);
+
             }
             else {
                 // Is this default correct ?
cvs server: Diffing mas_inc
[james@nebraska mas]$ ls -alstr
total 2332
  4 -rw-r--r--  1 james users    259 Jan  4  2013 Release.list
  4 -rw-r--r--  1 james users    327 Jan  4  2013 Deliverables
  4 -rw-r--r--  1 james users    675 Jan 25  2013 chat_session.c
  4 -rw-r--r--  1 james users   1446 Feb 14  2013 o_trying.c
  4 -rw-r--r--  1 james users    690 Feb 19  2013 group_chat_session.c
  8 -rw-r--r--  1 james users   7568 May 29  2013 group_chat_hash.c
  4 -rw-r--r--  1 james users   2467 Sep 10  2013 mirror.c
  4 -rw-r--r--  1 james users   2787 Sep 10  2013 mas_prov_make_ccd.py
  8 -rw-r--r--  1 james users   4402 Nov  6  2013 o_refer.c
 12 -rw-r--r--  1 james users   9037 Nov 14  2013 cstat.def
  4 -rw-r--r--  1 james users   3044 Nov 14  2013 Makefile
  4 -rw-r--r--  1 james users    480 Nov 14  2013 Module.versions.template
  4 -rw-r--r--  1 james users   1068 Dec 19 13:27 mas_visa.bvd
 36 -rw-r--r--  1 james users  36332 Dec 20 17:27 mas_imap.c
 20 -rw-r--r--  1 james users  19586 Feb 27 19:23 standfw_session.c
  8 -rw-r--r--  1 james users   5865 Feb 27 19:23 proxy.c
  4 -rw-r--r--  1 james users   3834 Feb 27 19:23 o_subscribe.c
 36 -rw-r--r--  1 james users  36750 Feb 27 19:23 o_notify.c
 12 -rw-r--r--  1 james users  12247 Feb 27 19:23 mas.h
 12 -rw-r--r--  1 james users  12258 Feb 27 19:23 file_transfer.c
  4 -rw-r--r--  1 james users   2403 Feb 27 19:23 error_mapping.c
 16 -rw-r--r--  1 james users  15158 Feb 27 19:23 content.c
 12 -rw-r--r--  1 james users   8588 Feb 27 19:23 chat_storage.c
  4 -rw-r--r--  1 james users   2911 Mar  4 15:49 o_res.c
 16 -rw-r--r--  1 james users  13239 Mar  5 18:19 i_subscribe.c
  8 -rw-r--r--  1 james users   5915 Mar 24 18:50 standfw_session.ghost
 28 -rw-r--r--  1 james users  25530 Mar 24 18:50 standfw_session_actions.c
 20 -rw-r--r--  1 james users  18968 Mar 24 18:50 o_message.c
 16 -rw-r--r--  1 james users  12934 Mar 24 18:50 file_transfer.ghost
  8 -rw-r--r--  1 james users   6068 Mar 24 18:50 file_transfer_events.c
  4 -rw-r--r--  1 james users   3740 Mar 24 18:50 standfw_session_events.c
 24 -rw-r--r--  1 james users  23830 Mar 25 15:04 mas.c
 16 -rw-r--r--  1 james users  12295 Mar 26 11:02 i_message.c
 24 -rw-r--r--  1 james users  21858 Mar 26 11:03 chat_session.ghost
 68 -rw-r--r--  1 james users  66330 Apr  1 17:22 file_transfer_actions.c
 16 -rw-r--r--  1 james users  12534 Apr 30 16:52 chat_session_events.c
 12 -rw-r--r--  1 james users   9438 Apr 30 16:52 group_chat_session_events.c
 20 -rw-r--r--  1 james users  16689 Apr 30 16:52 i_invite.c
 48 -rw-r--r--  1 james users  46782 Apr 30 16:52 mas_msrp.c
  8 -rw-r--r--  1 james users   4694 Jun  5 15:59 TC_mas_contact_gruu.log
120 -rw-r--r--  1 james users 120912 Jun  6 10:31 .#chat_session_actions.c.1.90
 44 -rw-r--r--  1 james users  41448 Jun  6 10:32 CHANGES
  4 -rw-r--r--  1 james users   1028 Jun  6 10:32 Module.versions.release
 16 -rw-r--r--  1 james users  13325 Jun  6 10:32 group_chat_session.ghost
144 -rw-r--r--  1 james users 145383 Jun  6 10:32 group_chat_session_actions.c
  8 -rw-r--r--  1 james users   4111 Jun  6 10:32 i_bye.c
  4 -rw-r--r--  1 james users   2748 Jun  6 10:32 i_ack.c
  8 -rw-r--r--  1 james users   4362 Jun  6 10:32 i_cancel.c
  8 -rw-r--r--  1 james users   4385 Jun  6 10:32 i_notify.c
  4 -rw-r--r--  1 james users   3890 Jun  6 10:32 i_refer.c
  4 -rw-r--r--  1 james users   2640 Jun  6 10:32 interwork.c
 48 -rw-r--r--  1 james users  47090 Jun  6 10:32 o_invite.c
  4 drwxr-xr-x  2 james users   4096 Jun  6 10:32 CVS
  4 drwxr-xr-x  3 james users   4096 Jun  6 10:32 mas_inc
120 -rw-r--r--  1 james users 121058 Jun  6 10:34 chat_session_actions.c
 96 -rw-------  1 james users 487424 Jun  6 10:38 core.15318
 96 -rw-------  1 james users 487424 Jun  6 10:39 core.15396
100 -rw-------  1 james users 487424 Jun  6 10:41 core.16239
  4 drwxr-xr-x 17 james users   4096 Jun  6 11:12 ..
  4 -rw-r--r--  1 james users    992 Jun  6 12:22 Module.versions
100 -rw-------  1 james users 487424 Jun  6 12:23 core.20636
  0 lrwxrwxrwx  1 james users      1 Jun  6 12:35 inc -> .
  0 lrwxrwxrwx  1 james users      1 Jun  6 12:35 python -> .
  0 lrwxrwxrwx  1 james users      1 Jun  6 12:35 java -> .
  0 lrwxrwxrwx  1 james users      1 Jun  6 12:35 misc -> .
  4 drwxr-xr-x  3 james users   4096 Jun  6 12:35 lnk
  4 drwxr-xr-x  2 james users   4096 Jun  6 12:35 _mas_prov_make_ccd_py_gen_tmp_
  4 -rw-r--r--  1 james users    188 Jun  6 12:35 mas_prov.refmap
  4 -rw-r--r--  1 james users    721 Jun  6 12:35 mas_prov.ccdmap
  4 -rw-r--r--  1 james users     86 Jun  6 12:35 mas_prov.ccddepends
  4 -rw-r--r--  1 james users     89 Jun  6 12:35 mas_prov.ccdntl
  4 -rw-r--r--  1 james users     44 Jun  6 12:35 mas_prov_val.exp
  4 -rw-r--r--  1 james users    364 Jun  6 12:35 mas_prov_val.c
  4 -rw-r--r--  1 james users     80 Jun  6 12:35 mas_prov_monitor.exp
  4 -rw-r--r--  1 james users    988 Jun  6 12:35 mas_prov_monitor.c
  4 -rw-r--r--  1 james users     44 Jun  6 12:35 mas_prov_mirror.exp
  4 -rw-r--r--  1 james users    367 Jun  6 12:35 mas_prov_mirror.c
  4 -rw-r--r--  1 james users     81 Jun  6 12:35 mas_prov_metadata.exp
  4 -rw-r--r--  1 james users   1135 Jun  6 12:35 mas_prov_ccd_gen_metadata.c
  4 -rw-r--r--  1 james users     78 Jun  6 12:35 mas_prov_gen_wabbit.inc
  4 -rw-r--r--  1 james users     53 Jun  6 12:35 mas_prov_gen_login_part.inc
  4 -rw-r--r--  1 james users     65 Jun  6 12:35 mas_prov_gen_matrix.exp
  4 -rw-r--r--  1 james users   1461 Jun  6 12:35 mas_prov_gen_matrix.c
  4 -rw-r--r--  1 james users    356 Jun  6 12:35 mas_prov_gen_ccd_wing.xml
  4 -rw-r--r--  1 james users     84 Jun  6 12:35 Release.list.mas_prov.wing-lang-ids.custom
 16 -rw-r--r--  1 james users  15166 Jun  6 12:35 mas_prov_gen_wing_lang.wids
  4 drwxr-xr-x  2 james users   4096 Jun  6 12:35 wing_magic_build_dir
  4 -rw-r--r--  1 james users    156 Jun  6 12:35 mas_prov.py
  4 -rw-r--r--  1 james users     93 Jun  6 12:35 mas_prov_ccd_ntl_dgen.exp
  4 drwxr-xr-x  2 james users   4096 Jun  6 12:35 libmas_prov_ccd_inc
  4 -rw-r--r--  1 james users   1421 Jun  6 12:35 mas_prov_custom_vld8rs.c
  4 -rw-r--r--  1 james users    456 Jun  6 12:35 mas_prov_ccd_codecs.c
  4 -rw-r--r--  1 james users    386 Jun  6 12:35 libmas_prov_ccd.h
  4 -rw-r--r--  1 james users    236 Jun  6 12:35 libmas_prov_ccd.exp
  4 drwxr-xr-x  3 james users   4096 Jun  6 12:35 obj
  4 -rw-r--r--  1 james users     65 Jun  6 12:36 libmas_prov_ccd.libdeps
  4 -rw-r--r--  1 james users   2134 Jun  6 12:36 libmas_visa.h
  8 -rw-r--r--  1 james users   6070 Jun  6 12:36 libmas_visa.c
  4 -rw-r--r--  1 james users    188 Jun  6 12:36 mas_visa.Makefile.bv
 16 -rw-r--r--  1 james users  13809 Jun  6 12:36 libmas_visa.exp
  0 -rw-r--r--  1 james users      0 Jun  6 12:36 libmas_visa.bv_gen
140 -rw-r--r--  1 james users 142026 Jun  6 12:36 mcs_ghost_gen.h
 96 -rw-r--r--  1 james users  95745 Jun  6 12:36 mgcs_ghost_gen.h
 56 -rw-r--r--  1 james users  55397 Jun  6 12:36 standfw_ghost_gen.h
 24 -rw-r--r--  1 james users  21034 Jun  6 12:36 cstat_gen.h
  8 -rw-r--r--  1 james users   6617 Jun  6 12:36 stats.txt_part
 12 -rw-r--r--  1 james users  11648 Jun  6 12:36 stats.snmp
 12 -rw-r--r--  1 james users   9515 Jun  6 12:36 stats.html_part
 96 -rw-r--r--  1 james users  95894 Jun  6 12:36 file_ghost_gen.h
100 -rw-------  1 james users 487424 Jun  6 12:36 core.28367
 96 -rw-------  1 james users 487424 Jun  6 12:39 core.28494
  4 -rw-r--r--  1 james users    505 Jun  6 12:39 make.log
  4 drwxr-xr-x  9 james users   4096 Jun  6 12:40 .
  8 -rw-r--r--  1 james users   4387 Jun  6 12:40 mas_contact_gruu_fix_1.patch
[james@nebraska mas]$ gdb -c core.28494
GNU gdb (GDB) Fedora 7.6.1-46.fc19
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "i686-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
[New LWP 28494]
Missing separate debuginfo for the main executable file
Try: yum --enablerepo='*debug*' install /usr/lib/debug/.build-id/46/51afeb94949e99c363a9859ed4bad467375788
Core was generated by `/slingshot/sbe/v2/31/37/lnk/linux.fc9/sbe_syn_chk chat_session_actions.c'.
Program terminated with signal 11, Segmentation fault.
#0  0x49117b6a in ?? ()
(gdb) bt
#0  0x49117b6a in ?? ()
#1  0xb777231c in ?? ()
#2  0x080490e4 in ?? ()
#3  0x08048c60 in ?? ()
#4  0x48fee963 in ?? ()
(gdb) quit
[james@nebraska mas]$ gdb -c core.28494 /slingshot/sbe/v2/31/37/lnk/linux.fc9/sbe_syn_chk
GNU gdb (GDB) Fedora 7.6.1-46.fc19
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "i686-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /slingshot/sbe/v2/31/37/lnk/linux.fc9/sbe_syn_chk...done.
[New LWP 28494]
Core was generated by `/slingshot/sbe/v2/31/37/lnk/linux.fc9/sbe_syn_chk chat_session_actions.c'.
Program terminated with signal 11, Segmentation fault.
#0  0x49117b6a in __memset_sse2_rep () from /lib/libc.so.6
Missing separate debuginfos, use: debuginfo-install glibc-2.17-20.fc19.i686
(gdb) bt
#0  0x49117b6a in __memset_sse2_rep () from /lib/libc.so.6
#1  0x08048915 in do_restrdup_check (fname=0xbf92606e "chat_session_actions.c", data=0xb776b000 <Address 0xb776b000 out of bounds>, len=121058)
    at sbe_syn_chk.c:119
#2  0x08048c60 in main (argc=<error reading variable: Cannot access memory at address 0x3fffffe9>, argv=0xbf924ab4) at sbe_syn_chk.c:222
(gdb) 








+		// 5. put contact back together without the port, if there was one (or more) semi-colon that bit needs to be added back
+		if (seminext != NULL) {
+		    char *newcontact = NULL;
+		    //newcontact = RESTRDUP(newcontact,contactb4semi);
+                    newcontact = tbx_strcat_multi(newcontact, contact, ";", seminext);
+		    //tbx_strcatf_2(newcontact,"%s;%s",contactb4semi,seminext);		    
+		    //tbx_strcatf(newcontact,";%s",seminext);		    
+		    SBUG_SOME("STRCAT newcontact [%s] = contact [%s] + ';' + seminext [%s]", newcontact, contactb4semi, seminext);
+		    // do we need to free the contact? what happened up there with 2 RESTRDUPs
+		    contact = newcontact;
+		    // careful now, the contact and seminext strings are pointers into tokBuf area
+		    // contact = RESTRDUP(contact,newcontact); ??? 


[james@nebraska mas]$ OMN_GCC_STATIC=1 gmake all __FAKE_RELEASE_AREA  2>&1 |tee make.log
perl /slingshot/sbe/v2/31/37/scripts/gcw  -pipe -O2 -g -W -Wall -Wno-unused -Wstrict-prototypes -Wno-unknown-pragmas -Werror -fno-strict-aliasing -fPIC -march=pentium -DSYS_ARCH_LINUX_X86 -DSBE_LINUX_VER=FC9 -DSBE_LINUX_VER_FC9  -fno-zero-initialized-in-bss -Wno-unused-parameter -Wno-array-bounds -Wno-sign-compare  -ggdb -gdwarf-3 -sbug_dir=/slingshot/sbug/v1/36/97 -DMAS_SRC -c -o obj/linux.fc9/chat_session_actions.o chat_session_actions.c
chat_session_actions.c:754: Zoikes, assignment mismatch for RESTRDUP:"//newcontact" != "newcontact"

gmake: *** [obj/linux.fc9/chat_session_actions.o] Error 255



WORKING: (or, well, at least it is compiling) . . . 

		// 5. put contact back together without the port, if there was one (or more) semi-colon that bit needs to be added back
		if (seminext != NULL) {
		    // careful now, the contact and seminext strings are pointers into tokBuf area
		    static struct tbx_string *newcontact = NULL;
                    newcontact = tbx_strcat_multi(newcontact, contactb4semi, ";", seminext);
		    contact = STRDUP(tbx_strget(newcontact));
		    SBUG_SOME("STRCAT newcontact [%s] = contact [%s] + ';' + seminext [%s]", contact, contactb4semi, seminext);
		}


#endif
