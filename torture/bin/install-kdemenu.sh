#!/bin/bash


#jamesc@dhcppc0:~> strings `which googleearth` |grep xpm
#jamesc@dhcppc0:~> locate googleearth |grep xpm
#/usr/local/google-earth/googleearth.xpm
#jamesc@dhcppc0:~> locate googleearth |grep ico
#/usr/local/google-earth/googleearth-icon.png
#/usr/local/google-earth/resources/googleearth-icon.png

#/usr/share/applications/bzflag-solo.desktop

if [[ $1 == "" ]] ; then
    echo "usage: $0 <application>"
    exit -1
fi

APP=$1

selpic(){
   PICS=`locate $APP |grep -E "xpm|ico|png|jpg"`
   for PIC in $PICS ; do 
      PICID=`identify $PIC`
      display $PIC &
      RV=$?
      JOB=$!
      echo PICID $PICID
      read -p "does that one look nice?" ans
      kill $JOB
      if [[ ${ans#y} != $ans || ${ans#Y} != $ans ]]; then
       SELPIC=$PIC
       return 1
      fi   
   done
   return 0
}

SELPIC= 
selpic
echo selected PIC $SELPIC

THINGIES="Name Categories"
#THINGIES="Name GenericName Exec Type Icon Name[en] GenericName[en] Categories"

Name="BZFlag solo"
GenericName="BZFlag-solo"
Exec="$APP"
Type="Application"
Icon="$SELPIC"
Name[en]="BZFlag solo"
GenericName[en]="3D networked multiplayer tank battle game"
Categories="Game;ActionGame"


   for THING in $THINGIES ; do 
       eval THINGV=\$$THING
       read -p "Get ready to pick a $THING"
       grep -h $THING /usr/share/applications/*.desktop |sort |uniq |less
       read -p "$THING=$THINGV ?" $THING
   done

GenericName="$Name"


echo "[Desktop Entry]
Name=$Name
GenericName=$GenericName
Exec=$Exec
Type=$Type
Icon=$Icon
Categories=$Categories
" > $APP.desktop

cp $APP.desktop /usr/share/applications/
sudo cp $APP.desktop /opt/kde3/share/applications/kde/

