#!/usr/bin/env python

# get test result from jenkins job - jenkins http python API

import urllib2
import base64
import os
import sys
import getopt


class report:
    """ class: report set args, call jenkins api to get job test result info, print report """
    def __init__(self):
        #self.baseurl = os.environ['BUILD_URL']
        self.baseurl="http://hp-bl-06.ie.openmindnetworks.com:8086"

        # get jobname from ENV $JOB_NAME should be set
        #jobname="system_test_regression_SMSC_15-Q3_DRIVERhp-bl-06_SUThp-bl-05"
        #self.jobname = os.environ['JOB_NAME']
        #self.jobnum = os.environ['JOB_NUM']
        self.jobname="yellowstone_QA_Staging"
        self.jobnum=0

        self.username="admin"
        self.password="paSSword"

        self.ignorepass = False
        self.debug = 0
        self.showstderr = 0

    def makeReport(self):
        #call api of job
        # ?depth=0  ?pretty=true
        url="%s/job/%s/%s/testReport/api/python" % (self.baseurl,self.jobname,self.jobnum)
        base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
        request = urllib2.Request(url)
        request.add_header("Authorization", "Basic %s" % base64string) 
        result = urllib2.urlopen(request)
        # job dict
        j=eval(result.read())

        # keys of job:
        # failCount suites skipCount empty duration passCount _class testActions
        print "TOTAL test count: pass:%d fail:%d skip:%d" % (j['passCount'],j['failCount'],j['skipCount'])

        oldClassName=""
        suites=j['suites']
        for s in suites:
            for c in s['cases']:
                if self.debug > 2: print "TEST dir:{}".format(dir(c))
                if self.debug > 1: 
                    print "TEST keys:{}".format(c.keys())
                    from pprint import pprint
                    pprint(c,indent=4)

                if c['className'] != oldClassName:
                    if self.debug: print "TEST CLASS: %s" % c['className']
                    oldClassName = c['className']
                skipped = ""
                if c['skipped']:
                    skipped = " SKIP(%s)" % c['skippedMessage']
                if self.debug: print "     TEST RESULT: %s%s NAME: %s" % ( c['status'], skipped, c['name'] )
                #if c['errorDetails']:
                #    if self.debug: print "      ERR: %s" % c['errorDetails']
                #if c['errorStackTrace']:
                #    from pprint import pprint
                #    pprint(c['errorStackTrace'],indent=8)

                if not self.ignorepass or ( c['status'] != "PASSED" and c['status'] != "SKIPPED" ):
                    print "TEST CLASS: %s" % c['className']
                    print "     TEST RESULT: %s%s NAME: %s" % ( c['status'], skipped, c['name'] )
                    if c['errorDetails']:
                        print "      ERR: %s" % c['errorDetails']
                    if self.showstderr>0:
                        if c['stderr']:
                            print "   STDERR: %s" % c['stderr']
                        if self.showstderr>1:
                            if c['stdout']:
                                print "   STDOUT: %s" % c['stdout']
                        
        #keys e.g. of test case:
        #          "testActions" : [],
        #          "age" : 0,
        #          "className" : "SMSC-ipsmgw_regression.TRANSPORTLEVEL",
        #          "duration" : 31.570633,
        #          "errorDetails" : None,
        #          "errorStackTrace" : None,
        #          "failedSince" : 0,
        #          "name" : "test_TRANSPORTLEVEL001b",
        #          "skipped" : False,
        #          "skippedMessage" : None,
        #          "status" : "PASSED",
        #          "stderr" : "stuff",
        #          "stdout" : "loads of stuff"

        """
        $ ./jenkins_show_test_result.py -n 466 -i |less

        TOTAL test count: pass:174 fail:7 skip:77
TEST CLASS: test_container_actions.TestContActions
     TEST RESULT: FIXED NAME: test_oasis_msw
TEST CLASS: test_platform_sanity.SANITY
     TEST RESULT: REGRESSION NAME: test_SANITY_007_hippy_container
      ERR: AssertionError: 'xena_store' not found in '[Running(MONDO)]  6-597e18d7     imdx-1 bin/tc_imdx_server -tbx_priority -20 -imdx-id vanilla-1 -disable-ec-purdy  \n[Running(MONDO)]  6-597e18d7   hammer-1 bin/hammer  \n[Running(MONDO)]  6-597e18d7    oasis-1 bin/oasis  \n[Running(MONDO)]  6-597e18d7  kyssbug-1 bin/kyssbug  \n[Running(MONDO)]  6-597e18d7 cconf_repl-1 bin/cconf_repl_cli  \n[Running(MONDO)]  6-597e18d7 http_srv-1 bin/http_srv  \n[Running(MONDO)]  6-597e18d7   reafer-1 bin/reafer  \n[Running(MONDO)]  6-597e18d7  xantipe-1 bin/xantipe  \n[Running(MONDO)]  6-597e18d7     xena-1 bin/xena  \n[Running(MONDO)]  6-597e18d7  sputnik-1 bin/sputnik  \n[Running(MONDO)]  6-597e18d7  cameron-1 bin/cameron  \n[Running(MONDO)]  6-597e18d7  camelot-1 bin/camelot  \n[Running(MONDO)]  6-597e18cf     imdx-1 bin/tc_imdx_server -tbx_priority -20 -imdx-id vanilla-1 -disable-ec-purdy  \n[Running(MONDO)]  6-597e18cf   hammer-1 bin/hammer  \n[Running(MONDO)]  6-597e18cf    oasis-1 bin/oasis  \n[Running(MONDO)]  6-597e18cf  kyssbug-1 bin/kyssbug  \n[Running(MONDO)]  6-597e18cf cconf_repl-1 bin/cconf_repl_cli  \n[Running(MONDO)]  6-597e18cf http_srv-1 bin/http_srv  \n[Running(MONDO)]  6-597e18cf   reafer-1 bin/reafer  \n[Running(MONDO)]  6-597e18cf  xantipe-1 bin/xantipe  \n[Running(MONDO)]  6-597e18b8     imdx-1 bin/tc_imdx_server -tbx_priority -20 -imdx-id vanilla-1 -disable-ec-purdy  \n[Running(MONDO)]  6-597e18b8   hammer-1 bin/hammer  \n[Running(MONDO)]  6-597e18b8    oasis-1 bin/oasis  \n[Running(MONDO)]  6-597e18b8  kyssbug-1 bin/kyssbug  \n[Running(MONDO)]  6-597e18b8 cconf_repl-1 bin/cconf_repl_cli  \n[Running(MONDO)]  6-597e18b8 http_srv-1 bin/http_srv  \n[Running(MONDO)]  6-597e18b8   reafer-1 bin/reafer  \n[Running(MONDO)]  6-597e18b8  xantipe-1 bin/xantipe  \n[Running(MONDO)]  6-597e18b8     xena-1 bin/xena  \n[Running(MONDO)]  6-597e18b8  sputnik-1 bin/sputnik  \n[Running(MONDO)]  6-597e18b8  cameron-1 bin/cameron  \n[Running(MONDO)]  6-597e18b8  camelot-1 bin/camelot  \n[Running(MONDO)]  6-597e18cf     xena-1 bin/xena  \n[Running(MONDO)]  6-597e18cf  sputnik-1 bin/sputnik  \n[Running(MONDO)]  6-597e18cf  cameron-1 bin/cameron  \n[Running(MONDO)]  6-597e18cf  camelot-1 bin/camelot  \n[Running(MONDO)]  6-597e18c4     imdx-1 bin/tc_imdx_server -tbx_priority -20 -imdx-id vanilla-1 -disable-ec-purdy  \n[Running(MONDO)]  6-597e18c4   hammer-1 bin/hammer  \n[Running(MONDO)]  6-597e18c4    oasis-1 bin/oasis  \n[Running(MONDO)]  6-597e18c4  kyssbug-1 bin/kyssbug  \n[Running(MONDO)]  6-597e18c4 cconf_repl-1 bin/cconf_repl_cli  \n[Running(MONDO)]  6-597e18c4 http_srv-1 bin/http_srv  \n[Running(MONDO)]  6-597e18c4   reafer-1 bin/reafer  \n[Running(MONDO)]  6-597e18c4  xantipe-1 bin/xantipe  \n[Running(MONDO)]  6-597e18c4     xena-1 bin/xena  \n[Running(MONDO)]  6-597e18c4  sputnik-1 bin/sputnik  \n[Running(MONDO)]  6-597e18c4  cameron-1 bin/cameron  \n[Running(MONDO)]  6-597e18c4  camelot-1 bin/camelot  \n\nCommand succeeded\n...6-597e18b8 exit code 0\n...6-597e18d7 exit code 0\n...6-597e18cf exit code 0\n...6-597e18c4 exit code 0'
TEST CLASS: test_protect_smpp.TestAoProtect
     TEST RESULT: REGRESSION NAME: test_ao_mt_protect_trap_oa
      ERR: AssertionError: 0 not greater than 0
TEST CLASS: test_smsc_asteroid_momt_memleak.TestMoMtTraffic
     TEST RESULT: FAILED NAME: test_motraffic_dtod_resilience_direct
      ERR: AssertionError: True is not false
TEST CLASS: test_smsc_segment_reassembly_mt.TestSegmentReassemblyMT
     TEST RESULT: REGRESSION NAME: test_SegmentReassemblyMT006
      ERR: AssertionError: 2 != 1
TEST CLASS: test_spd.TestSPD
     TEST RESULT: FAILED NAME: test_spd_add_record_soap
      ERR: AssertionError: assert 35 == 0  +  where 35 = len('Different number of records: 1 vs 0')
TEST CLASS: test_spd.TestSPD
     TEST RESULT: FAILED NAME: test_spd_mod_record_soap
      ERR: AssertionError: assert 12 == 0  +  where 12 = len('PP=0 != PP=1')
TEST CLASS: test_spd.TestSPD
     TEST RESULT: FAILED NAME: test_spd_query_record_soap
      ERR: AssertionError: assert None is not None

        """

    def usage(msg,status=1):
        print msg
        print "Usage:"
        print "    %s -b <jenkins url> -u <username> -p <password> -j <jobname> -n <jobnum> " % sys.argv[0]
        print "        -i     # ignore pass or skip test results "
        print "        -d[dd] # debug "
        print "        -s[s]  # show stderr and stdout "
        print " "
        print " e.g. ./jenkins_show_test_result.py -dd -n 466 -i |less "

        sys.exit(status)

def main():
    """ main process args and call func to generate report """
    
    rep = report()

    #opts,args = getopt.getopt(sys.argv[1:],'b:-j:')
    try:
        opts, args = getopt.getopt(sys.argv[1:], 
                                   "hb:j:n:u:p:ids", 
                                   ["help",
                                    "baseurl=","jobname=","jobnum=","username=","password=",
                                    "ignorepass","debug","showstderr" ] )
    except getopt.error, msg:
        print msg
        print "for help use -h or --help"
        rep.usage(2)

    for o, a in opts:
        if o in ("-h", "--help"):
            print __doc__
            rep.usage(0)
        if o in ("-b", "--baseurl"):
            rep.baseurl = a
        if o in ("-j", "--jobname"):
            rep.jobname = a
        if o in ("-n", "--jobnum"):
            rep.jobnum = a
        if o in ("-u", "--username"):
            rep.username = a
        if o in ("-p", "--password"):
            rep.password = a
        if o in ("-i", "--ignorepass"):
            rep.ignorepass = True
        if o in ("-d", "--debug"):
            rep.debug += 1
        if o in ("-s", "--showstderr"):
            rep.showstderr += 1

    rep.makeReport()

if __name__ == '__main__':
    main()


