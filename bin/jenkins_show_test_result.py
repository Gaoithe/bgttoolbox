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
        self.showcsv = False

    def makeReport(self):
        #call api of job
        # ?depth=0  ?pretty=true
        url="%s/job/%s/%s/api/python" % (self.baseurl,self.jobname,self.jobnum)
        base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
        request = urllib2.Request(url)
        request.add_header("Authorization", "Basic %s" % base64string) 
        try:
            result = urllib2.urlopen(request)
            job=eval(result.read())
            if self.debug: 
                print " keys:{}".format(job.keys())
                from pprint import pprint
                pprint(job,indent=4)

            from datetime import datetime
            dt = datetime.fromtimestamp(float(long(job['timestamp'])/1000.0))
            dtf = dt.strftime("%Y-%m-%d %H:%M:%S")
            print "{} {} {} {}".format(job['fullDisplayName'],
                                       dtf,
                                       job['result'],
                                       job['description'])

            #'description': 'v1.02.26 not rup',
            #'fullDisplayName': 'yellowstone_QA_Staging #373',
            #'result': 'SUCCESS',
            #'timestamp': 1497801645199L,
#>>> datetime.fromtimestamp(float(1497801645199L/1000.0))
#datetime.datetime(2017, 6, 18, 17, 0, 45, 199000)

        except urllib2.HTTPError, msg:
            print msg
            print url
        """ 
 keys:['building', 'queueId', 'displayName', 'description', 'changeSet', 'artifacts', 'timestamp', 'number', 'actions', 'id', 'keepLog', 'url', 'culprits', 'result', 'executor', 'duration', 'builtOn', '_class', 'fullDisplayName', 'estimatedDuration']
{   '_class': 'hudson.model.FreeStyleBuild',
    'actions': [   {   '_class': 'hudson.model.CauseAction',
                       'causes': [   {   '_class': 'hudson.model.Cause$UserIdCause',
                                         'shortDescription': 'Started by user admin',
                                         'userId': 'admin',
                                         'userName': 'admin'}]},
                   {   '_class': 'jenkins.metrics.impl.TimeInQueueAction'},
                   {   },
                   {   },
                   {   },
                   {   '_class': 'hudson.scm.cvstagging.CvsTagAction'},
                   {   },
                   {   '_class': 'hudson.tasks.junit.TestResultAction',
                       'failCount': 0,
                       'skipCount': 122,
                       'totalCount': 272,
                       'urlName': 'testReport'},
                   {   }],
    'artifacts': [   {   'displayPath': 'container_logs_after_install_fail.txt',
                         'fileName': 'container_logs_after_install_fail.txt',
                         'relativePath': 'container_logs_after_install_fail.txt'},
                     {   'displayPath': 'container_logs_before_test.txt',
                         'fileName': 'container_logs_before_test.txt',
                         'relativePath': 'container_logs_before_test.txt'},
                     {   'displayPath': 'poll_change.patch',
                         'fileName': 'poll_change.patch',
                         'relativePath': 'poll_change.patch'},
                     {   'displayPath': 'testreport.html',
                         'fileName': 'testreport.html',
                         'relativePath': 'testreport.html'},
                     {   'displayPath': 'VERSION.txt',
                         'fileName': 'VERSION.txt',
                         'relativePath': 'VERSION.txt'},
                     {   'displayPath': 'VERSION_load.txt',
                         'fileName': 'VERSION_load.txt',
                         'relativePath': 'VERSION_load.txt'}],
    'building': False,
    'builtOn': '',
    'changeSet': {   '_class': 'hudson.scm.CVSChangeLogSet',
                     'items': [],
                     'kind': 'cvs'},
    'culprits': [   {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/bob',
                        'fullName': 'bob'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/colm',
                        'fullName': 'colm'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/james',
                        'fullName': 'james'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/jirip',
                        'fullName': 'jirip'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/larry',
                        'fullName': 'larry'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/martin',
                        'fullName': 'Martin Havel'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/mbrenn',
                        'fullName': 'mbrenn'},
                    {   'absoluteUrl': 'http://hp-bl-06.ie.openmindnetworks.com:8086/user/rob',
                        'fullName': 'rob'}],
    'description': 'v1.02.26 not rup',
    'displayName': '#373',
    'duration': 10751444,
    'estimatedDuration': 14041878,
    'executor': None,
    'fullDisplayName': 'yellowstone_QA_Staging #373',
    'id': '373',
    'keepLog': False,
    'number': 373,
    'queueId': 2485,
    'result': 'SUCCESS',
    'timestamp': 1497801645199L,
    'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/373/'}
        """


        url="%s/job/%s/%s/testReport/api/python" % (self.baseurl,self.jobname,self.jobnum)
        base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
        request = urllib2.Request(url)
        request.add_header("Authorization", "Basic %s" % base64string) 
        try:
            result = urllib2.urlopen(request)
        except urllib2.HTTPError, msg:
            print msg
            print url

            url="%s/job/%s/api/python" % (self.baseurl,self.jobname)
            base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
            request = urllib2.Request(url)
            request.add_header("Authorization", "Basic %s" % base64string) 
            try:
                result = urllib2.urlopen(request)
            except urllib2.HTTPError, msg:
                print msg
                print url

        # job dict
        j=eval(result.read())

        # keys of job:
        # failCount suites skipCount empty duration passCount _class testActions
        if not 'passCount' in j:
            print "Which job?"
            #print " dir:{}".format(dir(j))
            print " keys:{}".format(j.keys())
            from pprint import pprint
            pprint(j,indent=4)
            sys.exit(1)

        self.testRepInfo(j)

        print "TOTAL test count: pass:%d fail:%d skip:%d" % (j['passCount'],j['failCount'],j['skipCount'])

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

$ ./jenkins_show_test_result.py -n 373 -i
TOTAL test count: pass:150 fail:0 skip:122
TEST CLASS: test_smsc_charging.TestMoMtCharging
     TEST RESULT: FIXED NAME: test_mo_mt_charging
TEST CLASS: test_smsc_charset_support.TestCharsetSupport
     TEST RESULT: FIXED NAME: test_CharsetSupport_3_3_1_1
TEST CLASS: test_smsc_ims_momt.TestImsMoMt
     TEST RESULT: FIXED NAME: test_ims_mo_mt_7
TEST CLASS: test_smsc_ims_momt.TestImsMoMt
     TEST RESULT: FIXED NAME: test_ims_mo_mt_8
TEST CLASS: test_smsc_smpp_support.TestSmppBind
     TEST RESULT: FIXED NAME: test_smppsupport_3_19_1_inesme

$ ./jenkins_show_test_result.py -n 368 -i
HTTP Error 404: Not Found
http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/368/testReport/api/python
Which job?
 keys:['scm', 'color', 'lastSuccessfulBuild', 'actions', 'lastCompletedBuild', 'lastUnsuccessfulBuild', 'upstreamProjects', 'lastFailedBuild', 'healthReport', 'queueItem', 'lastBuild', '_class', 'lastStableBuild', 'description', 'downstreamProjects', 'concurrentBuild', 'lastUnstableBuild', 'buildable', 'displayNameOrNull', 'inQueue', 'keepDependencies', 'name', 'displayName', 'builds', 'url', 'firstBuild', 'nextBuildNumber', 'property']
{   '_class': 'hudson.model.FreeStyleProject',
    'actions': [   {   },
                   {   },
                   {   },
                   {   },
                   {   },
                   {   },
                   {   '_class': 'org.jenkinsci.plugins.testresultsanalyzer.TestResultsAnalyzerAction'},
                   {   '_class': 'com.cloudbees.plugins.credentials.ViewCredentialsAction'}],
    'buildable': True,
    'builds': [   {   '_class': 'hudson.model.FreeStyleBuild',
                      'number': 468,
                      'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/468/'},
                  {   '_class': 'hudson.model.FreeStyleBuild',
                      'number': 467,
                      'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/467/'},
.
.
.
                  {   '_class': 'hudson.model.FreeStyleBuild',
                      'number': 368,
                      'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/368/'}],
    'color': 'yellow',
    'concurrentBuild': False,
    'description': '',
    'displayName': 'yellowstone_QA_Staging',
    'displayNameOrNull': None,
    'downstreamProjects': [],
    'firstBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                      'number': 1,
                      'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/1/'},
    'healthReport': [   {   'description': 'Build stability: 2 out of the last 5 builds failed.',
                            'iconClassName': 'icon-health-40to59',
                            'iconUrl': 'health-40to59.png',
                            'score': 60},
                        {   'description': 'Test Result: 2 tests failing out of a total of 258 tests.',
                            'iconClassName': 'icon-health-80plus',
                            'iconUrl': 'health-80plus.png',
                            'score': 99}],
    'inQueue': False,
    'keepDependencies': False,
    'lastBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                     'number': 468,
                     'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/468/'},
    'lastCompletedBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                              'number': 468,
                              'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/468/'},
    'lastFailedBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                           'number': 467,
                           'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/467/'},
    'lastStableBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                           'number': 457,
                           'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/457/'},
    'lastSuccessfulBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                               'number': 468,
                               'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/468/'},
    'lastUnstableBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                             'number': 468,
                             'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/468/'},
    'lastUnsuccessfulBuild': {   '_class': 'hudson.model.FreeStyleBuild',
                                 'number': 468,
                                 'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/468/'},
    'name': 'yellowstone_QA_Staging',
    'nextBuildNumber': 469,
    'property': [   {   '_class': 'org.jenkins.plugins.lockableresources.RequiredResourcesProperty'},
                    {   '_class': 'de.pellepelster.jenkins.walldisplay.WallDisplayJobProperty',
                        'wallDisplayBgPicture': None,
                        'wallDisplayName': None,
                        'wallDisplayOrder': None}],
    'queueItem': None,
    'scm': {   '_class': 'hudson.scm.CVSSCM'},
    'upstreamProjects': [],
    'url': 'http://hp-bl-06.ie.openmindnetworks.com:8086/job/yellowstone_QA_Staging/'}

        """

    def showCSV(self):

        # 1. get general job info and just of builds/job numbers
        url="%s/job/%s/api/python" % (self.baseurl,self.jobname)
        base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
        request = urllib2.Request(url)
        request.add_header("Authorization", "Basic %s" % base64string) 
        try:
            result = urllib2.urlopen(request)
        except urllib2.HTTPError, msg:
            print msg
            print url
            sys.exit(2)

        # job . . builds list
        jobinfo=eval(result.read())
        #print " keys:{}".format(job.keys())
        #from pprint import pprint
        #pprint(job,indent=4)
        if not 'builds' in jobinfo:
            print "UGH. No builds list in job ?"
            print " keys:{}".format(jobinfo.keys())
            sys.exit(2)
            
        for b in jobinfo['builds']:
            if self.debug: print b['number'] 
            if self.debug: print b['url']

            #2. get info for each build job

            url = b['url'] + "/api/python"
            # ?depth=0  ?pretty=true
            #url="%s/job/%s/%s/api/python" % (self.baseurl,self.jobname,b['number'])
            base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
            request = urllib2.Request(url)
            request.add_header("Authorization", "Basic %s" % base64string) 
            try:
                result = urllib2.urlopen(request)
                job=eval(result.read())
                if self.debug: 
                    print " keys:{}".format(job.keys())
                    from pprint import pprint
                    pprint(job,indent=4)

                from datetime import datetime
                dt = datetime.fromtimestamp(float(long(job['timestamp'])/1000.0))
                dtf = dt.strftime("%Y-%m-%d %H:%M:%S")
                print "{} {} {} {}".format(job['fullDisplayName'],
                                           dtf,
                                           job['result'],
                                           job['description'])

            except urllib2.HTTPError, msg:
                if self.debug: print msg
                if self.debug: print url
                pass


            # 3. get testReport info for each build job
            url="%s/job/%s/%s/testReport/api/python" % (self.baseurl,self.jobname,b['number'])
            base64string = base64.encodestring('%s:%s' % (self.username, self.password)).replace('\n', '')
            request = urllib2.Request(url)
            request.add_header("Authorization", "Basic %s" % base64string) 
            try:
                result = urllib2.urlopen(request)
                # job dict
                r=eval(result.read())
                self.testRepInfo(r)

            except urllib2.HTTPError, msg:
                if self.debug: print msg
                if self.debug: print url
                pass

    def testRepInfo(self,report):
        print "TOTAL test count: pass:%d fail:%d skip:%d" % (report['passCount'],report['failCount'],report['skipCount'])
        oldClassName=""
        suites=report['suites']
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




    def usage(msg,status=1):
        print msg
        print "Usage:"
        print "    %s -b <jenkins url> -u <username> -p <password> -j <jobname> -n <jobnum> " % sys.argv[0]
        print "        -c     # make csv report "
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
                                   "hb:j:n:u:p:idsc", 
                                   ["help",
                                    "baseurl=","jobname=","jobnum=","username=","password=",
                                    "ignorepass","debug","showstderr","csv" ] )
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
        if o in ("-c", "--csv"):
            rep.showcsv = True

    if rep.showcsv:
        rep.showCSV()
    else:
        rep.makeReport()

if __name__ == '__main__':
    main()


