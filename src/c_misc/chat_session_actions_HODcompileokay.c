static char *_ID_ims_mas_chat_session_actions_c = "$Name:  $ $Header: /homes/bob/cvsroot/ims/mas/chat_session_actions.c,v 1.91 2014/05/27 11:34:29 colm Exp $";

// define _GNU_SOURCE 
// as we need to use strcasestr() further down
// otherwise it will not exist
#define _GNU_SOURCE

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <ctype.h>
#include <time.h>

#include "libtbx.h"
#include "libnsl.h"
#include "libntl.h"
#include "libcstat.h"
#include "libatlas.h"
#include "libsbug.h"
#include "libcconf.h"
#include "libclog.h"
#include "libclam.h"
#include "libimdx.h"
#include "libfletch.h"
#include "libcango.h"
#include "libbalti.h"
#include "libcdr.h"
#include "libelm.h"
#include "libimf.h"
#include "libripley.h"
#include "libcorrib_api.h"
#include "libcorrib_sip.h"
#include "libmsrp.h"
#include "libims_config.h"
#include "libconrad.h"
#include "libims_call_id.h"
#include "libims_common.h"
#include "libtron_common.h"
#include "libtron_ims.h"

#include "mas.h"
#include "mcs_ghost_gen.h"
#include "cstat_gen.h"

#define GROUP_CHAT_LEG_TEARDOWN_TIMER_SECS 10
//If TCP socket is torn down, we wait this number of seconds to see if BYE is sent,
//some clients teardown TCP connection first and then send BYE, not good procedure 
//byt does happen.
#define TIME_TO_WAIT_FOR_BYE_SECS 10

static void mcs_subscribe_trnx_release(struct mcs_subscribe_trnx *trnx)
{
    if(trnx->subscribe_crb_req){
        crb_req_release(trnx->subscribe_crb_req);
    }
    if(trnx->subscribe_imf){
        imf_release(trnx->subscribe_imf);
    }

    FREE(trnx);
}
static void mcs_subscribe_state_release(struct mcs_subscribe_state *subscribe_state)
{
    struct mcs_state_machine_instance *smi = subscribe_state->mcs_smi;
    struct mcs_subscribe_trnx *subscribe_trnx;

    if(subscribe_state->trnx_list){
        for(subscribe_trnx = LLNEXT(subscribe_state->trnx_list);
            subscribe_trnx != subscribe_state->trnx_list;
            subscribe_trnx = LLNEXT(subscribe_state->trnx_list)){
            LLREMOVE(subscribe_trnx);
            mcs_subscribe_trnx_release(subscribe_trnx);
        }
    }
    if(subscribe_state->subscribe_imf){
        imf_release(subscribe_state->subscribe_imf);
        subscribe_state->subscribe_imf = NULL;
    }

    if(subscribe_state->subscribe_iw_dlg_assoc){
        if(subscribe_state->subscribe_iw_dlg_assoc->dlg){
            ims_call_id_erase(mas_prep_call_id(subscribe_state->subscribe_iw_dlg_assoc->dlg->call_id,
                                               smi->app_server));
            corrib_sip_dialog_release(subscribe_state->subscribe_iw_dlg_assoc->dlg);
            subscribe_state->subscribe_iw_dlg_assoc->dlg = NULL;
        }
        mas_sm_dlg_assoc_release(subscribe_state->subscribe_iw_dlg_assoc);
        subscribe_state->subscribe_iw_dlg_assoc = NULL;
    }

    if(subscribe_state->subscribe_gw_dlg_assoc){

        if(subscribe_state->subscribe_gw_dlg_assoc->dlg){
            ims_call_id_erase(mas_prep_call_id(subscribe_state->subscribe_gw_dlg_assoc->dlg->call_id,
                                               smi->app_server));
            corrib_sip_dialog_release(subscribe_state->subscribe_gw_dlg_assoc->dlg);
            subscribe_state->subscribe_gw_dlg_assoc->dlg = NULL;
        }
        mas_sm_dlg_assoc_release(subscribe_state->subscribe_gw_dlg_assoc);
        subscribe_state->subscribe_gw_dlg_assoc = NULL;
    }

    FREE(subscribe_state);
}

void mcs_ac_send_ok_to_oa_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct imf *oa_imf;
    struct imf *da_res_imf;
    static struct tbx_string *str = NULL;
    static struct tbx_string *sdp_str = NULL;
    static char *to = NULL;
    const char *c1, *c2;
    struct crb_res *crb_res;
    int i, num, idx;
    int answer_active_setup = 0;
    int answer_passive_setup = 0;
    const char *tmpPtr = NULL;

    if(!mcs_smi->oa_crb_state) {
        SBUG_SOME("Detected oa_crb_state NULL.. OA ACK already sent.. nothing to do here");
        return;
    }

    SBUG_SOME("Sending 200 OK to OA\n");

    oa_imf = mcs_smi->oa_invite_imf;
    da_res_imf = mcs_smi->da_invite_res_imf;

    if (strcmp(mcs_smi->oa_answered_msrp_setup, "active") == 0){
        answer_active_setup = 1;
        answer_passive_setup = 0;
        SBUG_SOME("MAS will answer with active setup");
    }
    else{
        answer_active_setup = 0;
        answer_passive_setup = 1;
        SBUG_SOME("MAS will answer with passive setup");
    }

    if(mcs_smi->da_answered_msd){
        sdp_str = msrp_sdp_create_str(sdp_str, 
                                      gv_msrp_settings->public_msrp_host,
                                      mas_msrp_get_svr_port(),
                                      mcs_smi->oa_local_msrp_uri,
                                      (mcs_smi->da_answered_msd->file_transfer_id[0] != '\0') ? 0 : 1,  //SEND
                                      1, //Recv
                                      answer_active_setup, //Active
                                      answer_passive_setup, //Passive
                                      mas_check_str(mcs_smi->da_answered_msd->accept_types),
                                      mas_check_str(mcs_smi->da_answered_msd->accept_wrapped_types),
                                      mas_check_str(mcs_smi->da_answered_msd->file_transfer_id),
                                      mas_check_str(mcs_smi->da_answered_msd->file_disposition),
                                      mas_check_str(mcs_smi->da_answered_msd->max_size),
                                      mas_check_str(mcs_smi->da_answered_msd->file_selector));
    }
    else {
        sdp_str = msrp_sdp_create_str(sdp_str, 
                                      gv_msrp_settings->public_msrp_host,
                                      mas_msrp_get_svr_port(),
                                      mcs_smi->oa_local_msrp_uri,
                                      0,  //SEND
                                      1, //Recv
                                      answer_active_setup, //Active
                                      answer_passive_setup, //Passive
                                      mas_check_str(mcs_smi->oa_offered_msd->accept_types),
                                      mas_check_str(mcs_smi->oa_offered_msd->accept_wrapped_types),
                                      mas_check_str(mcs_smi->oa_offered_msd->file_transfer_id),
                                      mas_check_str(mcs_smi->oa_offered_msd->file_disposition),
                                      mas_check_str(mcs_smi->oa_offered_msd->max_size),
                                      mas_check_str(mcs_smi->oa_offered_msd->file_selector));
    }

    str = tbx_strcpy(str, "");
    str = tbx_strcatf(str,"SIP/2.0 200 OK\r\n");

    /*via*/
    num = imf_hdr_count(oa_imf,corrib_sip_ihd_via_num);
    for(i=0;i<num;i++){
        c1 = imf_hdr_get(oa_imf,corrib_sip_ihd_via_num,i);
        str = tbx_strcatf(str,"Via: %s\r\n",c1);
    }

    /*From*/
    c1 = imf_hdr_get(oa_imf,corrib_sip_ihd_from_num,0);
    str = tbx_strcatf(str,"From: %s\r\n",c1);


    /*To*/
    c1 = imf_hdr_get(oa_imf,corrib_sip_ihd_to_num,0);
    if((c2 = strstr(c1,";tag=")) != NULL){
        to = RESUBSTRDUP(to,c1,c2);
    }
    else{
        to = RESTRDUP(to,c1);
    }
    str = tbx_strcatf(str,"To: %s;tag=%s\r\n", to, mcs_smi->iw_dlg_assoc->dlg->local_dialog_id);

    /*Call-ID*/
    c1 = imf_hdr_get(oa_imf,corrib_sip_ihd_call_id_num,0);
    str = tbx_strcatf(str, "Call-ID: %s\r\n",c1);

    // Contact
    c1 = imf_hdr_get((da_res_imf) ? da_res_imf : oa_imf, 
                     corrib_sip_ihd_contact_num, 0);
    SBUG_SOME("Contact c1 [%s]", c1);

    if(mcs_smi->contact_uri){
        SBUG_SOME("Contact uri present");
        str = tbx_strcatf(str, "Contact: <sip:%s:5060>", mcs_smi->contact_uri);
        // copy extra bits from original contact.
        if(((c2 = strchr(c1, '>')) != NULL) ||
            ((c2 = strchr(c1, ';')) != NULL)){
            str = tbx_strcat(str, 
                             (*c2 == ';') ? c2 : c2+1);
        }
        str = tbx_strcat(str, "\r\n"); 
    }
    else {
        str = tbx_strcatf(str, "Contact: %s\r\n", c1);
        SBUG_SOME("No contact uri in orig, set to [%s]", c1);
    }

    if(mcs_smi->record_route){
        str = tbx_strcatf(str, "Record-Route: <sip:%s:5060>\r\n", mcs_smi->record_route);
        SBUG_SOME("Record-Route set to '<sip:%s:5060>'", mcs_smi->record_route);
    }

    // Proxy the Supported header
    idx = imf_hdr_resolve((da_res_imf) ? da_res_imf : oa_imf, "Supported");
    if(idx != -1){
        c1 = imf_hdr_get((da_res_imf) ? da_res_imf : oa_imf, idx, 0);
        if(c1 && strlen(c1)){
            str = tbx_strcatf(str, "Supported: %s\r\n", c1);
        }
    }

    // Proxy the Allow Header
    idx = imf_hdr_resolve((da_res_imf) ? da_res_imf : oa_imf, "Allow");
    if(idx != -1){
        c1 = imf_hdr_get((da_res_imf) ? da_res_imf : oa_imf, idx, 0);
        if(c1 && strlen(c1)){
            str = tbx_strcatf(str, "Allow: %s\r\n", c1);
        }
    }

    // CSeq
    c1 = imf_hdr_get(oa_imf, corrib_sip_ihd_cseq_num,0);
    str = tbx_strcatf(str,"CSeq: %s\r\n",c1);

    // Record Route
    num = imf_hdr_count(oa_imf, corrib_sip_ihd_rec_route_num);
    for(i=0; i < num; i++){
        c1 = imf_hdr_get(oa_imf, corrib_sip_ihd_rec_route_num, i);
        str = tbx_strcatf(str, "Record-Route: %s\r\n", c1);
    }

    str = tbx_strcatf(str,
                      "Content-Type: application/sdp\r\n");

    str = tbx_strcatf(str,
                      "Content-Length: %d\r\n", tbx_strlen(sdp_str));

    str = tbx_strcatf(str, "\r\n");
    str = tbx_strcat(str, tbx_strget(sdp_str));

    crb_res = corrib_sip_create_crb_res(mcs_smi->oa_invite_crb_req,
                                        tbx_strget(str),
                                        tbx_strlen(str));

    mcs_smi->oa_invite_res_imf = imf_dupe(&crb_res->res_info.imf);

    if(mcs_smi->oa_crb_state){
        crb_consumer_consumed_ok(mcs_smi->oa_crb_state, crb_res);
        mcs_smi->oa_crb_state = NULL;
    }
    else {
        imdx_ims_handoff_bus_consumer_consumed_ok(mcs_smi->oa_handoff_req_state, crb_res);
        mcs_smi->oa_handoff_req_state = NULL;
    }
    crb_res_release(crb_res);    
}

void mcs_ac_check_msrp_server_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mas_msrp_server_get() == NULL) {
        mcs_ev_msrp_server_unavailable(mcs_smi->id);
    }
    else {
        mcs_ev_msrp_server_available(mcs_smi->id);
    }
}

void mcs_ac_check_session_type_fn(struct mcs_state_machine_instance *mcs_smi)
{

    if (mcs_smi->is_large_msg){
        mcs_ev_is_large_message(mcs_smi->id);
    }
    else{
        mcs_ev_is_chat(mcs_smi->id);
    } 

}

void mcs_ac_create_msrp_sessions_fn(struct mcs_state_machine_instance *mcs_smi)
{
    char *host;
    int port;
    int connect_to_oa = 0;
    int connect_to_da = 0;

    if (strcmp(mcs_smi->oa_offered_msd->setup, "actpass") == 0 ||
        strcmp(mcs_smi->oa_offered_msd->setup, "active") == 0){
        connect_to_oa = 0;
        mcs_smi->oa_answered_msrp_setup = RESTRDUP(mcs_smi->oa_answered_msrp_setup, "passive");
        SBUG_SOME("MAS will Listen for OAs connect with passive setup");
    }
    else{
        mcs_smi->oa_answered_msrp_setup = RESTRDUP(mcs_smi->oa_answered_msrp_setup, "active");
        connect_to_oa = 1;
        SBUG_SOME("MAS will connect to OA");
    }

    if (!mcs_smi->da_offline) {
        if (strcmp(mcs_smi->da_answered_msd->setup, "active") == 0){
            SBUG_SOME("MAS will listen for DAs connect with passive setup");
            connect_to_da = 0;
        }
        else{
            SBUG_SOME("MAS will connect to DA");
            connect_to_da = 1;
        }
    }
   
    // check oa session before creation.. we avoid doing it 
    // again on a re-invite of the DA
    if (!mcs_smi->oa_msrp_session) {
        // Determine whether to the host or port in the c= and m=
        // SDP lines should be used to connect instead of the
        // host + port in the path
        host = NULL;
        port = 0;
        if(connect_to_oa &&
           strstr(mcs_smi->oa_offered_msd->host, mcs_smi->oa_offered_msd->path)){
            host = mcs_smi->oa_offered_msd->host;
            port = mcs_smi->oa_offered_msd->port;
        }
        mcs_smi->oa_msrp_session = mas_msrp_session_create(mcs_smi->oa_local_msrp_uri,
                                                           host,
                                                           port,
                                                           mcs_smi->oa_offered_msd->path,
                                                           connect_to_oa,
                                                           1,
                                                           mcs_smi);
    }

    if (!mcs_smi->da_offline) {
        // Determine whether to the host or port in the c= and m=
        // SDP lines should be used to connect instead of the
        // host + port in the path
        host = NULL;
        port = 0;
        if(connect_to_da &&
           strstr(mcs_smi->da_answered_msd->host, mcs_smi->da_answered_msd->path)){
            host = mcs_smi->da_answered_msd->host;
            port = mcs_smi->da_answered_msd->port;
        }
        mcs_smi->da_msrp_session = mas_msrp_session_create(mcs_smi->da_local_msrp_uri,
                                                           host,
                                                           port,
                                                           mcs_smi->da_answered_msd->path,
                                                           connect_to_da,
                                                           0,
                                                           mcs_smi);
    }

}

void mcs_ac_create_da_msrp_session_fn(struct mcs_state_machine_instance *mcs_smi)
{
    char *host;
    int port;
    int connect_to_da = 0;

    if (strcmp(mcs_smi->da_answered_msd->setup, "active") == 0){
        SBUG_SOME("MAS will listen for DAs connect with passive setup");
        connect_to_da = 0;
    }
    else{
        SBUG_SOME("MAS will connect to DA");
        connect_to_da = 1;
    }

    // Determine whether to the host or port in the c= and m=
    // SDP lines should be used to connect instead of the
    // host + port in the path
    host = NULL;
    port = 0;
    if(connect_to_da &&
       strstr(mcs_smi->da_answered_msd->host, mcs_smi->da_answered_msd->path)){
        host = mcs_smi->da_answered_msd->host;
        port = mcs_smi->da_answered_msd->port;
    }
    mcs_smi->da_msrp_session = mas_msrp_session_create(mcs_smi->da_local_msrp_uri,
                                                       host,
                                                       port,
                                                       mcs_smi->da_answered_msd->path,
                                                       connect_to_da,
                                                       0,
                                                       mcs_smi);
    mcs_smi->da_offline = 0;
    mcs_smi->reinviting = 0;
}

void mcs_ac_destroy_da_msrp_session_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->da_msrp_session) {
        // may not be set if the DA is offline
        SBUG_SOME("Destroy da msrp session");
        mas_msrp_session_destroy(mcs_smi->da_msrp_session);
        mcs_smi->da_msrp_session = NULL;
    }
}

void mcs_ac_destroy_msrp_sessions_fn(struct mcs_state_machine_instance *mcs_smi)
{
    SBUG_SOME("Destroying MSRP Sessions");
    mas_msrp_session_destroy(mcs_smi->oa_msrp_session);
    mcs_smi->oa_msrp_session = NULL;

    if (mcs_smi->da_msrp_session) {
        // may not be set if the DA is offline
        SBUG_SOME("Destroy da msrp session");
        mas_msrp_session_destroy(mcs_smi->da_msrp_session);
        mcs_smi->da_msrp_session = NULL;
    }
}

void mcs_ac_extract_oa_content_fn(struct mcs_state_machine_instance *mcs_smi)
{
    const char *c1;
    char *c2, *c3;
    static char *group_as_prefix;
    char *err_str;
    struct ims_multipart *multi = NULL;
    struct ims_part *part = NULL;
    struct imf *imf;

    SBUG_SOME("Extracting Content\n");


    imf = mcs_smi->oa_invite_imf;

    c1 = imf_hdr_get(imf, corrib_sip_ihd_contribution_id, 0);
    if (*c1){
        SBUG_SOME("ContributionId = %s\n", c1 ? c1 : "EMPTY");
        mcs_smi->oa_contribution_id = RESTRDUP(mcs_smi->oa_contribution_id, c1);
    }

    c1 = imf_hdr_get(imf, corrib_sip_ihd_conversation_id, 0);
    if (*c1){
        SBUG_SOME("ConversationId = %s\n", c1 ? c1 : "EMPTY");
        mcs_smi->oa_conversation_id = RESTRDUP(mcs_smi->oa_conversation_id, c1);
    }

    // routing ID & chat ID
    // Routing ID is based on creation time and conversation ID or 
    // falling back to contribution ID
    // Chat ID is just the chosen the conversation or contribution ID
    // Its not timestamped like the the routing ID
    if (mcs_smi->oa_conversation_id) {
        c1 = mcs_smi->oa_conversation_id;
    }
    else if (mcs_smi->oa_contribution_id) {
        c1 = mcs_smi->oa_contribution_id;
    }
    else {
        c1 = "<no conv/contribution ID>";
    }

    mcs_smi->routing_id = RESTRDUP(mcs_smi->routing_id, 
                                   tbx_qsprintf("%d:%p:%s",
                                                mcs_smi->creation_time,
                                                mcs_smi,
                                                c1));
    SBUG_SOME("Routing ID = %s", mcs_smi->routing_id);
   
    c1 = imf_hdr_get(imf, corrib_sip_ihd_subject, 0);
    if (*c1){
        SBUG_SOME("Subject = %s\n", c1);
        mcs_smi->subject = RESTRDUP(mcs_smi->subject, c1);
    }

    c1 = imf_hdr_get(imf, corrib_sip_ihd_referred_by_num, 0);
    if (*c1){
        c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf,
                                            corrib_sip_ihd_referred_by_num,
                                            0,
                                            &err_str,
                                            EXTRACT_SIP_ADDR);

        if (c1 == NULL){
            SBUG_SOME("No SIP address found in Referred, Looking for TEL addr");
            c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf,
                                                corrib_sip_ihd_referred_by_num,
                                                0,
                                                &err_str,
                                                EXTRACT_TEL_ADDR);

            if (c1 == NULL){
                SBUG_SOME("Referred Field Header in imf but could not extract, sip or tel addr");
            }
            else{
                SBUG_SOME("Referred-By = tel:%s\n", c1);
                mcs_smi->oa_referred_by = RESTRDUP(mcs_smi->oa_referred_by,
                                                   tbx_qsprintf("tel:%s", c1));
            }
        }
        else{
            SBUG_SOME("Referred-By = sip:%s\n", c1);
            mcs_smi->oa_referred_by = RESTRDUP(mcs_smi->oa_referred_by,
                                               tbx_qsprintf("sip:%s", c1));
        }
    }


    c1 = imf_hdr_get(imf, corrib_sip_ihd_content_type, 0);
    
    SBUG_SOME("Content Type %s\n", c1 ? c1 : "EMPTY");
    if(strncasecmp("application/sdp", c1, 15) == 0){
        SBUG_SOME("Only SDP\n");
        mcs_smi->oa_sdp = RESTRDUP(mcs_smi->oa_sdp, (char*)imf->body_sec);
        return;
    }
    else if(strncasecmp("multipart/mixed", c1, 15) == 0){
        SBUG_SOME("Have multipart/mixed content\n");
       
        multi = ims_multipart_split(imf);
        
        for(part = LLNEXT(multi->part_list); 
            part != multi->part_list; 
            part = LLNEXT(part)){

            c1 = imf_hdr_get(part->imf, corrib_sip_ihd_content_type, 0);
            if(strlen(c1) == 0){
                // this is text plain
                SBUG_SOME("No Content Type... Assume text plain");
                imf_hdr_add(part->imf, "Content-type", "text/plain");
                if(mcs_smi->first_msg == NULL){
                    SBUG_SOME("Found First Message in Multipart");
                    mcs_smi->first_msg = imf_dupe(part->imf);
                }
            }
            else if(strncasecmp("application/sdp", c1, 15) == 0){
                SBUG_SOME("Found SDP in Multipart\n");
                mcs_smi->oa_sdp = RESTRDUP(mcs_smi->oa_sdp, (char*)part->imf->body_sec);
            }
            else if(strncasecmp("application/resource-lists+xml", c1, 30) == 0){
                SBUG_SOME("Found Invitee resource list in Multipart\n");
                mcs_smi->invite_resource_list = RESTRDUP(mcs_smi->invite_resource_list, 
                                                         (char*)part->imf->body_sec);
            }
            else if(mcs_smi->first_msg == NULL && 
                    (strncasecmp("text/plain", c1, 10) == 0 ||
                    strncasecmp("message/cpim", c1, 12) == 0)){
                SBUG_SOME("Found First Message in Multipart");
                mcs_smi->first_msg = imf_dupe(part->imf);
            }
        }

        ims_multipart_release(multi);
    }
    else {
        mcs_ev_no_content(mcs_smi->id);
        return;
    }

    // get device gruu or sip.instance
    if((c1 = mas_extract_device_info(imf)) != NULL){
        mcs_smi->oa_device = RESTRDUP(mcs_smi->oa_device, c1);
    }
}

void mcs_ac_set_group_chat_uri_fn(struct mcs_state_machine_instance *mcs_smi)
{
    static struct tbx_string *contact_uri;
    char *p;
    char *c1, *c2;
    char *group_chat_leg_uri = NULL;
    char *group_chat_uri = NULL;
    char *err_str = NULL;

    if (mcs_smi->is_group_chat_leg){
        if (mcs_smi->is_reinvite){
            mcs_smi->group_chat_uri = STRDUP(get_group_chat_uri_from_group_chat_leg_uri_id(mcs_smi->contact_uri));
            
            //Remove old instance of mapping to old chat state machine
            remove_group_chat_leg_uri_id(mcs_smi->contact_uri);
            
            //Add new mapping to this state machine and group chat uri
            record_group_chat_leg_uri_id(mcs_smi->contact_uri, 
                                         mcs_smi->id, 
                                         mcs_smi->group_chat_uri);

        }
        else{
            if(mcs_smi->group_chat_uri){
                SBUG_SOME("Already set\n");
                return;
            }
            //Extract Request-URI / TO-URI from contact field of original invite (or invite response)
            if (mcs_smi->is_mo){
                group_chat_uri = corrib_sip_extract_addr_header(mcs_smi->da_invite_res_imf, 
                                                                corrib_sip_ihd_contact_num, 
                                                                0, 
                                                                &err_str, 
                                                                EXTRACT_SIP_ADDR);
                SBUG_SOME("MO LEG, extracted contact address (%s) from response from Group Chat Server", group_chat_uri);
            }
            else{
                group_chat_uri = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf, 
                                                                corrib_sip_ihd_contact_num, 
                                                                0,
                                                                &err_str,
                                                                EXTRACT_SIP_ADDR);
                SBUG_SOME("MT LEG, extracting contact address (%s) from INVITE from Group Chat Server", group_chat_uri);
            }

            if (group_chat_uri == NULL){
                printf("No Contact Address found, aborting");
                tbx_abort();
            }
            mcs_smi->group_chat_uri = STRDUP(group_chat_uri);

            // record the instance ID against the contact URI
            // This will be used for incoming SUBSCRIBEs, REFERs and 
            // any other shit that comes out of thin air purporting to 
            // belong to this existing chat.. we'll get the contact
            // field from those requests and retrieve the chat based
            // on the key
            record_group_chat_leg_uri_id(mcs_smi->contact_uri, mcs_smi->id, mcs_smi->group_chat_uri);

            SBUG_SOME("Group Chat Leg Contact URI = %s", mcs_smi->contact_uri);
        }
    }
    else{
        //Nothing to do here
    }
}

void mcs_ac_set_contact_uri_fn(struct mcs_state_machine_instance *mcs_smi)
{
    static struct tbx_string *contact_uri;
    char *p;
    char *c1, *c2;
    char *chat_uri = NULL;
    char *err_str;
    const char *tmpPtr = NULL;
    static char *tokBuf = NULL;
    char *tokStr = NULL;
    char *contact = NULL;
    char *contactb4semi = NULL;
    char *seminext = NULL;

    if (mcs_smi->is_group_chat_leg){
        SBUG_SOME("Group chat leg");
        if (mcs_smi->is_reinvite){
            // Determine Destination conference
            c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf, 
                                                corrib_sip_ihd_omn_sip_req_num, 
                                                0, 
                                                &err_str, 
                                                EXTRACT_SIP_ADDR);

            //Strip port number if present
            c2 = strstr(c1, ":");
            if (c2 == NULL){
                chat_uri = RESTRDUP(chat_uri, c1);
            }
            else{
                chat_uri = RESUBSTRDUP(chat_uri, c1, c2);
            }

            mcs_smi->contact_uri = STRDUP(chat_uri);
            
            SBUG_SOME("Reusing Original Group Chat Leg Contact URI = %s", mcs_smi->contact_uri);
        }
        else{
            // locate the @ in the provisioned app server URI
            p = strstr(mcs_smi->app_server->as_uri, "@");
    
            // Take the part before the '@' and suffix in 
            // unique suffix.
            // Then append final @..... section (p pointer)
            contact_uri = tbx_strcpy(contact_uri, "");
            contact_uri = tbx_strncat(contact_uri, 
                                      mcs_smi->app_server->as_uri, 
                                      p - mcs_smi->app_server->as_uri);

            contact_uri = tbx_strcatf(contact_uri,
                                      "-%s-%u-%u",
                                      tbx_procname(),
                                      tbx_time(),
                                      tbx_militime());
            // finally add the @.... trailling setion of the AS URI
            contact_uri = tbx_strcat(contact_uri, p);

            mcs_smi->contact_uri = STRDUP(tbx_strget(contact_uri));
            SBUG_SOME("Group Chat Leg Contact URI = %s", mcs_smi->contact_uri);
        }
    }
    else{

        // leave Contact as is for 1-1. Add this to the Record-Route header
        //mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
        mcs_smi->record_route = STRDUP(mcs_smi->app_server->as_uri);
        SBUG_SOME("New record-route set to app svr uri [%s]", mcs_smi->record_route);

        SBUG_SOME("as_uri [%s]", mcs_smi->app_server->as_uri);
        SBUG_SOME("oa_user_sip_uri [%s]", mcs_smi->oa_user_sip_uri);
        SBUG_SOME("oa_device [%s]", mcs_smi->oa_device);
        SBUG_SOME("oa_user_tel_uri [%s]", mcs_smi->oa_user_tel_uri);

        // Only need number@host from this contact
        // convert sip:number@host<:port><;params> to sip:number@host<;params>
        tmpPtr = NULL;
        tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);

        if (strlen(tmpPtr) > 0) {
	    SBUG_SOME("contact from invite [%s]", tmpPtr);
            tokBuf = RESTRDUP(tokBuf, tmpPtr);
	    // 1. find sip: (may or may not be within <>s) 
            if ((tokStr = strstr(tokBuf, "sip:")) != NULL) {

		// 2. start after sip:, take contact from string up to next > or end (strtok tokenised sets > char to nul)
                contact = strtok(tokStr+4, ">");
                SBUG_SOME("1st token [%s]", contact);
		// 3. now take that contact and check are there parameters (find semi-colon)
		seminext = strchr(contact, ';');
		// check was there a semi-colon, split string and prepare seminext pointer to be added back if so
                // set semicolon to end-of-string and INCREMENT ptr to just after semicolon
		if (seminext != NULL) { *seminext=0; seminext++; }  
		// 4. tokenize contact on colon (if present), this removes :<port> part
		contactb4semi = strtok(contact, ":");
		SBUG_SOME("b4 semi [%s], seminext [%s]", contactb4semi, seminext==NULL?"NULL":seminext);
		
		// 5. put contact back together without the port, if there was one (or more) semi-colon that bit needs to be added back
		if (seminext != NULL) {
		    // careful now, the contact and seminext strings are pointers into tokBuf area
		    static struct tbx_string *newcontact = NULL;
                    newcontact = tbx_strcat_multi(newcontact, contactb4semi, ";", seminext);
		    contact = STRDUP(tbx_strget(newcontact));
		    SBUG_SOME("STRCAT newcontact [%s] = contact [%s] + ';' + seminext [%s]", contact, contactb4semi, seminext);
		}

		SBUG_SOME("Contact [%s]", contact);
		mcs_smi->contact_uri = STRDUP(contact);

            }
            else {
                // Is this default correct ?
                mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
                SBUG_SOME("No sip: in contact, using as_uri");
            }
        }
        else {
            mcs_smi->contact_uri = STRDUP(mcs_smi->app_server->as_uri);
            SBUG_SOME("No contact header, using as_uri");
        }
        SBUG_SOME("1-1 Chat Contact [%s] [%d]", mcs_smi->contact_uri,
            strlen(mcs_smi->contact_uri) );
    }
}

static void proxy_subscribe_cb(struct corrib_sip_dialog *dlg,
                              void *cbarg,
                              int code,
                              struct imf *res_imf,
                              struct qsr_forward_error *qfe)
{
    static struct tbx_string *contact_header;
    static const char *c1, *c2;
    struct imf *imf;
    struct mcs_subscribe_trnx *trnx = cbarg;
    struct mcs_state_machine_instance *mcs_smi = trnx->state->mcs_smi;

    SBUG_SOME("SUBSCRIBE returned %d\n", code);

    //Need to find correct imf in case there is any sip-instance or other params that 
    //need to be propogated back in SUBSCRIBE OK
    if (mcs_smi->is_mo == 1 || (mcs_smi->is_mo == 0 && mcs_smi->is_reinvite == 1)){
        imf = mcs_smi->da_invite_res_imf;
    }
    else{
        imf = mcs_smi->oa_invite_imf;
    }

    contact_header = tbx_strcpy(contact_header, "");
    contact_header = tbx_strcatf(contact_header, "<sip:%s:5060>", mcs_smi->contact_uri);
    // copy extra bits from response.
    c1 = imf_hdr_get(imf, corrib_sip_ihd_contact_num, 0);
    if(((c2 = strchr(c1, '>')) != NULL) ||
        ((c2 = strchr(c1, ';')) != NULL)){
        contact_header = tbx_strcat(contact_header, (*c2 == ';') ? c2 : c2+1);
    }

    //Respond to IW SUBSCRIBE with 200 OK 
    mas_send_response(trnx->subscribe_req_state, 
                      trnx->subscribe_handoff_req_state, 
                      trnx->subscribe_crb_req, 
                      trnx->state->subscribe_iw_dlg_assoc->dlg, 
                      (char *)tbx_strget(contact_header), 
                      NULL, 
                      NULL, 
                      NULL, 
                      200);

    mcs_subscribe_trnx_release(trnx);
    mcs_smi_decref(mcs_smi);
}

void mcs_ac_proxy_subscribe_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct mcs_subscribe_state *subscribe_state;
    struct mcs_subscribe_trnx *trnx;
    struct corrib_sip_dialog *dlg;

    for(subscribe_state = LLNEXT(mcs_smi->subscribe_list);
        subscribe_state != mcs_smi->subscribe_list;
        subscribe_state = LLNEXT(subscribe_state)){

        for(trnx = LLNEXT(subscribe_state->trnx_list);
            trnx != subscribe_state->trnx_list;
            trnx = LLNEXT(subscribe_state->trnx_list)){
            LLREMOVE(trnx);
            SBUG_SOME("Proxying Subscribe from User to Group Chat Server"); 
            if(subscribe_state->subscribe_gw_dlg_assoc == NULL){
                dlg = corrib_sip_create_gw_dialog_wip("SUBSCRIBE", 
                                                      0,
                                                      mcs_smi->iw_dlg_assoc->dlg->host,
                                                      mcs_smi->iw_dlg_assoc->dlg->port,
                                                      mcs_smi->app_server->as_name);
                subscribe_state->subscribe_gw_dlg_assoc = mas_associate_sm_to_dlg(dlg,
                                                                                  mcs_smi->id,
                                                                                  MAS_STATE_MACHINE_TYPE_CHAT);


                ims_call_id_record(mas_prep_call_id(dlg->call_id,
                                                    mcs_smi->app_server));
            }
            mcs_smi_incref(mcs_smi);
            mas_send_subscribe(trnx, proxy_subscribe_cb);
        }
    }
}

static void send_refer_cb(struct corrib_sip_dialog *dlg,
                          void *cbarg,
                          int code,
                          struct imf *res_imf,
                          struct qsr_forward_error *qfe)
{
    struct mcs_refer_state *refer_state = cbarg;
    struct mcs_state_machine_instance *mcs_smi;
    static struct tbx_string *contact_header;
    static struct tbx_string *extra_headers;
    const char *c1, *c2;
    struct corrib_sip_dialog *refer_dlg;
    int idx;

    SBUG_SOME("REFER returned %d\n", code);
   
    mcs_smi = refer_state->mcs_smi;
    if(refer_state->refer_req_state ||
       refer_state->refer_handoff_req_state){
        // Contact    
        contact_header = tbx_strcpy(contact_header, "");
        contact_header = tbx_strcatf(contact_header, "<sip:%s:5060>", mcs_smi->contact_uri);


        if (mcs_smi->is_mo){
            refer_dlg = mcs_smi->iw_dlg_assoc->dlg;
        }
        else{
            refer_dlg = mcs_smi->gw_dlg_assoc->dlg;
        }

        if (code != -1 && res_imf !=NULL){
            // copy extra bits from response.
            c1 = imf_hdr_get(res_imf, corrib_sip_ihd_contact_num, 0);
            if(((c2 = strchr(c1, '>')) != NULL) ||
               ((c2 = strchr(c1, ';')) != NULL)){
                contact_header = tbx_strcat(contact_header, (*c2 == ';') ? c2 : c2+1);
            }

            extra_headers = tbx_strcpy(extra_headers, "");
            idx = imf_hdr_resolve(res_imf, "Warning");
            if(idx != -1){
                c1 = imf_hdr_get(res_imf, idx, 0);
                if(c1 && strlen(c1)){
                    SBUG_SOME("Warning Header == %s", c1);
                    extra_headers = tbx_strcatf(extra_headers, "Warning: %s\r\n", c1);
                }
            }

            idx = imf_hdr_resolve(res_imf, "Refer-Sub");
            if (idx != -1){
                c1 = imf_hdr_get(res_imf, idx, 0);
                if(c1 && strlen(c1)){
                    SBUG_SOME("Refer-Sub == %s", c1);
                    extra_headers = tbx_strcatf(extra_headers, "Refer-Sub: %s\r\n", c1);
                }
            }

            mas_send_response(refer_state->refer_req_state, 
                              refer_state->refer_handoff_req_state, 
                              refer_state->refer_crb_req, 
                              refer_dlg, 
                              (char *)tbx_strget(contact_header), 
                              tbx_strlen(extra_headers) ? (char *)tbx_strget(extra_headers) : NULL, 
                              NULL, 
                              NULL, 
                              code);

            //Reinitialise all refer parameters
        }
        else{
            SBUG_SOME("No SIP return code, respond with 500 Internal Server Error");
            mas_send_response(refer_state->refer_req_state, 
                              refer_state->refer_handoff_req_state, 
                              refer_state->refer_crb_req, 
                              refer_dlg, 
                              (char *)tbx_strget(contact_header), 
                              NULL, 
                              NULL, 
                              NULL, 
                              500);
        }


        //These do no need to be freed
        crb_req_release(refer_state->refer_crb_req);
        refer_state->refer_crb_req = NULL;

        imf_release(refer_state->refer_imf);
        refer_state->refer_imf = NULL;
        FREE(refer_state);
    }

    mcs_smi_decref(mcs_smi);
}

void mcs_ac_proxy_refer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct mcs_refer_state *state;

    for(state = LLNEXT(mcs_smi->refer_list); 
        state != mcs_smi->refer_list;
        state = LLNEXT(mcs_smi->refer_list)){
        LLREMOVE(state);

        SBUG_SOME("Proxying Refer from User to Group Chat Server");
        mcs_smi_incref(mcs_smi);
        mas_send_refer(&send_refer_cb, state);
    }
}

static void parse_notify_endpoint_cb(xmlDocPtr doc, 
                                     xmlNodePtr cur,
                                     void *cbarg)
{
    xmlChar *key;
    static char *uri = NULL;
    static char *status = NULL;
    struct mgcs_member *mgcs_member;
    char *err_str;
    int found;
    xmlAttr *uri_attr;
    xmlNodePtr child;
    char *sip_uri;
    char *tel_uri;

    struct mcs_state_machine_instance *mcs_smi = cbarg;

    // Get the endpoint "entity"
    found = 0;
    uri_attr = cur->properties;
    while(uri_attr != NULL && !found){
        if((!xmlStrcmp(uri_attr->name, (const xmlChar*)"entity"))){
            found = 1;
        }
        uri_attr = uri_attr->next;
    }

    if (!found) {
        SBUG_SOME("Failed to find entity attribute in <user>.. bad bad");
        return;
    }

    // Grab the URI string
    key = xmlNodeListGetString(doc,uri_attr->xmlChildrenNode,1);
    SBUG_SOME("endpoint entity.. %s: %s\n",
              uri_attr->name,
              key);
    uri = RESTRDUP(uri, (char*)key);
    xmlFree(key);

    // Get the status
    found = 0;
    child = cur->xmlChildrenNode;
    while(child != NULL){
        if((!xmlStrcmp(child->name, (const xmlChar*)"status"))){
            found = 1;
        }
        child = child->next;
    }

    if (!found) {
        SBUG_SOME("Failed to find status child in <endpoint>.. bad bad");
        return;
    }

    key = xmlNodeListGetString(doc,child->xmlChildrenNode,1);
    SBUG_SOME("status.. %s: %s\n",
              child->name,
              key);
    status = RESTRDUP(status, (char*)key);
    xmlFree(key);

    // we have our uri and status now
    // check for connected state and track as a member of the 
    // group chat
    if (!strcasecmp(status, "connected")) {
        SBUG_SOME("Detected connected state.. adding to list");

        // Add member to group list
        // we pass in the arg as NULL as we've not 
        // got any group chat session in play here
        mgcs_member = mgcs_member_alloc(NULL);
        sip_uri = corrib_sip_extract_addr(uri,
                                          &err_str,
                                          EXTRACT_SIP_ADDR);
        if(sip_uri){
            SBUG_SOME("Extracted SIP URI: %s", sip_uri);
            mgcs_member->sip_uri = STRDUP(sip_uri);
        }

        tel_uri = corrib_sip_extract_addr(uri,
                                          &err_str,
                                          EXTRACT_TEL_ADDR);
        if(tel_uri){
            SBUG_SOME("Extracted TEL URI: %s", tel_uri);
            mgcs_member->tel_uri = STRDUP(tel_uri);
        }

        if (sip_uri || tel_uri) {
            // alloc and selflink list if required
            // The list will only be created if 
            // we go to actually add something to it
            // Its NULL state will cause the IMAP
            // storage to ignore the group session object
            // because this arg will be NULL
            if (!mcs_smi->group_chat_members) {
                mcs_smi->group_chat_members = mgcs_member_alloc(NULL);
                LLSELFLINK(mcs_smi->group_chat_members);
            }
            LLINSERTB4(mcs_smi->group_chat_members, mgcs_member);
        }
        else {
            SBUG_SOME("Failed to extract a SIP or TEL URI.. ignoring endpoint");
            mgcs_member_release(mgcs_member);
        }
    }
    else {
        SBUG_SOME("status is not connected.. ignoring");
    }
}

static void parse_notify_user_cb(xmlDocPtr doc, 
                                 xmlNodePtr cur,
                                 void *cbarg)
{
    struct mcs_state_machine_instance *mcs_smi = cbarg;

    ims_xml_walk_children(doc,
                          cur,
                          (xmlChar *)"endpoint",
                          parse_notify_endpoint_cb,
                          mcs_smi);

    return;
}

static void parse_notify_users_cb(xmlDocPtr doc, 
                                  xmlNodePtr cur,
                                  void *cbarg)
{
    struct mcs_state_machine_instance *mcs_smi = cbarg;

    ims_xml_walk_children(doc,
                          cur,
                          (xmlChar *)"user",
                          parse_notify_user_cb,
                          mcs_smi);

    return;
}

static void parse_notify_conf_info_cb(xmlDocPtr doc, 
                                      xmlNodePtr cur,
                                      void *cbarg)
{
    struct mcs_state_machine_instance *mcs_smi = cbarg;

    ims_xml_walk_children(doc,
                          cur,
                          (xmlChar *)"users",
                          parse_notify_users_cb,
                          mcs_smi);

    return;
}

int parse_notify(struct mcs_state_machine_instance *mcs_smi)
{
    // Parsing something like this

    // <conference-info xmlns="urn:ietf:params:xml:ns:conference-info" entity="sip:conf-mas-1-1385638538-2659068760@54.216.91.157" state="full" version="1"> <conference-description>
    //  </conference-description>
    //  <conference-state>
    //    <user-count>3</user-count>
    //  </conference-state>
    //  <users>
    //    <user entity="sip:+353860238089@apktrcs.com" state="full">
    //      <endpoint entity="sip:+353860238089@apktrcs.com">
    //        <status>connected</status>
    //      </endpoint>
    //    </user>
    //    <user entity="sip:+353894017257@apktrcs.com" state="full">
    //      <endpoint entity="sip:+353894017257@apktrcs.com">
    //        <status>connected</status>
    //      </endpoint>
    //    </user>
    //    <user entity="sip:+353894017172@apktrcs.com" state="full">
    //      <endpoint entity="sip:+353894017172@apktrcs.com">
    //        <status>connected</status>
    //      </endpoint>
    //    </user>
    //  </users>
    // </conference-info>
    //
    // The trick is to collect the <endpoint.. > parts with status
    // connected

    xmlChar *content;
    xmlNodePtr cur;
    xmlDocPtr doc;

    // wipe any existing group chat member list
    // This will get created again if we actually
    // parse usable entries from the NOTIFY
    if (mcs_smi->group_chat_members) {
        mgcs_member_release_list(mcs_smi->group_chat_members);
        mcs_smi->group_chat_members = NULL;
    }

    SBUG_SOME("Parsing notify details from..\n%s\n",
              mcs_smi->notify_imf->body_sec);
    content = xmlCharStrdup((const char*)mcs_smi->notify_imf->body_sec);

    doc = xmlParseDoc(content);
    if(!doc){
        SBUG_SOME("Failed to parse document correctly.. bad bad bad");
        return -1;
    }

    cur = xmlDocGetRootElement(doc);
    ims_xml_walk_children(doc,
                          cur,
                          (xmlChar *)"conference-info",
                          parse_notify_conf_info_cb,
                          mcs_smi);
    xmlFree(content);
    xmlFreeDoc(doc);

    return 0;
}

/* test code
void hacky_test_notify_parse(void *arg)
{
    static char* notify_body = 
        "<conference-info xmlns=\"urn:ietf:params:xml:ns:conference-info\" entity=\"sip:conf-mas-1-1385638538-2659068760@54.216.91.157\" state=\"full\" version=\"1\"> <conference-description>\r\n"
        " </conference-description>\r\n"
        " <conference-state>\r\n"
        "   <user-count>3</user-count>\r\n"
        " </conference-state>\r\n"
        " <users>\r\n"
        "   <user entity=\"sip:+353860238089@apktrcs.com\" state=\"full\">\r\n"
        "     <endpoint entity=\"sip:+353860238089@apktrcs.com\">\r\n"
        "       <status>connected</status>\r\n"
        "     </endpoint>\r\n"
        "   </user>\r\n"
        "   <user entity=\"sip:+353894017257@apktrcs.com\" state=\"full\">\r\n"
        "     <endpoint entity=\"sip:+353894017257@apktrcs.com\">\r\n"
        "       <status>connected</status>\r\n"
        "     </endpoint>\r\n"
        "   </user>\r\n"
        "   <user entity=\"sip:+353894017172@apktrcs.com\" state=\"full\">\r\n"
        "     <endpoint entity=\"sip:+353894017172@apktrcs.com\">\r\n"
        "       <status>connected</status>\r\n"
        "     </endpoint>\r\n"
        "   </user>\r\n"
        " </users>\r\n"
        "</conference-info>\r\n";

    struct mcs_state_machine_instance *hacky_smi;

    hacky_smi = mcs_state_machine_create();

    hacky_smi->notify_imf = imf_alloc();

    hacky_smi->notify_imf->body_sec = (unsigned char*)notify_body;

    parse_notify(hacky_smi);
    exit(0);
}
*/

void mcs_ac_proxy_notify_fn(struct mcs_state_machine_instance *mcs_smi)
{
    SBUG_SOME("Proxying Notify from Group Chat Server to User");
    parse_notify(mcs_smi);
    mas_send_notify(mcs_smi);
}

void mcs_ac_store_first_msg_fn(struct mcs_state_machine_instance *mcs_smi)
{
    const char *c1;

    if (mcs_smi->first_msg) {
        SBUG_SOME("Storing first message");
        c1 = imf_hdr_get(mcs_smi->first_msg, corrib_sip_ihd_content_type, 0);
        store_chat_msg(mcs_smi->oa_invite_imf,
                       mcs_smi->iw_dlg_assoc,
                       mcs_smi->oa_user_tel_uri,
                       mcs_smi->oa_user_sip_uri,
                       mcs_smi->da_user_tel_uri,
                       mcs_smi->da_user_sip_uri,
                       mcs_smi->routing_id,
                       CRB_RCS_MT_MSG | CRB_TECH_CLASS_RCS,
                       (c1 && strlen(c1)) ? c1 : "text/plain",
                       strlen((const char *)mcs_smi->first_msg->body_sec),
                       mcs_smi->first_msg->body_sec,
                       NULL, // no callback required here
                       NULL);
        // free it up.. prevents any confusion on the re-invite stages for DA
        imf_release(mcs_smi->first_msg);
        mcs_smi->first_msg = NULL;
    }
}
void mcs_ac_activate_da_storage_fn(struct mcs_state_machine_instance *mcs_smi)
{
    mcs_smi->da_offline = 1;

    mcs_ev_da_storage_ready(mcs_smi->id);
}

void mcs_ac_activate_reinvite_fn(struct mcs_state_machine_instance *mcs_smi)
{
    mcs_smi->reinviting = 1;
}

void mcs_ac_check_da_msrp_status_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct mcs_for_delivery *for_dlv;

    SBUG_SOME("DA Offline:%d DA MSRP Session:0x%p",
              mcs_smi->da_offline,
              mcs_smi->da_msrp_session);
    if (mcs_smi->da_offline && mcs_smi->da_msrp_session == NULL) {
        SBUG_SOME("DA is offline.. going for re-invite");
        mcs_ev_re_invite_da(mcs_smi->id);
    }
    else if(mcs_smi->da_msrp_session->sess && mcs_smi->da_msrp_session->sess->conn){
        SBUG_SOME("DA is not offline.. Can push message to him");
        for_dlv = LLNEXT(mcs_smi->for_delivery_list);
        LLREMOVE(for_dlv);
        mcs_smi->msg_store_crb_req = for_dlv->msg_store_crb_req;
        mcs_smi->msg_store_crb_state = for_dlv->msg_store_crb_state;
        mcs_smi->msg_store_handoff_req_state = for_dlv->msg_store_handoff_req_state;
        FREE(for_dlv);
        mcs_ev_send_msg_to_da(mcs_smi->id);
    }
    else {
        SBUG_SOME("MSRP unavail to be delivered");
        mcs_ev_da_msrp_unavail(mcs_smi->id);
    }
}

void mcs_ac_send_msgs_to_da_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct mcs_for_delivery *for_dlv;

    if(mcs_smi->for_delivery_list == NULL){
        return;
    }
    for(for_dlv = LLNEXT(mcs_smi->for_delivery_list);
        for_dlv != mcs_smi->for_delivery_list;
        for_dlv = LLNEXT(mcs_smi->for_delivery_list)){
        LLREMOVE(for_dlv);
        mas_msrp_send_crb_req_from_storage(for_dlv->msg_store_crb_state,
                                           for_dlv->msg_store_handoff_req_state,
                                           for_dlv->msg_store_crb_req,
                                           mcs_smi);
        FREE(for_dlv);
    }
}

void mcs_ac_send_msg_to_da_fn(struct mcs_state_machine_instance *mcs_smi)
{
    mas_msrp_send_crb_req_from_storage(mcs_smi->msg_store_crb_state,
                                       mcs_smi->msg_store_handoff_req_state,
                                       mcs_smi->msg_store_crb_req,
                                       mcs_smi);
    // We're done with the store req now as the
    // MSRP layer will do all ack/nacking
    // and has its own dupe
    crb_req_release(mcs_smi->msg_store_crb_req);
    mcs_smi->msg_store_crb_req = NULL;
    mcs_smi->msg_store_crb_state = NULL;
    mcs_smi->msg_store_handoff_req_state = NULL;

}

void mcs_ac_extract_da_content_fn(struct mcs_state_machine_instance *mcs_smi)
{
    const char *c1;
    char *c2, *c3;
    struct ims_multipart *multi = NULL;
    struct ims_part *part = NULL;
    struct imf *imf;

    SBUG_SOME("Extracting Outleg Content\n");

    imf = mcs_smi->da_invite_res_imf;

    c1 = imf_hdr_get(imf, corrib_sip_ihd_content_type, 0);
    
    SBUG_SOME("Content Type %s\n", c1 ? c1 : "EMPTY");
    if(strncasecmp("application/sdp", c1, 15) == 0){
        SBUG_SOME("Only SDP\n");
        mcs_smi->da_sdp = RESTRDUP(mcs_smi->da_sdp, (char*)imf->body_sec);
        return;
    }
    else if(strncasecmp("multipart/mixed", c1, 15) == 0){
        SBUG_SOME("Have multipart/mixed content\n");
       
        multi = ims_multipart_split(imf);
        
        for(part = LLNEXT(multi->part_list); 
            part != multi->part_list; 
            part = LLNEXT(part)){

            c1 = imf_hdr_get(part->imf, corrib_sip_ihd_content_type, 0);
            if(strncasecmp("application/sdp", c1, 15) == 0){
                SBUG_SOME("Found SDP in Multipart\n");
                mcs_smi->da_sdp = RESTRDUP(mcs_smi->da_sdp, (char*)part->imf->body_sec);
            }
        }

        ims_multipart_release(multi);
    }
    else {
        mcs_ev_no_content(mcs_smi->id);
        return;
    }
    // get device gruu or sip.instance
    if((c1 = mas_extract_device_info(imf)) != NULL){
        mcs_smi->da_device = RESTRDUP(mcs_smi->da_device, c1);
    }
}

void mcs_ac_get_session_type_fn(struct mcs_state_machine_instance *mcs_smi)
{

    const char *c1;
    struct imf *imf;
    int num, i;

    imf = mcs_smi->oa_invite_imf;

    num = imf_hdr_count(imf, corrib_sip_ihd_accept_contact);
    for(i=0; i<num; i++){

        c1 = imf_hdr_get(imf, corrib_sip_ihd_accept_contact, i);
        if(strlen(c1)){

            SBUG_SOME("Accept Contact %s\n", c1);


            if (strcasestr(c1, "+g.oma.sip-im.large-message")){ 
                mcs_smi->is_large_msg = 1;
                mcs_smi->is_sip_simple = 1;
                mcs_ev_valid_session_type(mcs_smi->id);
                return;
            }

            if (strcasestr(c1, "3gpp-service.ims.icsi.oma.cpm.largemsg")){
                mcs_smi->is_large_msg = 1;
                mcs_smi->is_cpm = 1;
                mcs_ev_valid_session_type(mcs_smi->id);
                return;
            }

            if (strcasestr(c1, "+g.oma.sip-im") ||
                strcasestr(c1, "3gpp-application.ims.iari.gsma-is")){ // image share
                mcs_smi->is_chat = 1;
                mcs_smi->is_sip_simple = 1;
                mcs_ev_valid_session_type(mcs_smi->id);
                return;
            }

            if (strcasestr(c1, "3gpp-service.ims.icsi.oma.cpm.session")){
                mcs_smi->is_chat = 1;
                mcs_smi->is_cpm = 1;
                mcs_ev_valid_session_type(mcs_smi->id);
                return;
            }

        }
    }
    
    mcs_ev_unknown_session_type(mcs_smi->id);


}

void mcs_ac_create_oa_local_msrp_uri_fn(struct mcs_state_machine_instance *mcs_smi)
{
    mcs_smi->oa_local_msrp_uri = msrp_generate_uri(0,
                                                   gv_msrp_settings->public_msrp_host,
                                                   mas_msrp_get_svr_port(),
                                                   (char*)tbx_qsprintf("%08x", ripley_get_thread_id()));

    SBUG_SOME("Inleg Local MSRP URI created: %s", tbx_strget(mcs_smi->oa_local_msrp_uri->value));

}

void mcs_ac_create_da_local_msrp_uri_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->da_local_msrp_uri) {
        SBUG_SOME("Removing old DA MSRP URI: %s", tbx_strget(mcs_smi->da_local_msrp_uri->value));
        msrp_release_uri(mcs_smi->da_local_msrp_uri);
        mcs_smi->da_local_msrp_uri = NULL;
    }
    mcs_smi->da_local_msrp_uri = msrp_generate_uri(0,
                                                   gv_msrp_settings->public_msrp_host,
                                                   mas_msrp_get_svr_port(),
                                                   (char*)tbx_qsprintf("%08x", ripley_get_thread_id()));

    SBUG_SOME("Outleg Local MSRP URI created: %s", tbx_strget(mcs_smi->da_local_msrp_uri->value));
}

void mcs_ac_return_to_ims_core_for_termination_fn(struct mcs_state_machine_instance *mcs_smi)
{

    //TODO: AK: Not sure what to do here yet

}

void mcs_ac_send_session_progress_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mcs_smi->oa_crb_state || mcs_smi->oa_handoff_req_state){
        mas_send_iresponse(mcs_smi->oa_crb_state,
                           mcs_smi->oa_handoff_req_state,
                           mcs_smi->oa_invite_crb_req,
                           mcs_smi->iw_dlg_assoc->dlg,
                           NULL,
                           NULL, 
                           NULL,
                           NULL,
                           183);
    }
}

void mcs_ac_proxy_interim_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mcs_smi->oa_crb_state || mcs_smi->oa_handoff_req_state){
        mas_send_iresponse(mcs_smi->oa_crb_state,
                           mcs_smi->oa_handoff_req_state,
                           mcs_smi->oa_invite_crb_req,
                           mcs_smi->iw_dlg_assoc->dlg,
                           NULL,
                           NULL, 
                           NULL,
                           NULL,
                           mcs_smi->da_invite_interim_return_code);
    }
}

void mcs_ac_mark_invite_for_ipsms_fn(struct mcs_state_machine_instance *mcs_smi)
{
    SBUG_SOME("leaving req continue on bus modified for IPSMS (Whiskey)");

    conrad_add_as_name(mcs_smi->oa_invite_crb_req, 
                       gv_ipsmgw_server);

    crb_consumer_modified(mcs_smi->oa_crb_state, mcs_smi->oa_invite_crb_req);
}

void mcs_ac_nack_inleg_invite_fn(struct mcs_state_machine_instance *mcs_smi, int error_code)
{
    if(mcs_smi->oa_crb_state || mcs_smi->oa_handoff_req_state){
        mas_send_response(mcs_smi->oa_crb_state,
                          mcs_smi->oa_handoff_req_state,
                          mcs_smi->oa_invite_crb_req,
                          mcs_smi->iw_dlg_assoc->dlg,
                          NULL,
                          NULL, 
                          NULL,
                          NULL,
                          error_code);
    }
}

void mcs_ac_nack_inleg_reinvite_fn(struct mcs_state_machine_instance *mcs_smi, int error_code)
{
    if(mcs_smi->reinvite_crb_state || mcs_smi->reinvite_handoff_req_state){
        mas_send_response(mcs_smi->reinvite_crb_state,
                          mcs_smi->reinvite_handoff_req_state,
                          mcs_smi->reinvite_invite_crb_req,
                          mcs_smi->reinvite_dlg_assoc->dlg,
                          NULL,
                          NULL, 
                          NULL,
                          NULL,
                          error_code);

        if(mcs_smi->reinvite_invite_imf){
            imf_release(mcs_smi->reinvite_invite_imf);
            mcs_smi->reinvite_invite_imf = NULL;
        }

        if(mcs_smi->reinvite_invite_crb_req){
            crb_req_release(mcs_smi->reinvite_invite_crb_req);
            mcs_smi->reinvite_invite_crb_req = NULL;
        }
    }
}

void mcs_ac_nack_inleg_invite_with_da_error_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mcs_smi->oa_crb_state || mcs_smi->oa_handoff_req_state){
        mas_send_response(mcs_smi->oa_crb_state,
                          mcs_smi->oa_handoff_req_state,
                          mcs_smi->oa_invite_crb_req,
                          mcs_smi->iw_dlg_assoc->dlg,
                          NULL,
                          NULL, 
                          NULL,
                          NULL,
                          mcs_smi->da_invite_error_code);
    }
}

void mcs_ac_parse_inleg_offered_sdp_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct msrp_sdp_details *msd;

    SBUG_SOME("Parsing Inleg offered sdp\n");

    if((msd = msrp_sdp_details_parse(mcs_smi->oa_sdp)) == NULL){
        SBUG_SOME("SDP Is unacceptable\n");
        mcs_ev_inleg_sdp_unacceptable(mcs_smi->id);
        return;
    }

    SBUG_SOME("%s", msrp_sdp_details_to_string("MSRP SDP Details", msd));
    
    if(msd->accept_types == NULL || msd->accept_types[0] == '\0'){
        SBUG_SOME("SDP Is unacceptable\n");
        msrp_sdp_details_release(msd);
        mcs_ev_inleg_sdp_unacceptable(mcs_smi->id);
        return;
    }
    if(msd->path == NULL || msd->path[0] == '\0'){
        SBUG_SOME("SDP Is unacceptable\n");
        msrp_sdp_details_release(msd);
        mcs_ev_inleg_sdp_unacceptable(mcs_smi->id);
        return;
    }

    if(msd->setup == NULL || msd->setup[0] == '\0'){
        SBUG_SOME("No setup offered in OA SDP, defaulting to active");
        msd->setup = RESTRDUP(msd->setup, "active");
    }

    if(msd->file_transfer_id != NULL && msd->file_transfer_id[0] != '\0'){
        SBUG_SOME("file-transfer-id offered in OA SDP: %s", msd->file_transfer_id);
        cstat_gadj(mas_file_transfers, 1);
        cstat_cadj(mas_file_transfers_invites_received, 1);
    }

    mcs_smi->oa_offered_msd = msd;
    mcs_ev_inleg_sdp_ok(mcs_smi->id);
}

static void send_bye_cb(void *cbarg)
{
    struct mcs_state_machine_instance *mcs_smi = (struct mcs_state_machine_instance *) cbarg;
    SBUG_SOME("Send Bye Completed");
    mcs_ev_bye_ok(mcs_smi->id);
    mcs_smi_decref(mcs_smi);
}

void wait_for_bye_timeout_cb(void *cbarg){
    struct mcs_state_machine_instance *mcs_smi = cbarg;

    SBUG_SOME("No BYE recieved from device, assume this is a disconnect");
    mcs_smi->wait_for_bye_event = NULL;
    mcs_ev_wait_for_bye_timeout(mcs_smi->id);
}

void mcs_ac_start_wait_for_bye_timer_fn(struct mcs_state_machine_instance *mcs_smi){
    SBUG_SOME("TCP session has been closed, wait %d secs to see if BYE is coming from device", TIME_TO_WAIT_FOR_BYE_SECS);
    if(mcs_smi->wait_for_bye_event){
        tbx_cancel_event(mcs_smi->wait_for_bye_event);
    }
    mcs_smi->wait_for_bye_event = tbx_queue_event(TIME_TO_WAIT_FOR_BYE_SECS * 1000, 
                                                  wait_for_bye_timeout_cb, 
                                                  mcs_smi);
}

void mcs_ac_stop_wait_for_bye_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->wait_for_bye_event){
        SBUG_SOME("Wait for bye timer was active, cancel and handle OA BYE as normal");
        tbx_cancel_event(mcs_smi->wait_for_bye_event);
        mcs_smi->wait_for_bye_event = NULL;
    }
}

void mcs_ac_send_da_bye_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->wait_for_bye_event){
        SBUG_SOME("Wait for bye timer was active, cancel and handle OA BYE as normal");
        tbx_cancel_event(mcs_smi->wait_for_bye_event);
        mcs_smi->wait_for_bye_event = NULL;
    }

    if(mcs_smi->da_invite_res_imf){
        mcs_smi_incref(mcs_smi);
        corrib_sip_send_bye(mas_crb_hndl,
                            send_bye_cb,
                            mcs_smi,
                            mcs_smi->gw_dlg_assoc->dlg,
                            mcs_smi->da_invite_imf,
                            mcs_smi->da_invite_res_imf,
                            mcs_smi->oa_bye_reason,
                            mcs_smi->app_server->as_uri); 
    }
    else {
        // Never established a session with the da.
        mcs_ev_bye_ok(mcs_smi->id);
    }
}


void mcs_ac_send_oa_bye_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->wait_for_bye_event){
        SBUG_SOME("Wait for bye timer was active, cancel and handle DA BYE as normal");
        tbx_cancel_event(mcs_smi->wait_for_bye_event);
        mcs_smi->wait_for_bye_event = NULL;
    }
    
    mcs_smi_incref(mcs_smi);
    corrib_sip_send_bye(mas_crb_hndl,
                        send_bye_cb,
                        mcs_smi,
                        mcs_smi->iw_dlg_assoc->dlg,
                        mcs_smi->oa_invite_imf,
                        mcs_smi->oa_invite_res_imf,
                        mcs_smi->da_bye_reason,
                        mcs_smi->app_server->as_uri);
}

void mcs_ac_check_is_mo_or_mt_fn(struct mcs_state_machine_instance *mcs_smi)
{
    int num, i;
    const char *c1;
    static char *as_prefix;
        

    if (mcs_smi->app_server == gv_mas_term_server){    
        mcs_smi->is_mo = 0;
        c1 = strchr(gv_mas_term_server->as_uri, '@');
        as_prefix = RESUBSTRDUP(as_prefix, gv_mas_term_server->as_uri, c1);

        if (mcs_smi->da_user_sip_uri && strstr(mcs_smi->da_user_sip_uri, as_prefix)){
            SBUG_SOME("This is an MT RE-INVITE");
            mcs_smi->is_reinvite = 1;
        }
        else{
            SBUG_SOME("This is an MT INVITE");
            mcs_smi->is_reinvite = 0;
        }
    }
    else{
        mcs_smi->is_mo = 1;
        
        c1 = strchr(gv_mas_orig_server->as_uri, '@');
        as_prefix = RESUBSTRDUP(as_prefix, gv_mas_orig_server->as_uri, c1);
        
        if (mcs_smi->da_user_sip_uri && strstr(mcs_smi->da_user_sip_uri, as_prefix)){
            SBUG_SOME("This is an MO RE-INVITE");
            mcs_smi->is_reinvite = 1;
        }
        else{
            SBUG_SOME("This is an MO INVITE");
            mcs_smi->is_reinvite = 0;
        }
    }

    //Determine whether this is a leg of a group chat or a 1-1 chat
    if (mcs_smi->is_reinvite){
        SBUG_SOME("This re-invite is on the leg of a group chat");
        mcs_smi->is_group_chat_leg = 1; 
    }
    else{
        c1 = strchr(gv_mas_conf_server->as_uri, '@');
        as_prefix = RESUBSTRDUP(as_prefix, gv_mas_conf_server->as_uri, c1);

        c1 = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_to_num, 0);
        SBUG_SOME("To Header = %s", c1);

        if (c1 && strstr(c1, as_prefix) != NULL){
            SBUG_SOME("This invite represents an Orig leg of a group chat");
            mcs_smi->is_group_chat_leg = 1; 
            mcs_smi->is_group_originator = 1;
        }
        else{
            c1 = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
            if (*c1){
                SBUG_SOME("Contact = %s\n", c1);
                if (strstr(c1, "isfocus") != NULL){
                    SBUG_SOME("This invite represents a Term leg of a group chat");
                    mcs_smi->is_group_chat_leg = 1;
                }
                else{
                    SBUG_SOME("This invite represents a 1 to 1 chat");
                    mcs_smi->is_group_chat_leg = 0;
                }
            }
        }
    }
}

void mcs_ac_extract_oa_and_da_fn(struct mcs_state_machine_instance *mcs_smi)
{
    char *oa_user_sip_uri = NULL;
    char *da_user_sip_uri = NULL;
    char *oa_scscf_sip_uri = NULL;
    char *oa_user_tel_uri = NULL;
    char *da_user_tel_uri = NULL;
    int i, num;
    const char *c1;
    char *err_str;
    int sip_ihd_num;
    static char *as_prefix;

    // extract orig addr
    if((num = imf_hdr_count(mcs_smi->oa_invite_imf, corrib_sip_ihd_p_asserted_id)) > 0){
        SBUG_SOME("Looking for P-Asserted-ID\n");
        sip_ihd_num = corrib_sip_ihd_p_asserted_id;
    }
    else {
        SBUG_SOME("Could not find P-Asserted-ID using From\n");
        num = 1;
        sip_ihd_num = corrib_sip_ihd_from_num;
    }

    for(i=0;
        i<num && oa_user_tel_uri == NULL && oa_user_sip_uri == NULL;
        i++){
        if(oa_user_sip_uri == NULL){
            c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf,
                                                sip_ihd_num,
                                                i,
                                                &err_str,
                                                EXTRACT_SIP_ADDR);
            if(c1){
                oa_user_sip_uri = STRDUP(c1);
            }
        }

        if(oa_user_tel_uri == NULL){
            c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf,
                                                sip_ihd_num,
                                                i,
                                                &err_str,
                                                EXTRACT_TEL_ADDR);
            if(c1){
                oa_user_tel_uri = STRDUP(c1);
            }
        }
    }

    if(oa_user_sip_uri == NULL && oa_user_tel_uri == NULL){
        SBUG_SOME("Couldn't find OA's sip uri or tel uri... nacking\n");
        mcs_ev_oa_and_da_extract_fail(mcs_smi->id);        
        return;
    }

    if(oa_user_tel_uri){
        SBUG_SOME("Extracted OA TEL URI: [%s]", oa_user_tel_uri);
    }
    else{
        SBUG_SOME("No OA TEL URI extracted");
    }

    if(oa_user_sip_uri){
        SBUG_SOME("Extracted OA SIP URI: [%s]", oa_user_sip_uri);
    }
    else{
        SBUG_SOME("No OA SIP URI extracted");
    } 

    SBUG_SOME("Could not find P-Asserted-ID or Referred-By header using From\n");
    sip_ihd_num = corrib_sip_ihd_to_num;

    c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf,
                                        sip_ihd_num,
                                        0,
                                        &err_str,
                                        EXTRACT_SIP_ADDR);
    if(c1){
        da_user_sip_uri = STRDUP(c1);
    }

    c1 = corrib_sip_extract_addr_header(mcs_smi->oa_invite_imf,
                                        sip_ihd_num,
                                        0,
                                        &err_str,
                                        EXTRACT_TEL_ADDR);
    if(c1){
        da_user_tel_uri = STRDUP(c1);
    }

    if(da_user_sip_uri == NULL && da_user_tel_uri == NULL){
        SBUG_SOME("Couldn't find DA sip uri or DA tel uri... nacking\n");
        mcs_ev_oa_and_da_extract_fail(mcs_smi->id);        
        return;
    }
    
    if(da_user_tel_uri){
        SBUG_SOME("Extracted DA TEL URI: [%s]", da_user_tel_uri);
    }
    else{
        SBUG_SOME("No DA TEL URI extracted");
    }

    if(da_user_sip_uri){
        SBUG_SOME("Extracted DA SIP URI: [%s]", da_user_sip_uri);
    }
    else{
        SBUG_SOME("No DA SIP URI extracted");
    }

    mcs_smi->oa_user_sip_uri = RESTRDUP(mcs_smi->oa_user_sip_uri, (oa_user_sip_uri != NULL ? oa_user_sip_uri : ""));
    mcs_smi->oa_user_tel_uri = RESTRDUP(mcs_smi->oa_user_tel_uri, (oa_user_tel_uri != NULL ? oa_user_tel_uri : ""));
    mcs_smi->da_user_sip_uri = RESTRDUP(mcs_smi->da_user_sip_uri, (da_user_sip_uri != NULL ? da_user_sip_uri : ""));
    mcs_smi->da_user_tel_uri = RESTRDUP(mcs_smi->da_user_tel_uri, (da_user_tel_uri != NULL ? da_user_tel_uri : ""));

    // Chat history list init
    mcs_smi->chat_msg_history = mas_chat_msg_alloc(NULL);
    LLSELFLINK(mcs_smi->chat_msg_history);

    mcs_ev_oa_and_da_extract_ok(mcs_smi->id);        
}

void mcs_ac_parse_outleg_answered_sdp_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct msrp_sdp_details *msd;

    SBUG_SOME("Parsing outleg answered sdp\n"); 
    if((msd = msrp_sdp_details_parse(mcs_smi->da_sdp)) == NULL){
        SBUG_SOME("SDP Is unacceptable\n");
        mcs_ev_outleg_sdp_unacceptable(mcs_smi->id);
        return;
    }
    SBUG_SOME("%s", msrp_sdp_details_to_string("MSRP SDP Details", msd));

    if(msd->accept_types == NULL || msd->accept_types[0] == '\0'){
        SBUG_SOME("SDP Is unacceptable\n");
        mcs_ev_outleg_sdp_unacceptable(mcs_smi->id);
        return;
    }

    if(msd->path == NULL || msd->path[0] == '\0'){
        SBUG_SOME("SDP Is unacceptable\n");
        mcs_ev_outleg_sdp_unacceptable(mcs_smi->id);
        return;
    }
    
    if(msd->setup == NULL || msd->setup[0] == '\0'){
        SBUG_SOME("No setup answer in DA SDP, defaulting to passive");
        msd->setup = RESTRDUP(msd->setup, "passive");
    }
    SBUG_SOME("Got setup [%s]\n", msd->setup);

    mcs_smi->da_answered_msd = msd;
    mcs_ev_outleg_sdp_ok(mcs_smi->id);
}

void accept_session_timer_cb(void *cb)
{
    struct mcs_state_machine_instance *mcs_smi = cb;
    SBUG_SOME("This session has not been accepted/declined in %d seconds", gv_ims_settings->accept_session_timeout);
    mcs_smi->accept_session_timeout_event = NULL;
    mcs_ev_accept_session_timeout(mcs_smi->id);
}

void mcs_ac_start_accept_session_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    int interval;

    SBUG_SOME("Starting accept session timer");
    if(mcs_smi->accept_session_timeout_event){
        tbx_cancel_event(mcs_smi->accept_session_timeout_event);
    }
    interval = gv_ims_settings->accept_session_timeout*1000;
    if(mcs_smi->is_mo){
        interval *= 1.5; // for MO add 50% to allow MAS TERM timer expire first.
    }
    mcs_smi->accept_session_timeout_event = tbx_queue_event(interval, accept_session_timer_cb, mcs_smi);
}

void mcs_ac_stop_accept_session_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->accept_session_timeout_event){
        SBUG_SOME("Stopping accept session timer");
        tbx_cancel_event(mcs_smi->accept_session_timeout_event);
        mcs_smi->accept_session_timeout_event = NULL;
    }
}

void mcs_ac_set_da_invite_error_fn(struct mcs_state_machine_instance *mcs_smi,
                                   int error_code)
{
    mcs_smi->da_invite_error_code = error_code;
}

static int map_code(int code)
{
    switch(code){
      case 480: // Temporarily Unavailable
        return 200;

      case 408: // Request Timeout
      case 487: // Request Terminated
      case 500: // Server Internal Error
      case 503: // Service Unavailable
      case 504: // Server Timeout
      case 600: // Busy Everywhere
      case 603: // Declined
        return 486;

      default:
        return code;
    }
}

void mcs_ac_check_da_error_fn(struct mcs_state_machine_instance *mcs_smi)
{
    int mapped;
    int gc_allowed=0;

    // Check error for MT leg to see if we have an unavailable
    // scenario where we invoke storage for the DA
    mapped = map_code(mcs_smi->da_invite_error_code);

    SBUG_SOME("Chat leg:%s Group Chat Leg:%s Invite Error:%d MapCode:%d File Transfer:%s",
              mcs_smi->is_mo ? "MO" : "MT",
              mcs_smi->is_group_chat_leg ? "Yes" : "No",
              mcs_smi->da_invite_error_code,
              mapped,
              (mcs_smi->oa_offered_msd->file_transfer_id[0] != '\0') ? "Yes" : "No");

    if(mcs_smi->is_group_chat_leg){
       fletch_get_feature(FLETCH_IMS_GROUP_CHAT_FULL_STANDFW, &gc_allowed);
    }
    
    // MO interwork error detection
    // for IP-SMS breakout
    // Then falling back on existing mo file transfer and group chat
    // handling
    if(mcs_smi->is_mo && 
       interwork_check(mcs_smi->da_invite_error_code,
                       strlen(mcs_smi->oa_user_tel_uri) ? mcs_smi->oa_user_tel_uri : mcs_smi->oa_user_sip_uri,
                       strlen(mcs_smi->da_user_tel_uri) ? mcs_smi->da_user_tel_uri : mcs_smi->da_user_sip_uri)) {
        // escalation to IPSMS (whiskey) 
        SBUG_SOME("Received interwork error %d on DA INVITE.. going for escalation to IPSMS",
                  mcs_smi->da_invite_error_code);
        mcs_ev_breakout_to_ipsms(mcs_smi->id);
    }
    else if(mcs_smi->is_mo || 
       mcs_smi->oa_offered_msd->file_transfer_id[0] != '\0' ||
       (mcs_smi->is_group_chat_leg && !gc_allowed) || 
       mcs_smi->da_invite_interim_return_code == 180 ||
       (mapped != 200 && mapped != 486)){
       SBUG_SOME("Not Storing the Message... relaying error as is\n");
        mcs_ev_da_invite_failed(mcs_smi->id);
    }
    else if(mapped == 200 ||
            (mcs_smi->is_group_chat_leg && gc_allowed)) {
        SBUG_SOME("DA is Unavailable... storage + establish session with OA\n");
        mcs_ev_da_invite_unavail(mcs_smi->id);
    }
    else {
        SBUG_SOME("Encountered Temporary error %d... mapping to %d, nacking Invite but storing\n", 
                  mcs_smi->da_invite_error_code, mapped);
        mcs_ev_da_invite_send_busy(mcs_smi->id); 
    }
}

void activity_check_event_cb(void *cb)
{
    struct mcs_state_machine_instance *mcs_smi = cb;

    if ((tbx_rough_time() - mcs_smi->last_activity_time) > gv_msrp_settings->idle_session_timeout){
        SBUG_SOME("This session has been idle for more than %d seconds, terminating", gv_msrp_settings->idle_session_timeout);
        mcs_smi->activity_time_check_event = NULL;
        mcs_ev_idle_timeout(mcs_smi->id);
    }
    else{
        mcs_smi->activity_time_check_event = tbx_queue_event(1*1000, activity_check_event_cb, mcs_smi);
    }
}

void mcs_ac_start_activity_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->is_mo && mcs_smi->is_group_chat_leg == 0){
        SBUG_SOME("Starting activity time checker");
        mcs_smi->last_activity_time = tbx_rough_time();
        if(mcs_smi->activity_time_check_event){
            tbx_cancel_event(mcs_smi->activity_time_check_event);
        }
        mcs_smi->activity_time_check_event = tbx_queue_event(1*1000, activity_check_event_cb, mcs_smi);
    }
    else{
        if (mcs_smi->is_group_chat_leg == 1){
            SBUG_SOME("Not starting activity time checker, this is a group chat leg");
        }
        else{
            SBUG_SOME("Not starting activity time checker, this is MT leg");
        }
    }
}

void mcs_ac_send_invite_to_da_fn(struct mcs_state_machine_instance *mcs_smi)
{
    char *host;
    int port;
    struct corrib_sip_dialog *dlg;

    if(mcs_smi->scscf_host && *mcs_smi->scscf_host){
        host = mcs_smi->scscf_host;
        port = mcs_smi->scscf_port;
    }
    else  if(mcs_smi->iw_dlg_assoc && mcs_smi->iw_dlg_assoc->dlg &&
             mcs_smi->iw_dlg_assoc->dlg->host) {
        host = mcs_smi->iw_dlg_assoc->dlg->host;
        port = mcs_smi->iw_dlg_assoc->dlg->port;
    }
    else {
        host = NULL;
        port = 0;
    }
    dlg = corrib_sip_create_gw_dialog_wip("INVITE", 
                                          0,
                                          host,
                                          port,
                                          mcs_smi->app_server->as_name);
    mcs_smi->gw_dlg_assoc = mas_associate_sm_to_dlg(dlg,
                                                    mcs_smi->id,
                                                    MAS_STATE_MACHINE_TYPE_CHAT);
    ims_call_id_record(mas_prep_call_id(dlg->call_id,
                                        mcs_smi->app_server));

    mcs_smi->da_invite_crb_req = mas_send_invite(mcs_smi);
    if (mcs_smi->da_invite_crb_req != NULL){ 
        mcs_smi->da_invite_imf = imf_dupe(&mcs_smi->da_invite_crb_req->qsr_msg.imf);
    }
}

static void mcs_conrad_get_cb(struct conrad_store_entry *entry,
                              void *cbarg)
{
    struct ntl_string *nstr=NULL;
    static char *host = NULL;
    int port=5060;
    struct mcs_state_machine_instance *smi = cbarg;
    struct mcs_for_delivery *for_dlv = NULL;
    struct crb_req *req = NULL;
    char *c1;

    if(smi->determine_scscf_cancelled){
        SBUG_SOME("Determined SCSCF Cancelled\n");
        smi->determine_scscf_cancelled = 0;
        mcs_smi_decref(smi);
        return;
    }

    if(entry && entry->scscf_addr &&
       entry->scscf_addr[0] != '\0'){
        if((c1 = strchr(entry->scscf_addr, ':')) !=NULL){
            host = RESUBSTRDUP(host, entry->scscf_addr, c1);
            port = tbx_stoi(c1+1);
        }
        else {
            host = RESTRDUP(host, c1);
            port = 5060;
        }
        SBUG_SOME("Using SCSCF From Conrad Entry %s:%d\n", host, port);
    }
    else {
        SBUG_SOME("Check for delivery list for SCSCF INFO\n");
        // searching backwards assuming the last message in the list
        // if there are more than one will have more up-to-date SCSCF info
        if(smi->for_delivery_list){
            for(for_dlv = smi->for_delivery_list->blink;
                for_dlv != smi->for_delivery_list;
                for_dlv = for_dlv->blink){
                req = for_dlv->msg_store_crb_req;
                if((nstr = bvm_mas_scscf_get_ntl_string_mas_scscf_addr(req)) != NULL){
                    break;
                }
            }
        }

        if(nstr){
            SBUG_SOME("Found SCSCF INFO in for delivery list %s\n", nstr->str);

            if((c1 = strchr(nstr->str, ':')) !=NULL){
                host = RESUBSTRDUP(host, nstr->str, c1);
                port = tbx_stoi(c1+1);
            }
            else {
                host = RESTRDUP(host, c1);
                port = 5060;
            }
            ntl_string_release(nstr);
        }
        else if(smi->scscf_host != NULL && smi->scscf_host[0] != '\0'){
            host = RESTRDUP(host, smi->scscf_host);
            port = smi->scscf_port;
            SBUG_SOME("Using Previous SCSCF %s:%d\n", host, port);
        }
        else  if(smi->iw_dlg_assoc && smi->iw_dlg_assoc->dlg &&
                 smi->iw_dlg_assoc->dlg->host) {
            host = RESTRDUP(host, smi->iw_dlg_assoc->dlg->host);
            port = smi->iw_dlg_assoc->dlg->port;
            SBUG_SOME("Using SCSCF From IW DLG %s:%d\n", host, port);
        }
    }

    mcs_ev_scscf_determined(smi->id,
                            host,
                            port);
    mcs_smi_decref(smi);
}

void mcs_ac_cancel_determine_scscf_fn(struct mcs_state_machine_instance *smi)
{
    smi->determine_scscf_cancelled = 1;
}

void mcs_ac_determine_scscf_fn(struct mcs_state_machine_instance *smi)
{
    int key_type;
    char *key;
   
    if(smi->da_user_sip_uri){
        key_type = CONRAD_STORE_KEY_UNAME;
        key = smi->da_user_sip_uri;
    }
    else {
        key_type = CONRAD_STORE_KEY_MSISDN;
        key = smi->da_user_tel_uri;
    }

    mcs_smi_incref(smi);
    conrad_store_get(key,
                     key_type,
                     IMS_ASTYPE_RCS_MAS_ORIG | IMS_ASTYPE_RCS_MAS_TERM,
                     mcs_conrad_get_cb,
                     smi);

}
static void send_ack_cb(void *cbarg)
{
    struct mcs_state_machine_instance *mcs_smi = (struct mcs_state_machine_instance *) cbarg;
    SBUG_SOME("ACK send completed");
    mcs_smi_decref(mcs_smi);
}

void mcs_ac_send_ack_to_da_fn(struct mcs_state_machine_instance *mcs_smi)
{
    // Only issue the ACK if the DA is marked as online
    if (!mcs_smi->da_offline) {

        mcs_smi_incref(mcs_smi);
        corrib_sip_send_ack(mas_crb_hndl,
                            send_ack_cb,
                            (void *)mcs_smi,
                            mcs_smi->gw_dlg_assoc->dlg,
                            mcs_smi->da_invite_imf,
                            mcs_smi->da_invite_res_imf,
                            mcs_smi->app_server->as_uri);
    }
}

void mcs_ac_register_session_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct tron_data *tron_data = NULL;
    struct crb_req *crb_req = NULL;
    struct ntl_integer *tron_req_type = NULL;
    struct ntl_string *tron_thread_id = NULL;
    int chat_type = CRB_RCS_MO_CHAT_BEGIN;
    char tmp_str[1024];
    struct tbx_buffer *buf = NULL;
    const char *tmpPtr = NULL;
    char *tokStr = NULL;
    char *uuid = NULL;
    struct ims_data *ims_data_ptr = NULL;
    struct tbx_string *str = NULL;
    static char *tokBuf = NULL;

    // register handoff based on routing ID
    // but do it once only.. we will return 
    // here in subscribes and other scenarios

    memset(tmp_str, 0, sizeof(tmp_str));
    if (mcs_smi->is_mo <= 0) {
        chat_type = CRB_RCS_MT_CHAT_BEGIN;
        SBUG_SOME("MT chat start");
    }

    if (!mcs_smi->routing_id_registered) {
        SBUG_SOME("Registering routing ID chat leg.. %s", mcs_smi->routing_id);
        SBUG_SOME("Group chat uri [%s]", mcs_smi->group_chat_uri);

        if (mcs_smi->oa_contribution_id){
            SBUG_SOME("oa_contribution_id [%s]", mcs_smi->oa_contribution_id);
        }
        if (mcs_smi->oa_conversation_id){
            SBUG_SOME("oa_conversation_id [%s]", mcs_smi->oa_conversation_id);
        }

        record_group_chat_leg_uri_id(mcs_smi->routing_id, mcs_smi->id,
            mcs_smi->group_chat_uri);
        mcs_smi->routing_id_registered = 1;

        // Tron registration of a successful Chat setup
        crb_req = crb_req_alloc();
        tron_data = tron_data_alloc();
        tron_req_type = ntl_integer_alloc();
        tron_thread_id = tron_common_make_ntl_string(mcs_smi->routing_id);

        SBUG_SOME("mcs_smi->oa_user_tel_uri [%s] [%s]", mcs_smi->oa_user_tel_uri,
            mcs_smi->oa_user_sip_uri);
        SBUG_SOME("mcs_smi->da_user_tel_uri [%s] [%s]", mcs_smi->da_user_tel_uri,
            mcs_smi->da_user_sip_uri);


        // Extract extra data for care derived field
        buf = tbx_buf_reset(buf);
        if (mcs_smi->oa_invite_imf != NULL) {
            imf_render2buf(buf, mcs_smi->oa_invite_imf);

            // Get User-Agent info
            tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_user_agent, 0);
            if (strlen(tmpPtr) > 0) {
                SBUG_SOME("User agent [%s]", tmpPtr);
                sprintf(tmp_str, "User-Agent: %s.", tmpPtr);
            }

            // Uuid from Contact
            tmpPtr = NULL;
            tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
            if (strlen(tmpPtr) > 0) {
                SBUG_SOME("Contact [%s]", tmpPtr);
                tokBuf = RESTRDUP(tokBuf, tmpPtr);
                if ((tokStr = strstr(tokBuf, "uuid:")) != NULL) {

                    if ((uuid = strtok(tokStr, ">\"")) != NULL)
                    {
                        SBUG_SOME("Uuid [%s]", &uuid[5]);
                        strncat(tmp_str, " Uuid: ", (sizeof(tmp_str) - strlen(tmp_str)) );
                        strncat(tmp_str, &uuid[5], (sizeof(tmp_str) - strlen(tmp_str)) );
                    }
                }
            }

            tmpPtr = NULL;
            tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_route_num, 0);
            if (strlen(tmpPtr) > 0) {
                SBUG_SOME("Route [%s]", tmpPtr);
                strncat(tmp_str, " Route: ", (sizeof(tmp_str) - strlen(tmp_str)) );
                strncat(tmp_str, tmpPtr, (sizeof(tmp_str) - strlen(tmp_str)) );
                strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
            }

            tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_rec_route_num, 0);
            if (strlen(tmpPtr) > 0) {
                SBUG_SOME("Record Route [%s]", tmpPtr);
                strncat(tmp_str, " Record-Route: ", (sizeof(tmp_str) - strlen(tmp_str)) );
                strncat(tmp_str, tmpPtr, (sizeof(tmp_str) - strlen(tmp_str)) );
                strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
            }

            tmpPtr = NULL;
            tmpPtr = imf_hdr_get(mcs_smi->oa_invite_imf, corrib_sip_ihd_proxy_authorization, 0);
            if (strlen(tmpPtr) > 0) {
                SBUG_SOME("Proxy-Authorization [%s]", tmpPtr);
                strncat(tmp_str, " Proxy-Authorization: ", (sizeof(tmp_str) - strlen(tmp_str)) );
                strncat(tmp_str, tmpPtr, (sizeof(tmp_str) - strlen(tmp_str)) );
                strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
            }
        }

        buf = tbx_buf_reset(buf);
        if (mcs_smi->refer_imf != NULL) {
            imf_render2buf(buf, mcs_smi->refer_imf);
            SBUG_SOME("refer_imf [%s]", (char*)tbx_buf_read_ptr(buf));
        }
        // end
 
        mas_populate_addr(crb_req, 
                          mcs_smi->oa_user_tel_uri,
                          mcs_smi->oa_user_sip_uri,
                          1);
        mas_populate_addr(crb_req, 
                          mcs_smi->da_user_tel_uri,
                          mcs_smi->da_user_sip_uri,
                          0);
        crb_req->qsr_msg.submission_time = tbx_time();

        // Try this for msg id, will sub_time be unique under load ?
        crb_req->qsr_msg.msgid.str = RESTRDUP(crb_req->qsr_msg.msgid.str,
                tbx_qsprintf("%s.%d", crb_req->qsr_msg.oa.addr,
            crb_req->qsr_msg.submission_time));
        SBUG_SOME("Msgid [%s]", crb_req->qsr_msg.msgid.str);

        // For care msg type, will non-empty resource-list always be for group ?
        if (mcs_smi->invite_resource_list != NULL) {
            if (strlen(mcs_smi->invite_resource_list) > 0) {
                crb_req->req_type = CRB_RCS_GROUP_CHAT_JOIN;
                crb_req->qsr_msg.type = CRB_RCS_GROUP_CHAT_JOIN;
                tron_req_type->val = CRB_RCS_GROUP_CHAT_JOIN;
                SBUG_SOME("Group chat join");
            }
            else {
                crb_req->req_type = chat_type;
                crb_req->qsr_msg.type = chat_type;
                tron_req_type->val = chat_type;
                SBUG_SOME("Single chat begin, type [%d]", chat_type);
            }
        }
        else {
            crb_req->req_type = chat_type;
            crb_req->qsr_msg.type = chat_type;
            tron_req_type->val = chat_type;
            SBUG_SOME("Single chat begin, type [%d]", chat_type);
        }
        SBUG_SOME("Tron value [%d]", tron_req_type->val);

        if(bvm_td_add_ntl_integer_req_type(tron_data, tron_req_type) != 0) {
            tron_common_report_add_fail("Message Request Type",
                                        __FILE__,
                                        __LINE__);
        }

        crb_req->qsr_msg.orig_locn = RESTRDUP(crb_req->qsr_msg.orig_locn,
                mcs_smi->oa_user_sip_uri);
        crb_req->qsr_msg.dest_locn = RESTRDUP(crb_req->qsr_msg.dest_locn,
                mcs_smi->da_user_sip_uri);

        // Tmp trace for checking value - remove if not being used
        if (mcs_smi->oa_scscf_sip_uri != NULL) {
            SBUG_SOME("oa_scscf_sip_uri [%s]", mcs_smi->oa_scscf_sip_uri);
        }
        if (mcs_smi->invite_resource_list != NULL) {
            SBUG_SOME("invite_resource_list [%s]", mcs_smi->invite_resource_list);
        }

        if (strlen(tmp_str) > 0) {

            if ((ims_data_ptr = ims_data_alloc()) == NULL) {
                SBUG_SOME("ERROR: Failed to alloc ims data info");
                tron_common_report_add_fail("Ims alloc data", __FILE__, __LINE__);
                tron_data_release(tron_data);
                crb_req_release(crb_req);
                return;
            }

            ims_data_ptr->data1 = RESTRDUP(ims_data_ptr->data1, tmp_str);

            int res = 0;
            if ((res = bvm_td_add_ims_data_ims_data(tron_data, ims_data_ptr)) != 0) {
                SBUG_SOME("ERROR: Failed to add ims start chat info to tron data");
                tron_common_report_add_fail("Care start chat", __FILE__, __LINE__);
                tron_data_release(tron_data);
                crb_req_release(crb_req);
                ims_data_release(ims_data_ptr);
                return;
            }
        }

        if (bvm_td_add_qsr_msg_msg(tron_data, &crb_req->qsr_msg) != 0) {
            tron_common_report_add_fail("Qsr Msg",
                                        __FILE__,
                                        __LINE__);
        }

        if(bvm_td_add_ntl_string_thread_id(tron_data,
                                           tron_thread_id) != 0){
            tron_common_report_add_fail("Thread Identifier",
                                        __FILE__,
                                        __LINE__);
        }

        str = tron_data_dump(str, "Chat start Tron data", tron_data);
        SBUG_SOME("Sending tron_emit start dump: %s", tbx_strget(str));

        if (mcs_smi->is_mo > 0) {
            SBUG_SOME("Sending tron_emit chat mo start (success)");
            tron_rcs_mo_start_chat_success_emit(tron_data);
        }
        else {
            SBUG_SOME("Sending tron_emit chat mt start (success)");
            tron_rcs_mt_start_chat_success_emit(tron_data);
        }
        tron_data_release(tron_data);
        crb_req_release(crb_req);
        ntl_integer_release(tron_req_type);
        ims_data_release(ims_data_ptr);
    }
}

static void send_cancel_cb(struct imf *res_imf,
                           void *cbarg)
{
    struct mcs_state_machine_instance *mcs_smi = (struct mcs_state_machine_instance *) cbarg;
    mcs_smi_decref(mcs_smi);
}

void mcs_ac_cancel_outleg_invite_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->da_invite_interim_res_imf != NULL){
        mcs_smi_incref(mcs_smi);
        corrib_sip_send_cancel(mas_crb_hndl,
                               send_cancel_cb,
                               mcs_smi,
                               mcs_smi->gw_dlg_assoc->dlg,
                               mcs_smi->da_invite_imf,
                               NULL);
    }
    else{
        SBUG_SOME("Cannot send Cancel, no interim message recieved");
    }
}

void mcs_ac_check_is_group_chat_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if (mcs_smi->is_group_chat_leg){
        SBUG_SOME("This is a group chat leg");
        mcs_ev_is_group_chat(mcs_smi->id);
    }
    else{
        SBUG_SOME("This is a 1-1 chat");
        mcs_ev_not_group_chat(mcs_smi->id);
    }
}

void group_chat_leg_teardown_timer_expired_event_cb(void *cb)
{
    struct mcs_state_machine_instance *mcs_smi = cb;
    SBUG_SOME("This group chat is terminating");
    mcs_smi->group_chat_leg_teardown_timer_expired_event = NULL;
    mcs_ev_group_chat_leg_teardown_timer_expired(mcs_smi->id);
}

void mcs_ac_start_group_chat_leg_teardown_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    SBUG_SOME("Starting Group Chat Leg Terminate timer");
    if(mcs_smi->group_chat_leg_teardown_timer_expired_event){
        tbx_cancel_event(mcs_smi->group_chat_leg_teardown_timer_expired_event);
    }
    mcs_smi->group_chat_leg_teardown_timer_expired_event = tbx_queue_event(GROUP_CHAT_LEG_TEARDOWN_TIMER_SECS*1000, 
                                                                           group_chat_leg_teardown_timer_expired_event_cb, 
                                                                           mcs_smi);
}

static void nack_msg(struct crb_req *msg_store_crb_req, 
                     struct core_routing_bus_req_cons_state *msg_store_crb_state,
                     struct ims_handoff_bus_req_cons_state *msg_store_handoff_req_state)
{
    struct crb_res *crb_res = NULL;
    struct qsr_forward_error *qfe = NULL;

    qfe = qsr_forward_error_alloc();
    qfe->i_error.type = qfe->o_error.type = EDAM_ERROR_TYPE_INTERNAL;
    qfe->i_error.value = qfe->o_error.value = INTERNAL_TEMP_MEDIUM_TERM;

    crb_res = mas_crb_res_from_req(msg_store_crb_req,
                                   CRB_RTYPE_EMPTY,
                                   qfe);

    if(msg_store_crb_state){
        crb_consumer_consumed_fail(msg_store_crb_state,
                                   crb_res,
                                   qfe);
    }
    else {
        imdx_ims_handoff_bus_consumer_consumed_fail(msg_store_handoff_req_state,
                                                    crb_res,
                                                    qfe);
    }

    crb_res_release(crb_res);
    qsr_forward_error_release(qfe);
}

void mcs_ac_nack_message_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mcs_smi->msg_store_crb_state == NULL &&
       mcs_smi->msg_store_handoff_req_state == NULL){
        return;
    }
    nack_msg(mcs_smi->msg_store_crb_req,
             mcs_smi->msg_store_crb_state,
             mcs_smi->msg_store_handoff_req_state);
    mcs_smi->msg_store_crb_state = NULL;
    mcs_smi->msg_store_handoff_req_state = NULL;
    crb_req_release(mcs_smi->msg_store_crb_req);
    mcs_smi->msg_store_crb_req = NULL;
}

void mcs_ac_maybe_nack_all_messages_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct mcs_for_delivery *for_dlv;

    if(mcs_smi->msg_store_crb_req &&
       (mcs_smi->msg_store_crb_state != NULL || 
       mcs_smi->msg_store_handoff_req_state != NULL)){
        nack_msg(mcs_smi->msg_store_crb_req,
                 mcs_smi->msg_store_crb_state,
                 mcs_smi->msg_store_handoff_req_state);
        mcs_smi->msg_store_crb_state = NULL;
        mcs_smi->msg_store_handoff_req_state = NULL;
        crb_req_release(mcs_smi->msg_store_crb_req);
        mcs_smi->msg_store_crb_req = NULL;
    }

    if(mcs_smi->for_delivery_list){
        for(for_dlv = LLNEXT(mcs_smi->for_delivery_list);
            for_dlv != mcs_smi->for_delivery_list;
            for_dlv = LLNEXT(mcs_smi->for_delivery_list)){
            LLREMOVE(for_dlv);
            nack_msg(for_dlv->msg_store_crb_req,
                     for_dlv->msg_store_crb_state, 
                     for_dlv->msg_store_handoff_req_state);
            crb_req_release(for_dlv->msg_store_crb_req);
            FREE(for_dlv);
        }
    }

}

void mcs_ac_maybe_ack_message_fn(struct mcs_state_machine_instance *mcs_smi)
{
    struct crb_res *crb_res = NULL;

    if(mcs_smi->da_invite_interim_return_code != 180 ||
       (mcs_smi->msg_store_crb_req && CRB_MSG_TYPE_MASK) == CRB_RCS_MT_FT ||
       (mcs_smi->msg_store_crb_req && CRB_MSG_TYPE_MASK) == CRB_RCS_MO_FT ||
       (mcs_smi->msg_store_crb_state == NULL &&
        mcs_smi->msg_store_handoff_req_state == NULL)){
        // No need to ack message.
        SBUG_SOME("No Need to ACK Message\n");
        return;
    }

    crb_res = mas_crb_res_from_req(mcs_smi->msg_store_crb_req,
                                   CRB_RTYPE_EMPTY,
                                   NULL);

    if(mcs_smi->msg_store_crb_state){
        crb_consumer_consumed_ok(mcs_smi->msg_store_crb_state,
                                 crb_res);
        mcs_smi->msg_store_crb_state = NULL;
    }
    else {
        imdx_ims_handoff_bus_consumer_consumed_ok(mcs_smi->msg_store_handoff_req_state,
                                                  crb_res);
        mcs_smi->msg_store_handoff_req_state = NULL;
    }

    crb_req_release(mcs_smi->msg_store_crb_req);
    mcs_smi->msg_store_crb_req = NULL;
    crb_res_release(crb_res);
}

void mcs_ac_record_msg_fn(struct mcs_state_machine_instance *smi)
{
    // Dummy... doing nothing
    // Message already in for_delivery_list
}

static int group_chat_is_unclean_bye(struct mcs_state_machine_instance *smi)
{
    SBUG_SOME("Reason %s\n", smi->da_bye_reason);
    if(smi->da_bye_reason != NULL &&
       strstr(smi->da_bye_reason, "cause=200") != NULL){
        SBUG_SOME("Call Completed... User has left group chat\n");
        return 0;
    }

    return 1;
}

void mcs_ac_group_chat_continue_check_fn(struct mcs_state_machine_instance *smi)
{
    int gc_basic_standfw = 0;
    int gc_full_standfw = 0;

    if(smi->is_group_chat_leg){

        fletch_get_feature(FLETCH_IMS_GROUP_CHAT_FULL_STANDFW, &gc_full_standfw);
        fletch_get_feature(FLETCH_IMS_GROUP_CHAT_BASIC_STANDFW, &gc_basic_standfw);

        if(group_chat_is_unclean_bye(smi) && 
           (gc_full_standfw || gc_basic_standfw)){
            SBUG_SOME("Continuing Group Chat Leg\n");
            mcs_ev_group_chat_continue(smi->id);
        }
        else {
            SBUG_SOME("Group Chat Leg Continue Hangup\n");
            mcs_ev_continue_hangup(smi->id);
        }
    }
    else {
        SBUG_SOME("1-1 Chat Continue Hangup\n");
        mcs_ev_continue_hangup(smi->id);
    }
}

static void gcl_alert_cb(void *cbarg,
                         int success,
                         struct crb_res *crb_res,
                         struct qsr_forward_error *qfe)
{
    SBUG_SOME("Alert %s\n", (success == 1) ? "Succeeded" : "Failed");
}

void mcs_ac_alert_stored_messages_fn(struct mcs_state_machine_instance *smi)
{
    char *addr;
    int ton, npi;
    int rc;

    if(smi->da_user_tel_uri){
        addr = smi->da_user_tel_uri;
        ton = npi = 1;
    }
    else {
        addr = smi->da_user_sip_uri;
        ton = 99;
        npi = 0;
    }
    SBUG_SOME("Sending Alert for key %s\n", addr);
    rc = crb_app_send_alert(mas_crb_hndl,
                            "GROUP CHAT LEG ALERT",
                            NULL,
                            ton,
                            npi,
                            addr,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            gcl_alert_cb,
                            smi);
    if(rc != 0){
        SBUG_SOME("Send Alert failed\n");
    }
}

void mcs_ac_restart_chat_fn(struct mcs_state_machine_instance *smi)
{
    if(smi->routing_id){
        // Remove routing id to avoid clash
        // with reinvite
        remove_group_chat_leg_uri_id(smi->routing_id);
        FREE(smi->routing_id);
        smi->routing_id = NULL;
    }
    mas_restart_chat(smi);
}

void mcs_ac_check_reinvite_ready_fn(struct mcs_state_machine_instance *smi)
{
    if (smi->da_msrp_session == NULL ||
        smi->reinviting){
       mcs_ev_reinvite_ready(smi->id);
    }
    else {
       mcs_ev_reinvite_not_ready(smi->id);
    }
}

static void mcs_msrp_conn_avail_timeout_cb(void *cb)
{
    struct mcs_state_machine_instance *mcs_smi = cb;
    SBUG_SOME("MSRP Connection has not become available in %d seconds", gv_ims_settings->accept_session_timeout);
    mcs_smi->msrp_avail_event = NULL;
    mcs_ev_msrp_avail_timeout(mcs_smi->id);
}
void mcs_ac_start_msrp_avail_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mcs_smi->msrp_avail_event){
        tbx_cancel_event(mcs_smi->msrp_avail_event);
    }
    mcs_smi->msrp_avail_event = tbx_queue_event(gv_ims_settings->accept_session_timeout*1000, 
                                                mcs_msrp_conn_avail_timeout_cb, 
                                                mcs_smi);
}

void mcs_ac_stop_msrp_avail_timer_fn(struct mcs_state_machine_instance *mcs_smi)
{
    if(mcs_smi->msrp_avail_event){
        tbx_cancel_event(mcs_smi->msrp_avail_event);
        mcs_smi->msrp_avail_event = NULL;
    }
}

void mcs_ac_orphan_gw_dialog_fn(struct mcs_state_machine_instance *smi)
{
    struct corrib_sip_dialog *dlg;

    if(smi->gw_dlg_assoc){
        dlg = smi->gw_dlg_assoc->dlg;
        if(dlg){
            dlg->cbarg = NULL;
        }
        ims_call_id_erase(mas_prep_call_id(smi->gw_dlg_assoc->dlg->call_id,
                                           smi->app_server));
        smi->gw_dlg_assoc->dlg = NULL;
        mas_sm_dlg_assoc_release(smi->gw_dlg_assoc);
        smi->gw_dlg_assoc = NULL;
    }
}

void mcs_ac_terminate_fn(struct mcs_state_machine_instance *smi)
{
    int now, age;
    struct crb_req *crb_req = NULL;
    struct tron_data *tron_data = NULL;
    struct ntl_integer *tron_req_type = NULL;
    struct ntl_string *tron_thread_id = NULL;
    int chat_type = CRB_RCS_MO_CHAT_END;
    struct mas_chat_msg *mas_chat_msg;
    char tmp_str[1024];
    static struct tbx_buffer *buf = NULL;
    const char *tmpPtr = NULL;
    static char *tokBuf = NULL;
    struct mcs_subscribe_state *subscribe_state;

    // Tron
    // either it's the end of an existing chat
    // or a failed chat
    // smi->routing_id_registered will have been set
    // for a registered chat        
    crb_req = crb_req_alloc();
    tron_data = tron_data_alloc();
    tron_req_type = ntl_integer_alloc();

    tron_thread_id = tron_common_make_ntl_string(smi->routing_id);

    // store session in IMAP
    // for now user and password is OA's tel/sip URI

    // check for file transfer, else 1:1 chat
    if (smi->oa_offered_msd->file_transfer_id &&
        strlen(smi->oa_offered_msd->file_transfer_id)) {
        // file transfer
        mas_imap_store_file_transfer(strlen(smi->oa_user_tel_uri) ? smi->oa_user_tel_uri : smi->oa_user_sip_uri,
                                     strlen(smi->oa_user_tel_uri) ? smi->oa_user_tel_uri : smi->oa_user_sip_uri,
                                     smi->oa_conversation_id,
                                     smi->oa_contribution_id,
                                     NULL, // in-reply-to-contribution-id FIXME
                                     strlen(smi->oa_user_tel_uri) ? smi->oa_user_tel_uri : smi->oa_user_sip_uri,
                                     strlen(smi->da_user_tel_uri) ? smi->da_user_tel_uri : smi->da_user_sip_uri,
                                     smi->creation_time,
                                     smi->oa_sdp,
                                     NULL, // No file data
                                     0, // no file data FIXME FIXME
                                     smi->oa_offered_msd->file_type,
                                     smi->oa_offered_msd->file_name,
                                     smi->oa_offered_msd->file_disposition);
    }
    else {
        // 1:1 chat
        mas_imap_store_chat_session(strlen(smi->oa_user_tel_uri) ? smi->oa_user_tel_uri : smi->oa_user_sip_uri,
                                    strlen(smi->oa_user_tel_uri) ? smi->oa_user_tel_uri : smi->oa_user_sip_uri,
                                    smi->oa_conversation_id,
                                    smi->oa_contribution_id,
                                    NULL, // in-reply-to-contribution-id FIXME
                                    strlen(smi->oa_user_tel_uri) ? smi->oa_user_tel_uri : smi->oa_user_sip_uri,
                                    strlen(smi->da_user_tel_uri) ? smi->da_user_tel_uri : smi->da_user_sip_uri,
                                    smi->creation_time,
                                    smi->subject,
                                    smi->oa_sdp,
                                    smi->chat_msg_history,
                                    smi->group_chat_members,
                                    smi->group_chat_uri);
    }

    for(mas_chat_msg = LLNEXT(smi->chat_msg_history);
        mas_chat_msg != smi->chat_msg_history;
        mas_chat_msg = LLNEXT(smi->chat_msg_history)){
        LLREMOVE(mas_chat_msg);
        mas_chat_msg_release(mas_chat_msg);
    }
    mas_chat_msg_release(smi->chat_msg_history);
    smi->chat_msg_history = NULL;

    if(smi->oa_contribution_id){
        SBUG_SOME("oa_contribution_id [%s]", smi->oa_contribution_id);
    }
    if(smi->oa_conversation_id){
        SBUG_SOME("oa_conversation_id [%s]", smi->oa_conversation_id);
    }

    if (smi->invite_resource_list != NULL) {
        SBUG_SOME("Chat End - Resource list [%s]", smi->invite_resource_list);
    }

    if (smi->group_chat_members) {
        mgcs_member_release_list(smi->group_chat_members);
        smi->group_chat_members = NULL;
    }

    memset(tmp_str, 0, sizeof(tmp_str));
    buf = tbx_buf_reset(buf);

    if (smi->oa_invite_imf != NULL) {
        imf_render2buf(buf, smi->oa_invite_imf);

        // Get User agent info
        tmpPtr = imf_hdr_get(smi->oa_invite_imf, corrib_sip_ihd_user_agent, 0);
        if (strlen(tmpPtr) > 0) {
            SBUG_SOME("User agent [%s]", tmpPtr);
            sprintf(tmp_str, "User-Agent: %s.", tmpPtr);
        }

        // Uuid from Contact
        tmpPtr = NULL;
        tmpPtr = imf_hdr_get(smi->oa_invite_imf, corrib_sip_ihd_contact_num, 0);
        if (strlen(tmpPtr) > 0) {
            SBUG_SOME("Contact [%s]", tmpPtr);
            tokBuf = RESTRDUP(tokBuf, tmpPtr);
            char *tokStr = NULL;
            if ((tokStr = strstr(tokBuf, "uuid:")) != NULL) {

                SBUG_SOME("Uuid [%s]", tokStr);
                char *uuid = NULL;
                if ((uuid = strtok(tokStr, ">\"")) != NULL)
                {
                    SBUG_SOME("Uuid [%s]", &uuid[5]);
                    strncat(tmp_str, " Uuid: ", (sizeof(tmp_str) - strlen(tmp_str)) );
                    strncat(tmp_str, &uuid[5], (sizeof(tmp_str) - strlen(tmp_str)) );
                    strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
                }
            }
        }

        tmpPtr = NULL;
        tmpPtr = imf_hdr_get(smi->oa_invite_imf, corrib_sip_ihd_route_num, 0);
        if (strlen(tmpPtr) > 0) {
            SBUG_SOME("Route [%s]", tmpPtr);
            strncat(tmp_str, " Route: ", (sizeof(tmp_str) - strlen(tmp_str)) );
            strncat(tmp_str, tmpPtr, (sizeof(tmp_str) - strlen(tmp_str)) );
            strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
        }

        tmpPtr = NULL;
        tmpPtr = imf_hdr_get(smi->oa_invite_imf, corrib_sip_ihd_rec_route_num, 0);
        if (strlen(tmpPtr) > 0) {
            SBUG_SOME("Record-Route [%s]", tmpPtr);
            strncat(tmp_str, " Record-Route: ", (sizeof(tmp_str) - strlen(tmp_str)) );
            strncat(tmp_str, tmpPtr, (sizeof(tmp_str) - strlen(tmp_str)) );
            strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
        }

        tmpPtr = NULL;
        tmpPtr = imf_hdr_get(smi->oa_invite_imf, corrib_sip_ihd_proxy_authorization, 0);
        if (strlen(tmpPtr) > 0) {
            SBUG_SOME("Proxy-Authorization [%s]", tmpPtr);
            strncat(tmp_str, " Proxy-Authorization: ", (sizeof(tmp_str) - strlen(tmp_str)) );
            strncat(tmp_str, tmpPtr, (sizeof(tmp_str) - strlen(tmp_str)) );
            strncat(tmp_str, ".", (sizeof(tmp_str) - strlen(tmp_str)) );
        }
    }

    mas_populate_addr(crb_req, 
                      smi->oa_user_tel_uri,
                      smi->oa_user_sip_uri,
                      1);
    mas_populate_addr(crb_req, 
                      smi->da_user_tel_uri,
                      smi->da_user_sip_uri,
                      0);
    crb_req->qsr_msg.submission_time = tbx_time();

    // Try this for msg id, will sub_time be unique under load ?
    crb_req->qsr_msg.msgid.str = RESTRDUP(crb_req->qsr_msg.msgid.str,
                                          (char *)tbx_qsprintf("%s.%d", crb_req->qsr_msg.oa.addr,
                                                               crb_req->qsr_msg.submission_time));
    SBUG_SOME("Msg str [%s]", crb_req->qsr_msg.msgid.str);
    SBUG_SOME("Oa [%s] Da [%s]", crb_req->qsr_msg.oa.addr, crb_req->qsr_msg.da.addr);

    // Can't see error params in tron_data...
    if (!smi->routing_id_registered) {
        crb_req->qsr_msg.error.i_error.type = EDAM_ERROR_TYPE_INTERNAL;
        crb_req->qsr_msg.error.i_error.value = INTERNAL_INVALID_MESSAGE;
        crb_req->qsr_msg.error.o_error.type = EDAM_ERROR_TYPE_SIP;
        crb_req->qsr_msg.error.o_error.value = 500;
        SBUG_SOME("No routing id, set o error to [%d]",
                  crb_req->qsr_msg.error.o_error.value);
    }

    if (smi->is_mo <= 0) {
        chat_type = CRB_RCS_MT_CHAT_END;
        SBUG_SOME("MT chat end");
    }

    if (smi->invite_resource_list != NULL) {
        if (strlen(smi->invite_resource_list) > 0) {
            crb_req->qsr_msg.type = CRB_RCS_GROUP_CHAT_LEAVE;
            crb_req->req_type = CRB_RCS_GROUP_CHAT_LEAVE;
            tron_req_type->val = CRB_RCS_GROUP_CHAT_LEAVE;
            SBUG_SOME("Group chat leave");
        }
        else {
            crb_req->qsr_msg.type = chat_type;
            crb_req->req_type = chat_type;
            tron_req_type->val = chat_type;
            SBUG_SOME("Single chat end");
        }
    }
    else {
        crb_req->qsr_msg.type = chat_type;
        tron_req_type->val = chat_type;
        crb_req->req_type = chat_type;
        SBUG_SOME("Single chat end");
    }
    SBUG_SOME("Crb_req req_type [%d] tron val [%d]", crb_req->req_type, tron_req_type->val);

    if(bvm_td_add_ntl_integer_req_type(tron_data, tron_req_type) != 0) {
        tron_common_report_add_fail("Message Request Type",
                                    __FILE__,
                                    __LINE__);
    }

    // Tmp trace for checking value - remove if not being used
    if (smi->oa_scscf_sip_uri != NULL) {
        SBUG_SOME("oa_scscf_sip_uri [%s]", smi->oa_scscf_sip_uri);
    }
    if (smi->invite_resource_list != NULL) {
        SBUG_SOME("invite_resource_list [%s]", smi->invite_resource_list);
    }
    if (smi->oa_referred_by != NULL) {
        SBUG_SOME("oa_referred_by [%s]", smi->oa_referred_by);
    }
    if (smi->remote_path != NULL) {
        SBUG_SOME("remote_path [%s]", smi->remote_path);
    }

    // Could this be used in tron/care gui ?
    SBUG_SOME("Session state [%d]", smi->state);

    if (bvm_td_add_qsr_msg_msg(tron_data, &crb_req->qsr_msg) != 0) {
        tron_common_report_add_fail("Qsr Msg",
                                    __FILE__,
                                    __LINE__);
    }

    if(bvm_td_add_ntl_string_thread_id(tron_data,
                                       tron_thread_id) != 0){
        tron_common_report_add_fail("Thread Identifier",
                                    __FILE__,
                                    __LINE__);
    }

    // Add any extra if present
    struct ims_data *ims_data_ptr = NULL;
    if (strlen(tmp_str) > 0) {

        if ((ims_data_ptr = ims_data_alloc()) == NULL) {
            SBUG_SOME("ERROR: Failed to alloc ims REGISTER info");
            tron_common_report_add_fail("Ims alloc REGISTER", __FILE__, __LINE__);
            tron_data_release(tron_data);
            crb_req_release(crb_req);
            return;
        }
        ims_data_ptr->data1 = RESTRDUP(ims_data_ptr->data1, tmp_str);

        int res = 0;
        if ((res = bvm_td_add_ims_data_ims_data(tron_data, ims_data_ptr)) != 0) {
            SBUG_SOME("ERROR: Failed to add ims end chat info to tron data");
            tron_common_report_add_fail("Care end chat", __FILE__, __LINE__);
            tron_data_release(tron_data);
            crb_req_release(crb_req);
            ims_data_release(ims_data_ptr);
            return;
        }
        SBUG_SOME("Added extra ims data [%s]", tmp_str);
    }

    struct tbx_string *str = NULL;
    str = tron_data_dump(str, "Chat end Tron data", tron_data);
    SBUG_SOME("Chat end Tron dump: %s", tbx_strget(str));

    if (smi->routing_id_registered) {
        if (smi->is_mo > 0) {
            SBUG_SOME("Sending tron_emit chat mo end (success)");
            tron_rcs_mo_end_chat_emit(tron_data);
        }
        else {
            SBUG_SOME("Sending tron_emit chat mt end (success)");
            tron_rcs_mt_end_chat_emit(tron_data);
        }
    }
    else {
        if (smi->is_mo > 0) {
            SBUG_SOME("Sending tron_emit mo start chat failure");
            tron_rcs_mo_start_chat_failure_emit(tron_data);
        }
        else {
            SBUG_SOME("Sending tron_emit mt start chat failure");
            tron_rcs_mt_start_chat_failure_emit(tron_data);
        }
    }

    if(tron_data) tron_data_release(tron_data);
    if(crb_req) crb_req_release(crb_req);
    if(tron_req_type) ntl_integer_release(tron_req_type);
    if(ims_data_ptr) ims_data_release(ims_data_ptr);
    // end of tron stage

    if(smi->oa_device){
        FREE(smi->oa_device);
        smi->oa_device = NULL;
    }

    if(smi->da_device){
        FREE(smi->da_device);
        smi->da_device = NULL;
    }

    if(smi->contact_uri){
        if(smi->is_group_chat_leg){
            remove_group_chat_leg_uri_id(smi->contact_uri);
        }

        FREE(smi->contact_uri);
        smi->contact_uri = NULL;
    }

    if(smi->oa_invite_crb_req){
        crb_req_release(smi->oa_invite_crb_req);
        smi->oa_invite_crb_req = NULL;
    }
    if(smi->reinvite_invite_crb_req){
        crb_req_release(smi->reinvite_invite_crb_req);
        smi->reinvite_invite_crb_req = NULL;
    }

    if(smi->subscribe_list){
        for(subscribe_state = LLNEXT(smi->subscribe_list);
            subscribe_state != smi->subscribe_list;
            subscribe_state = LLNEXT(smi->subscribe_list)){

            LLREMOVE(subscribe_state);

            mcs_subscribe_state_release(subscribe_state);
        }

        FREE(smi->subscribe_list);
    }

    if(smi->notify_crb_req){
        crb_req_release(smi->notify_crb_req);
        smi->notify_crb_req = NULL;
    }

    if(smi->msg_store_crb_req){
        crb_req_release(smi->msg_store_crb_req);
        smi->msg_store_crb_req = NULL;
    }

    if(smi->oa_invite_imf){
        imf_release(smi->oa_invite_imf);
        smi->oa_invite_imf = NULL;
    }

    if(smi->reinvite_invite_imf){
        imf_release(smi->reinvite_invite_imf);
        smi->reinvite_invite_imf = NULL;
    }
    if(smi->notify_imf){
        imf_release(smi->notify_imf);
        smi->notify_imf = NULL;
    }

    if(smi->oa_invite_res_imf){
        imf_release(smi->oa_invite_res_imf);
        smi->oa_invite_res_imf = NULL;
    }

    if(smi->iw_dlg_assoc){
        if(smi->iw_dlg_assoc->dlg){
            ims_call_id_erase(mas_prep_call_id(smi->iw_dlg_assoc->dlg->call_id,
                                               smi->app_server));
            corrib_sip_dialog_release(smi->iw_dlg_assoc->dlg);
            smi->iw_dlg_assoc->dlg = NULL;
        }
        mas_sm_dlg_assoc_release(smi->iw_dlg_assoc);
        smi->iw_dlg_assoc = NULL;
    }

    if(smi->reinvite_dlg_assoc){
        if(smi->reinvite_dlg_assoc->dlg){
            corrib_sip_dialog_release(smi->reinvite_dlg_assoc->dlg);
            smi->reinvite_dlg_assoc->dlg = NULL;
        }
        mas_sm_dlg_assoc_release(smi->reinvite_dlg_assoc);
        smi->reinvite_dlg_assoc = NULL;
    }

    if(smi->da_invite_crb_req){
        crb_req_release(smi->da_invite_crb_req);
        smi->da_invite_crb_req = NULL;
    }

    if(smi->da_invite_imf){
        imf_release(smi->da_invite_imf);
        smi->da_invite_imf = NULL;
    }

    if(smi->da_invite_interim_res_imf){
        imf_release(smi->da_invite_interim_res_imf);
        smi->da_invite_interim_res_imf = NULL;
    }

    if(smi->da_invite_res_imf){
        imf_release(smi->da_invite_res_imf);
        smi->da_invite_res_imf = NULL;
    }

    if(smi->gw_dlg_assoc){

        if(smi->gw_dlg_assoc->dlg){
            ims_call_id_erase(mas_prep_call_id(smi->gw_dlg_assoc->dlg->call_id,
                                               smi->app_server));
            corrib_sip_dialog_release(smi->gw_dlg_assoc->dlg);
            smi->gw_dlg_assoc->dlg = NULL;
        }
        mas_sm_dlg_assoc_release(smi->gw_dlg_assoc);
        smi->gw_dlg_assoc = NULL;
    }

    if(smi->remote_path){
        FREE(smi->remote_path);
        smi->remote_path = NULL;
    }

    if(smi->oa_user_sip_uri){
        FREE(smi->oa_user_sip_uri);
        smi->oa_user_sip_uri = NULL;
    }

    if(smi->oa_referred_by){
        FREE(smi->oa_referred_by);
        smi->oa_referred_by = NULL;
    }

    if(smi->oa_user_tel_uri){
        FREE(smi->oa_user_tel_uri);
        smi->oa_user_tel_uri = NULL;
    }

    if(smi->oa_scscf_sip_uri){
        FREE(smi->oa_scscf_sip_uri);
        smi->oa_scscf_sip_uri = NULL;
    }

    if(smi->oa_contribution_id){
        FREE(smi->oa_contribution_id);
        smi->oa_contribution_id = NULL;
    }

    if(smi->oa_conversation_id){
        FREE(smi->oa_conversation_id);
        smi->oa_conversation_id = NULL;
    }

    if(smi->routing_id){
        remove_group_chat_leg_uri_id(smi->routing_id);
        FREE(smi->routing_id);
        smi->routing_id = NULL;
    }

    if(smi->da_user_sip_uri){
        FREE(smi->da_user_sip_uri);
        smi->da_user_sip_uri = NULL;
    }

    if(smi->da_user_tel_uri){
        FREE(smi->da_user_tel_uri);
        smi->da_user_tel_uri = NULL;
    }

    if(smi->oa_sdp){
        FREE(smi->oa_sdp);
        smi->oa_sdp = NULL;
    }

    if(smi->da_sdp){
        FREE(smi->da_sdp);
        smi->da_sdp = NULL;
    }

    if(smi->first_msg){
        imf_release(smi->first_msg);
        smi->first_msg = NULL;
    }

    if(smi->invite_resource_list){
        FREE(smi->invite_resource_list);
        smi->invite_resource_list = NULL;
    }

    if(smi->oa_local_msrp_uri){
        msrp_release_uri(smi->oa_local_msrp_uri);
        smi->oa_local_msrp_uri = NULL;
    }

    if(smi->oa_offered_msd){
        msrp_sdp_details_release(smi->oa_offered_msd);
        smi->oa_offered_msd = NULL;
    }

    if(smi->oa_answered_msrp_setup){
        FREE(smi->oa_answered_msrp_setup);
        smi->oa_answered_msrp_setup = NULL;
    }

    if(smi->da_local_msrp_uri){
        msrp_release_uri(smi->da_local_msrp_uri);
        smi->da_local_msrp_uri = NULL;
    }

    if(smi->da_answered_msd){
        msrp_sdp_details_release(smi->da_answered_msd);
        smi->da_answered_msd = NULL;
    }

    if(smi->oa_msrp_session){
        //Session is released when destroyed, no need to free
        smi->oa_msrp_session = NULL;
    }

    if(smi->da_msrp_session){
        //Session is released when destroyed, no need to free
        smi->da_msrp_session = NULL;
    }

    if(smi->subject){
        FREE(smi->subject);
        smi->subject = NULL;
    }

    if (smi->activity_time_check_event){
        tbx_cancel_event(smi->activity_time_check_event);
        smi->activity_time_check_event = NULL;
    }

    if (smi->msrp_avail_event){
        tbx_cancel_event(smi->msrp_avail_event);
        smi->msrp_avail_event = NULL;
    }
    if (smi->group_chat_leg_teardown_timer_expired_event){
        tbx_cancel_event(smi->group_chat_leg_teardown_timer_expired_event);
        smi->group_chat_leg_teardown_timer_expired_event = NULL;
    }

    if (smi->wait_for_bye_event){
        tbx_cancel_event(smi->wait_for_bye_event);
        smi->wait_for_bye_event = NULL;
    }

    if (smi->oa_bye_reason){
        FREE(smi->oa_bye_reason);
        smi->oa_bye_reason = NULL;
    }

    if (smi->da_bye_reason){
        FREE(smi->da_bye_reason);
        smi->da_bye_reason = NULL;
    }

    if(smi->for_delivery_list){
        FREE(smi->for_delivery_list);
        smi->for_delivery_list = NULL;
    }

    if(smi->refer_list){
        FREE(smi->refer_list);
        smi->refer_list = NULL;
    }
    if(smi->refer_imf){
        imf_release(smi->refer_imf);
        smi->refer_imf = NULL;
    }
    if(smi->scscf_host){
        FREE(smi->scscf_host);
        smi->scscf_host = NULL;
    }
    cstat_gadj(mas_chats, -1);

    // lifetime achievement awards
    // determine age
    now = tbx_time();

    age = now - smi->creation_time;
    SBUG_SOME("Session age:%d.. now:%d, created:%d",
              age,
              now,
              smi->creation_time);
    if (age < 60) {
        cstat_cadj(mas_chat_lifetime_1_60_sec, 1);
    }
    else if (age < 5 * 60) {
        cstat_cadj(mas_chat_lifetime_1_5_min, 1);
    }
    else if (age < 30 * 60) {
        cstat_cadj(mas_chat_lifetime_5_30_min, 1);
    }
    else if (age < 60 * 60) {
        cstat_cadj(mas_chat_lifetime_30_60_min, 1);
    }
    else if (age < 5 * 60 * 60) {
        cstat_cadj(mas_chat_lifetime_1_5_hour, 1);
    }
    else if (age < 10 * 60 * 60) {
        cstat_cadj(mas_chat_lifetime_5_10_hour, 1);
    }
    else if (age < 24 * 60 * 60) {
        cstat_cadj(mas_chat_lifetime_10_24_hour, 1);
    }
    else if (age < 5 * 24 * 60 * 60) {
        cstat_cadj(mas_chat_lifetime_1_5_days, 1);
    }
    else if (age < 10 * 24 * 60 * 60) {
        cstat_cadj(mas_chat_lifetime_5_10_days, 1);
    }
    else {
        cstat_cadj(mas_chat_lifetime_10_days_plus, 1);
    }
}
