#!/usr/bin/env python

# this script is only demo purpose which is designed to get properties of job, queue, like
# nextBuildNumber. But note the logistics might not be correct

import urllib2
import base64


#baseurl="http://hp-bl-06.ie.openmindnetworks.com:8086"
baseurl="http://hp-bl-02.ie.openmindnetworks.com:8086"

### 1. we do not need to use token
### 2. passman username/passwd stuff doesn't work
###    but base64 adding username/password to request does work.

#passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
#passman.add_password(None, baseurl, "admin", "paSSword")
#urllib2.install_opener(urllib2.build_opener(urllib2.HTTPBasicAuthHandler(passman)))
#url="%s/crumbIssuer/api/json" % baseurl
#passman.add_password(None, url, "admin", "paSSword")
#urllib2.install_opener(urllib2.build_opener(urllib2.HTTPBasicAuthHandler(passman)))
#req = urllib2.Request(url)
#f = urllib2.urlopen(req)
##urllib2.HTTPError: HTTP Error 403: Forbidden
#token = f.read()
#print(token)


#call api of job
# ?depth=0  ?pretty=true
#https://wiki.jenkins-ci.org/display/JENKINS/Remote+access+API
#url="http://localhost:9001/job/git_plugin_test/api/python?depth=0"
#url="%s/job/system_test_regression_SMSC_15-Q3_DRIVERhp-bl-06_SUThp-bl-05/lastCompletedBuild/testReport/api/python" % baseurl
url="%s/job/yellowstone_QA_Staging/lastCompletedBuild/testReport/api/python" % baseurl

username="admin"
password="paSSword"
base64string = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')
request = urllib2.Request(url)
request.add_header("Authorization", "Basic %s" % base64string) 
result = urllib2.urlopen(request)
# job dict
j=eval(result.read())

# properties of job
#for eachKey in j:
#    print eachKey
#    #print eachKey,j[eachKey]
#    print
#failCount suites skipCount empty duration passCount _class testActions
print "TOTAL test count: pass:%d fail:%d skip:%d" % (j['passCount'],j['failCount'],j['skipCount'])

oldClassName=""
suites=j['suites']
for s in suites:
    for c in s['cases']:
        #print c.keys()
        #['status', 'skipped', 'failedSince', 'stderr', 'stdout', 'testActions', 'duration', 'name', 'errorDetails', 'age', 'className', 'errorStackTrace', 'skippedMessage']
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


#call api of job 'queue' of jenkins (global but not specific for one job)
url="%s/queue/api/python?depth=0" % baseurl
request = urllib2.Request(url)
request.add_header("Authorization", "Basic %s" % base64string) 
result = urllib2.urlopen(request)
queue_dict=eval(result.read())

from pprint import pprint
pprint(vars(queue_dict),indent=2)




print ''*40,'queue dict',''*40
#look through items in queue and can be extended to forecast the job build
#number in for one item in queue
for index in range(1,len(queue_dict['items'])):
    print ''*40,'queue hash',''*40
    qi_action=queue_dict['items'][index]['actions']
    list_para=qi_action[0]['parameters']
    for index1 in range(0,len(list_para)):
        print list_para[index1]
        if list_para[index1]['name'] == 'SLEEP_TIME' and list_para[index1]['value'] == '62':
            print "OK"

#only valid when no more than one build found in queue
if j['inQueue']:
    build_number=int(j['nextBuildNumber']) + 1
else:
    build_number=int(j['nextBuildNumber'])
print "Jenkins Build URL:",j['url']+str(build_number)
print "Current build tree:"+j['builds'][0]['url']
