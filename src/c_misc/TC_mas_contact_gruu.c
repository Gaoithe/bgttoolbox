
#include <stdio.h>
#include <stdlib.h>
//#define SBUG_SOME printf
//#define SBUG_SOME(format, ...) { printf("%s:%d ",__FILE__,__LINE__); printf(format, ## __VA_ARGS__); printf("\n"); }
#define SBUG_SOME(format, ...) { printf("%s:%d ",__FILE__ ":" ,__LINE__); printf(format, ## __VA_ARGS__); printf("\n"); }

#include <string.h>
#define STRDUP strdup
#define RESTRDUP(a,b) strdup(b)


char *tbx_strcatf(char *dest, char *format, char *src)
{
    int l = strlen(dest);
    sprintf(dest+l,format,src);
    return dest;
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

void do_contact_test(char *contact_from_invite, char *expected)
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
            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

		printf("DEBUG tokStr:%s\n", tokStr);
		// 2. start after sip:, contact is string up to next > or end(strtok sets > to nul)
                contact = strtok(tokStr+4, ">");
                SBUG_SOME("1st token [%s]", contact);
		// 3. next get string up to semi-colon
		semi = strtok(contact, ";");
		if (semi != NULL) {
		    seminext = strtok(NULL, ";");
		    SBUG_SOME("semi token [%s], seminext [%s]", semi, seminext);
		    // 4. next get string up to colon (if present)
		    contact = strtok(semi, ":");
		    SBUG_SOME("contact [%s], semi token [%s], seminext [%s]", contact, semi, seminext);
		    // 5. copy back in from semi-colon to end(the > or real end)  (might be doing nothing if semi-colon was not present)
		    if (seminext != NULL) {
			//seminext[-1]=';'; // THIS JOINS contact and seminext back together! Not if there has been a :<port> strip
			//strcat(contact,";"); // which way do you prefer >;-)   // duhrrr, I prefer the way that works.
			//strcat(contact,seminext);

			// careful now, the contact and seminext strings are pointers into tokBuf area
			contact = tbx_strcatf(contact,";%s",seminext);

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

// unit test contacts  (original and expected (all after > stripped is expected)
char *contact_tests[] = {
    "Contact: <sip:+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7>;+g.oma.sip-im",
    "+353894017257@omn-ims.test;gr=urn:gsma:imei:35592104-359095-7",
    "Contact: <sip:+353894017257@omn-ims.test>",
    "+353894017257@omn-ims.test",
    "Contact: <sip:10.220.105.213:60860>",
    "10.220.105.213",
    "Contact: <sip:10.220.105.213>",
    "10.220.105.213",
    "Contact: <sip:10.220.105.213:5054>;expires=300",
    "10.220.105.213",
    "Contact: <sip:+353861953134@192.168.127.239:48865;ob>;q=0.5;+sip.instance=\"<urn:gsma:imei:35287606-388013-9>\";+g.3gpp.cs-voice;+g.3gpp.iari-ref=\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is\";+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg\";+g.oma.sip-im",
    "+353861953134@192.168.127.239;ob",
    "Contact: <sip:+353894017258@192.168.127.78:55750;ob>;+g.oma.sip-im;+sip.instance=\"<urn:gsma:imei:35592104-358960-3>\"",
    "+353894017258@192.168.127.78;ob",
    "Contact: sip:+353894017258@192.168.127.78:4444;ob;q=0.5",
    "+353894017258@192.168.127.78;ob;q=0.5",
    "Contact: sip:+353894017258@192.168.127.78:41876;ob;q=0.5;expires=300;+sip.instance=\"<urn:gsma:imei:35592104-358960-3\";+g.3gpp.cs-voice;+g.3gpp.iari-ref=\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is\";+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg\";+g.oma.sip-im",
    "+353894017258@192.168.127.78;ob;q=0.5;expires=300;+sip.instance=\"<urn:gsma:imei:35592104-358960-3\";+g.3gpp.cs-voice;+g.3gpp.iari-ref=\"urn%3Aurn-7%3A3gpp-application.ims.iari.gsma-is\";+g.3gpp.icsi-ref=\"urn%3Aurn-7%3A3gpp-service.ims.icsi.oma.cpm.msg\";+g.oma.sip-im",
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



#endif
