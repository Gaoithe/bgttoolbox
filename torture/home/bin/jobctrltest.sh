#!/bin/bash 
#!/bin/bash -m

# -m for job control

# invoke: ./makerps &
# build will run in parallel (5 top level processes per Makefile called) 
# nice 6 so cpu will not be hammered
# user processes will not notice because of nice
# build much faster as the limiting build factor is really disk io access, not cpu. 
# xterm opened showing build progress (closed when build finishes)
# errors logged on screen and to file and presented after build in another xterm if present

echo start process 1
xterm -T "process 1" &
makepid=$!
echo IFNI makepid is $makepid

sleep 3
echo start process 2
xterm -T "process 2" &
logpid=$!
echo IFNI logpid is $logpid

echo IFNI wait for process 1 to finish #fg %- or wait %- or wait $makepid 
# beware the error: wait: job control not enabled (on wait %- in script?)
wait $makepid

echo IFNI after make process finishes kill make log. #kill %+ or kill $logpid
kill $logpid
kill -9 $logpid

