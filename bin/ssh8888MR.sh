#!/bin/bash

HOSMCN="192.168.102.21 192.168.102.22"
HOST=192.168.102.21
#ssh -g -L 127.0.0.4:8888:$HOST:8888 -L 127.0.0.4:29997:$HOST:29997 -L 127.0.0.4:22:$HOST:22 root@dell-b-14
ssh -g -L 127.0.0.4:8888:$HOST:8888 -L 127.0.0.4:29997:$HOST:29997 root@dell-b-14
echo HOST=$HOST now goto http://127.0.0.4:8888/Wing/
