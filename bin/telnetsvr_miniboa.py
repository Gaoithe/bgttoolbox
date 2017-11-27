#!/usr/bin/python

from miniboa import TelnetServer

CLIENTS = []

def my_on_connect(client):
    """Example on_connect handler."""
    client.send('You connected from %s\r\n' % client.addrport())
    if CLIENTS:
        client.send('Also connected are:\r\n')
        for neighbor in CLIENTS:
            client.send('%s\r\n' % neighbor.addrport())
    else:
        client.send('Sadly, you are alone.\r\n')
    CLIENTS.append(client)


def my_on_disconnect(client):
    """Example on_disconnect handler."""
    CLIENTS.remove(client)

server = TelnetServer()
server.on_connect=my_on_connect
server.on_disconnect=my_on_disconnect

print "\n\nStarting server on port %d.  CTRL-C to interrupt.\n" % server.port
while True:
    server.poll()
