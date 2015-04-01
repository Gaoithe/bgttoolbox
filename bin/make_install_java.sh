#!/bin/bash

USERHOST=$1
if [[ -z $USERHOST ]] ; then 
    echo "you must specify install location as user@host e.g. omn@nebraska"
    exit;
fi

CJARFILES=$(ls dst/*.jar); 
if [[ ! -z "$CJARFILES" ]] ; then 
    echo install client $CJARFILES to $USERHOST:tomcat/webapps/Wing/WEB-INF/lib/; 
    scp $CJARFILES $USERHOST:tomcat/webapps/Wing/WEB-INF/lib/
fi

SJARFILES=$(ls dst/*.jar); 
if [[ ! -z "$SJARFILES" ]] ; then 
    echo install server $SJARFILES to $USERHOST:java/; 
    scp $SJARFILES $USERHOST:java/
    echo rebuild slingshot.jar
    ssh $USERHOST "ls -al java/slingshot.jar; sh scripts/rpmmkj.sh; ls -al java/slingshot.jar;"
fi

while [[ ! -e SBUG_SRC_BASE && $(pwd) != "/" ]] ; do
  cd ..
done;
if [[ $(pwd) == "/" ]] ; then
    echo error: cannot find build base using SBUG_SRC_BASE
    exit -1
fi

echo build deptron/OMN-Traffic-Control
cd deptron/OMN-Traffic-Control
gmake spotless all __FAKE_RELEASE_AREA

echo copy war/wing files
scp -r war/wing/* $USERHOST:tomcat/webapps/Wing/wing/

# now restart tomcat or . . . . 
#ssh $USERHOST "sci -stop_proc tomcat.sh"
