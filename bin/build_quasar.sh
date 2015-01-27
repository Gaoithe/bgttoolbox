QD=quasar

cd $QD/lib; 
#make all __FAKE_RELEASE_AREA
make spotless all __FAKE_RELEASE_AREA

cd $QD/QUASAR; 
#make spotless all; 
#make all __FAKE_RELEASE_AREA
make spotless all __FAKE_RELEASE_AREA

#[james@nebraska quasar]$ ls
#care  client  CVS  lib  libqstorage  librodeo  logger  mod.graph  mod.list  Module.versions  QUASAR  retry  retry_config  server
for d in care  client  libqstorage  librodeo  logger  retry  retry_config  server; do
  cd $QD/$d
  make spotless all __FAKE_RELEASE_AREA
done
