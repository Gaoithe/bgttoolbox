#!/bin/python

import httplib, urllib
# download from <a href="http://code.google.com/p/psutil/" title="http://code.google.com/p/psutil/">http://code.google.com/p/psutil/</a>
import psutil
import time

# Install: [james@nebraska gloGH]$ sudo easy_install psutil

#https://thingspeak.com/channels/120786/private_show
#OMN regr test stop/start times
#Channel ID:	120786
 
def doit():
    cpu_pc = psutil.cpu_percent()
    #mem_avail_mb = psutil.avail_phymem()/1000000
    mem_avail_mb = psutil.virtual_memory().available
    print cpu_pc
    print mem_avail_mb
    params = urllib.urlencode({'field1': cpu_pc, 'field2': mem_avail_mb,'key':'0ZR02LA2PL8KCK87'})
    headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
    conn = httplib.HTTPConnection("api.thingspeak.com:80")
    conn.request("POST", "/update", params, headers)
    response = conn.getresponse()
    print response.status, response.reason
    data = response.read()
    conn.close()
 
#sleep for 16 seconds (api limit of 15 secs)
if __name__ == "__main__":
    while True:
        doit()
        time.sleep(16) 

#<iframe width="640" height="300" style="border: 1px solid #cccccc;" src="https://www.thingspeak.com/channels/120786/charts/2?   
#  height=300&width=640&results=30&title=Available%20Memory%20(mb)
#  &dynamic=true&results=30">
#</iframe>

#http://www.australianrobotics.com.au/news/how-to-talk-to-thingspeak-with-python-a-memory-cpu-monitor
#https://github.com/giampaolo/psutil/blob/master/INSTALL.rst
