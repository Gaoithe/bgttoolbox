#!/usr/bin/python

'''moo'''

import getpass
import sys
import telnetlib

HOST = "localhost"
PORT = 8080
HOST = "iowa"
PORT = 80
#HOST = "localhost"
#PORT = 7777

#user = raw_input("Enter your remote account: ")
#password = getpass.getpass()

print "connect to " + HOST + ":" + str(PORT) + "\n";
tn = telnetlib.Telnet(HOST,PORT)

#tn.read_until("login: ")
#tn.write(user + "\n")
#if password:
#    tn.read_until("Password: ")
#    tn.write(password + "\n")
#tn.write("ls\n")
#tn.write("exit\n")
#print tn.read_all()

#Connected to localhost.
#Escape character is '^]'.
print "write\n"
tn.write("GET /\n")
#tn.write("GET index.html HTTP/1.0\n")
#tn.write("HEAD HTTP/1.0\nGET index.html\n")
#tn.write("\n")
print "read\n"
print tn.read_until("Escape character is ")
#tn.write(user + "HEAD HTTP/1.0\nGET index.html\n")
#tn.write("HEAD HTTP/1.0\nGET index.html\n")
print "read\n"
print tn.read_all()

