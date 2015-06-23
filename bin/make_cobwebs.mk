include Makefile

DTS := $(shell date +%Y%m%d_%H%M)
backup:
	tar -jcvf ../cobwebs_$(DTS).tbz ../cobwebs
	-cvs diff -u >../cobwebs_$(DTS).patch
	mkdir -p /scratch/$(USER)/backups
	cp -p ../cobwebs_$(DTS).tbz ../cobwebs_$(DTS).patch /scratch/$(USER)/backups/

#DEPLOYHOSTS := vb-28 vb-48

devdeploy: devdeploybin devdeployccd
devdeploybin: all

devdeploybin: 
	gzip $(LNK)/cobwebs{,_vld8r}
	scp $(LNK)/cobwebs{,_vld8r}.gz omn@vb-28:bin/
	scp $(LNK)/cobwebs{,_vld8r}.gz omn@vb-48:bin/
	tar -jcvf $(LNK)/cobwebssolibs.tbz $(LNK)/lib*.so
	scp $(LNK)/cobwebssolibs.tbz omn@vb-28:lib/
	scp $(LNK)/cobwebssolibs.tbz omn@vb-48:lib/
	# libcobwebs_config_ccd-vx-xx-xx.so libcobwebs_prov_ccd-vx-xx-xx.so libtron_cobwebs-vx-xx-xx.so	
	ssh omn@vb-28 "cd lib; tar -jxvf cobwebssolibs.tbz; mv -f lnk/linux.fc9/* .; cd ..; mv bin/cobwebs{,.older}; mv bin/cobwebs_vld8r{,.older}; gunzip bin/cobwebs{,_vld8r}.gz"
	ssh omn@vb-48 "cd lib; tar -jxvf cobwebssolibs.tbz; mv -f lnk/linux.fc9/* .; cd ..; mv bin/cobwebs{,.older}; mv bin/cobwebs_vld8r{,.older}; gunzip bin/cobwebs{,_vld8r}.gz; mci stop cobwebs-1 cobwebs-2; mci start cobwebs-1 cobwebs-2; sleep 10; mci list |grep cobwebs"
	echo "For Validators corrib_router/META and tc_cconf_vld8r from deployments/OMN-Traffic-Control also need to be built, install(use rpm) and restart process using sci"

RPMSCRATCHDIR := /scratch/james/RPMS/rpms_cobwebs/
MYRPM := OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686
OTHERRPMS := OMN-CORRIB-PROTECT-vx.xx.xx-1.FC9.i686 OMN-Traffic-Control-vx.xx.xx-1.FC9.i686

devdeployccd: 
	echo "MAKE SURE YOU HAVE RE-BUILT corrib_router/META"
	cp -p ../META/RPMS/$(MYRPM).rpm $(RPMSCRATCHDIR)
	ssh vroot@vb-28 "rpm -e $(MYRPM) $(OTHERRPMS); rpm -ivh $(patsubst %,$(RPMSCRATCHDIR)/%.rpm,$(MYRPM) $(OTHERRPMS)); cd /apps/omn; ./bin/sci -stop_proc tomcat.sh;"
	ssh vroot@vb-48 "rpm -e $(MYRPM) $(OTHERRPMS); rpm -ivh $(patsubst %,$(RPMSCRATCHDIR)/%.rpm,$(MYRPM) $(OTHERRPMS)); cd /apps/omn; ./bin/sci -stop_proc tomcat.sh;"
	ssh omn@vb-48 "mci stop cobwebs-1 cobwebs-2; mci start cobwebs-1 cobwebs-2"

devdeployvld8r:
	#gmake spotless all __FAKE_RELEASE_AREA
	cd ../META && pwd && gmake spotless all __FAKE_RELEASE_AREA
	cd ../../deployments/OMN-Traffic-Control && gmake spotless all __FAKE_RELEASE_AREA
	cd ../.. && run_prep_rpms_deploylist.sh 
	pwd
	cd corrib_router/cobwebs/
	pwd
	ssh vroot@vb-48 "cd /apps/omn/bin/; ./sci -stop; sleep 20 && sci -quit; rpm --force -ivh /scratch/james/RPMS/rpms_cobwebs/{OMN-CORRIB-ROUTER-vx.xx.xx-1.FC9.i686,OMN-CORRIB-PROTECT-vx.xx.xx-1.FC9.i686,OMN-Traffic-Control-vx.xx.xx-1.FC9.i686}.rpm; cd ..' ./scripts/samson.sh &"
	echo "now run ./scripts/samson.sh; rm -rf cconf-dir.old/ dfl-dir.old/ && sci -rejoin; e.t.c."
	#scp ~/bin/run_rejoin_TC.sh omn@${HOST2}:scripts/
	#ssh omn@${HOST1} /apps/omn/scripts/run_solo_start_TC.sh |tee -a TC_solo_start.log; 
	ssh omn@vb-48 /apps/omn/scripts/run_rejoin_TC.sh |tee -a TC_rejoin.log; 
