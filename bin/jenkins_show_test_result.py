#!/usr/bin/env python

# get test result from jenkins job - jenkins http python API

import urllib2
import base64
import os

#baseurl="http://hp-bl-06.ie.openmindnetworks.com:8086"
baseurl = os.environ['BUILD_URL']

# get jobname from ENV $JOB_NAME should be set
#jobname="system_test_regression_SMSC_15-Q3_DRIVERhp-bl-06_SUThp-bl-05"
jobname = os.environ['JOB_NAME']

#call api of job
# ?depth=0  ?pretty=true
url="%s/job/%s/lastCompletedBuild/testReport/api/python" % (baseurl,jobname)

username="admin"
password="paSSword"
base64string = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')
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
        if c['className'] != oldClassName:
            print "TEST CLASS: %s" % c['className']
            oldClassName = c['className']
        skipped = ""
        if c['skipped']:
            skipped = " SKIP(%s)" % c['skippedMessage']
        print "     TEST RESULT: %s%s NAME: %s" % ( c['status'], skipped, c['name'] )
        if c['errorDetails']:
            print "      ERR: %s" % c['errorDetails']
        #if c['errorStackTrace']:
        #    from pprint import pprint
        #    pprint(c['errorStackTrace'],indent=8)

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

