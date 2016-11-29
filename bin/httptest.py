
# http://stackoverflow.com/questions/720867/http-authentication-in-python
# [omn@hp-bl-06 ~]$ py.test --verbose --pdb --junitxml results.xml system_test/regression/scripts/Docker-sanity_regression.py::SANITY::test_SANITY_020_http8888
# [omn@hp-bl-06 ~]$ py.test --verbose --pdb --junitxml results.xml system_test/regression/scripts/Docker-sanity_regression.py::SANITY::test_SANITY_021_httpwing


import urllib2
#from urllib2 import urlopen, HTTPError, URLError, build_opener, HTTPCookieProcessor, Request
import urllib
#from urllib import urlencode
from cookielib import CookieJar

## Create an OpenerDirector with support for Basic HTTP Authentication...
#auth_handler = urllib2.HTTPBasicAuthHandler()
#auth_handler.add_password(realm='PDQ Application',
#                          uri='https://mahler:8092/site-updates.py',
#                          user='klem',
#                          passwd='kadidd!ehopper')
#opener = urllib2.build_opener(auth_handler)
## ...and install it globally so it can be used with urlopen.
#urllib2.install_opener(opener)
#urllib2.urlopen('http://www.example.com/login.html')

#handle = urllib2.Request(url)
#authheader =  "Basic %s" % base64.encodestring('%s:%s' % (username, password))
#handle.add_header("Authorization", authheader)


if False:
    import urllib2
    password_mgr = urllib2.HTTPPasswordMgrWithDefaultRealm()
    top_level_url = "http://hp-bl-05:8888/"
    password_mgr.add_password(None, top_level_url, 'omn', 'omn')
    handler = urllib2.HTTPBasicAuthHandler(password_mgr)
    opener = urllib2.build_opener(urllib2.HTTPHandler, handler)
    url = "http://hp-bl-05:8888/"
    request = urllib2.Request(url)
    print "url:%s request:%s v:%s" % (url, request, vars(request))
    url = "http://hp-bl-05:8888/Wing/Login.jsp"
    request = urllib2.Request(url)
    print "url:%s request:%s v:%s" % (url, request, vars(request))


if False:
    response = urllib2.urlopen('http://pythonforbeginners.com/')
    print "response:%s" % response.info()
    html = response.read()
    print "html:%s" % html
    response.close()  # best practice to close the file




########################################################################################
response = urllib2.urlopen(top_level_url)
print "response:%s code:%s v:%s" % (response.info(),response.code,vars(response))
html = response.read()
print "html:%s" % html
response.close()  # best practice to close the file

# 404: throws exception

url = "http://hp-bl-05:8888/Wing/Login.jsp"
try:
    response = urllib2.urlopen(url)
    print "response:%s code:%s v:%s" % (response.info(),response.code,vars(response))
    html = response.read()
    print "html:%s" % html
    response.close()  # best practice to close the file
    # raise HTTPError(req.get_full_url(), code, msg, hdrs, fp)
except urllib2.HTTPError, e:
    print "EXCEPTION HTTPError code:%s reason:%s e:%s %s " % (e.code, e.reason, e, vars(e))
except urllib2.URLError, e:
    print "EXCEPTION URLError reason:%s e:%s %s " % (e.reason, e, vars(e))
except httplib.HTTPException, e:
    print "EXCEPTION HTTPException e:%s %s " % (e, vars(e))




########################################################################################
url = "http://nfv10-host:8888"
response = urllib2.urlopen(url)
print "response:%s code:%s v:%s" % (response.info(),response.code,vars(response))
html = response.read()
print "html:%s" % html
response.close()  # best practice to close the file

#response:Server: nginx/1.9.14
#Date: Thu, 15 Sep 2016 09:56:08 GMT
#Content-Type: text/html
#Content-Length: 99
#Connection: close
#Accept-Ranges: bytes
#ETag: W/"99-1473897109000"
#Last-Modified: Wed, 14 Sep 2016 23:51:49 GMT
# code:200 v:{'fp': <socket._fileobject object at 0x930bbac>, 'fileno': <bound method _fileobject.fileno of <socket._fileobject object at 0x930bbac>>, 'code': 200, 'read': <bound method _fileobject.read of <socket._fileobject object at 0x930bbac>>, 'readlines': <bound method _fileobject.readlines of <socket._fileobject object at 0x930bbac>>, 'next': <bound method _fileobject.next of <socket._fileobject object at 0x930bbac>>, 'headers': <httplib.HTTPMessage instance at 0x932ae2c>, '__iter__': <bound method _fileobject.__iter__ of <socket._fileobject object at 0x930bbac>>, 'url': 'http://nfv10-host:8888', 'msg': '', 'readline': <bound method _fileobject.readline of <socket._fileobject object at 0x930bbac>>}
#html:<html><head><meta http-equiv="refresh" content="0;URL=/Wing/Login.jsp"></head><body></body></html>

url = "http://nfv10-host:8888/Wing/Login.jsp"
#response = urllib2.urlopen(url)
cj = CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
response = opener.open(url)
print "response:%s code:%s v:%s" % (response.info(),response.code,vars(response))
html = response.read()
print "html:%s" % html
response.close()  # best practice to close the file

print "cookiejar:%s v:%s" % (cj,vars(cj))

#response:Server: nginx/1.9.14
#Date: Thu, 15 Sep 2016 09:56:08 GMT
#Content-Type: text/html;charset=ISO-8859-1
#Content-Length: 6604
#Connection: close
#Set-Cookie: JSESSIONID=7D69CB1A158D4D0AEAF8D69B54DB558B;path=/Wing/;HttpOnly
#Vary: Accept-Encoding
# code:200 v:{'fp': <socket._fileobject object at 0x930be2c>, 'fileno': <bound method _fileobject.fileno of <socket._fileobject object at 0x930be2c>>, 'code': 200, 'read': <bound method _fileobject.read of <socket._fileobject object at 0x930be2c>>, 'readlines': <bound method _fileobject.readlines of <socket._fileobject object at 0x930be2c>>, 'next': <bound method _fileobject.next of <socket._fileobject object at 0x930be2c>>, 'headers': <httplib.HTTPMessage instance at 0x932afcc>, '__iter__': <bound method _fileobject.__iter__ of <socket._fileobject object at 0x930be2c>>, 'url': 'http://nfv10-host:8888/Wing/Login.jsp', 'msg': '', 'readline': <bound method _fileobject.readline of <socket._fileobject object at 0x930be2c>>}
#html:<html xmlns="http://www.w3.org/1999/xhtml">
#<head>
#<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon"/>
#.
#OMN-Login-Panel {
#.
#.OMN-Login-Input {
#.
#.OMN-UserName-TR {
#.
#<body onload='document.f.j_username.focus();'>
#.
#<form name='f' action='/Wing/j_spring_security_check' method='POST'>
#.
#<td><input type='text' name='j_username' value='' class="OMN-Login-Input" /></td>
#<td><input type='password' name='j_password' autocomplete="off" class="OMN-Login-Input"/></td>
#<td><input name="submit" type="submit" value="Login" class="submit"/></td>
#.
#<center>&copy; <a href="http://www.openmindnetworks.com">Openmind Networks</a></center>
#.



# login form data
query_args = { 'j_username':'omn', 'j_password':'omn', 'submit':'Login' }

# urlencode the request form data
data = urllib.urlencode(query_args)

url = "http://nfv10-host:8888/Wing/j_spring_security_check"
# Send HTTP POST request
req = urllib2.Request(url, data)
print "req:%s v:%s" % (req,vars(req))
#response = urllib2.urlopen(req)
# with cookies:
response = opener.open(req)
print "response:%s code:%s v:%s" % (response.info(),response.code,vars(response))
html = response.read()
print "html:%s" % html
response.close()  # best practice to close the file


#cookiejar:<cookielib.CookieJar[<Cookie JSESSIONID=D1F0C402972AC0BD30E20329E5F40650 for nfv10-host.local/Wing/>]> v:{'_now': 1473936696, '_policy': <cookielib.DefaultCookiePolicy instance at 0xb72dc3cc>, '_cookies': {'nfv10-host.local': {'/Wing/': {'JSESSIONID': Cookie(version=0, name='JSESSIONID', value='D1F0C402972AC0BD30E20329E5F40650', port=None, port_specified=False, domain='nfv10-host.local', domain_specified=False, domain_initial_dot=False, path='/Wing/', path_specified=True, secure=False, expires=None, discard=True, comment=None, comment_url=None, rest={'HttpOnly': None}, rfc2109=False)}}}, '_cookies_lock': <_RLock owner=None count=0>}
#req:<urllib2.Request instance at 0xb72dcd8c> v:{'_Request__original': 'http://nfv10-host:8888/Wing/j_spring_security_check', 'data': 'j_username=omn&j_password=omn&submit=Login', '_tunnel_host': None, 'host': None, 'origin_req_host': 'nfv10-host', 'headers': {}, '_Request__fragment': None, 'unredirected_hdrs': {}, 'unverifiable': False, 'type': None, 'port': None}
#response:Server: nginx/1.9.14
#Date: Thu, 15 Sep 2016 10:51:36 GMT
#Content-Type: text/html;charset=ISO-8859-1
#Content-Length: 3125
#Connection: close
#Vary: Accept-Encoding
# code:200 v:{'fp': <socket._fileobject object at 0xb72bce6c>, 'fileno': <bound method _fileobject.fileno of <socket._fileobject object at 0xb72bce6c>>, 'code': 200, 'read': <bound method _fileobject.read of <socket._fileobject object at 0xb72bce6c>>, 'readlines': <bound method _fileobject.readlines of <socket._fileobject object at 0xb72bce6c>>, 'next': <bound method _fileobject.next of <socket._fileobject object at 0xb72bce6c>>, 'headers': <httplib.HTTPMessage instance at 0xb72e04cc>, '__iter__': <bound method _fileobject.__iter__ of <socket._fileobject object at 0xb72bce6c>>, 'url': 'http://nfv10-host:8888/Wing/Wing.jsp', 'msg': '', 'readline': <bound method _fileobject.readline of <socket._fileobject object at 0xb72bce6c>>}
#html:<!DOCTYPE HTML>
#<!-- The HTML 4.01 Transitional DOCTYPE declaration-->
#<!-- above set at the top of the file will set     -->
#<!-- the browser's rendering engine into           -->
#<!-- "Quirks Mode". Replacing this declaration     -->
#<!-- with a "Standards Mode" doctype is supported, -->
#<!-- but may lead to some differences in layout.   -->
#
#<html>
#  <head>
#    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
#    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
#
#    <!--                                                               -->
#    <!-- Consider inlining CSS to reduce the number of requested files -->
#    <!--                                                               -->
#    <link href="wing/gwt/standard/standard.css" rel="stylesheet">
#    <link type="text/css" rel="stylesheet" href="Wing_base.css">    
#    <link type="text/css" rel="stylesheet" href="Wing_stack.css">      
#    <link type="text/css" rel="stylesheet" href="Wing_custom.css">
#    <!--[if gte IE 9]>
#	  <style type="text/css">
#	    .OMN-IE9-Gradient {
#	       filter: none;
#	    }
#	  </style>
#	<![endif]-->
#
#    <!--                                           -->
#    <!-- Any title is fine                         -->
#    <!--                                           -->
#    <title>omn@TC-6000 (oasis-nfv10) - Openmind Networks</title>
#    <script type="text/javascript" src="sessvars.js"></script>
#    <!--                                           -->
#    <!-- This script loads your compiled module.   -->
#    <!-- If you add any GWT meta tags, they must   -->
#    <!-- be added before this line.                -->
#    <!--                                           -->
#    <script type="text/javascript" language="javascript" src="wing/wing.nocache.js"></script>
#    <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon">
#  </head>
#
#  <!--                                           -->
#  <!-- The body can have arbitrary html, or      -->
#  <!-- you can leave the body empty if you want  -->
#  <!-- to create a completely dynamic UI.        -->
#  <!--                                           -->
#  <body>
# <!-- OPTIONAL: include this if you want history support -->
#    <iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>
#  
#    <div id="topsection">
#      <div id="logo"><img src="images/logo.png" alt="openmind: traffic control"></div>
#      <div id="user">
#        <ul>
#          <li><span id="user_name"></span>@<span id="node_name"></span></li>
#<!--      <li><a class="user_preferences" href="#">Preferences</a></li>  -->
#          <li><a class="user_logout" href="/Wing/j_spring_security_logout">Logout</a></li>
#        </ul>
#      </div>
#      <div id="notification">
#      	<div id="loadingPanel" class="OMN-Inform-Msg" style="display: none;"><div class='spinningCircle'>In progress</div>#</div>
#      </div>
#    </div>
#
#    <div id="MainWindow"></div>    
#    <div id="debugWindow"></div>
#	<center>&copy; <a href="http://www.openmindnetworks.com">Openmind Networks</a></center>
#  </body>
#</html>
