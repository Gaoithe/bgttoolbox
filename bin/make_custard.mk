include Makefile

DTS := $(shell date +%Y%m%d_%H%M)

showsbecustard:
	echo SBE_DIR=$(SBE_DIR) SBE_INC_DIR=$(SBE_INC_DIR)

MODNAME=drill_custard
DMODNAME=drill_custard
devdeploybin: $(LNK)/drill_custard $(LNK)/drill_custard_cli
	gzip < $(LNK)/$(MODNAME) > $(LNK)/$(MODNAME).gz
	gzip < $(LNK)/$(MODNAME)_cli > $(LNK)/$(MODNAME)_cli.gz
	#gzip < $(LNK)/$(MODNAME)_vld8r > $(LNK)/$(MODNAME)_vld8r.gz
	scp $(LNK)/$(MODNAME){,_cli}.gz omn@vb-28:bin/
	scp $(LNK)/$(MODNAME){,_cli}.gz omn@vb-48:bin/
	tar -jcvf $(LNK)/$(MODNAME)solibs.tbz $(LNK)/lib*.so
	scp $(LNK)/$(MODNAME)solibs.tbz omn@vb-28:lib/
	scp $(LNK)/$(MODNAME)solibs.tbz omn@vb-48:lib/
	# lib$(MODNAME)_config_ccd-vx-xx-xx.so lib$(MODNAME)_prov_ccd-vx-xx-xx.so libtron_$(MODNAME)-vx-xx-xx.so	
	ssh omn@vb-28 "cd lib; tar -jxvf $(MODNAME)solibs.tbz; mv -f lnk/linux.fc9/* .; cd ..; "
	-ssh omn@vb-28 "[[ -e bin/$(MODNAME) ]] && mv -f bin/$(MODNAME){,$(DTS)};"
	-ssh omn@vb-28 "[[ -e bin/$(MODNAME)_cli ]] && mv -f bin/$(MODNAME)_cli{,$(DTS)};"
	ssh omn@vb-28 "gunzip bin/$(MODNAME){,_cli}.gz; chmod 755 bin/$(MODNAME){,_cli}"
	ssh omn@vb-48 "cd lib; tar -jxvf $(MODNAME)solibs.tbz; mv -f lnk/linux.fc9/* .; cd ..; "
	-ssh omn@vb-48 "[[ -e bin/$(MODNAME) ]] && mv -f bin/$(MODNAME){,$(DTS)};"
	-ssh omn@vb-48 "[[ -e bin/$(MODNAME)_cli ]] && mv -f bin/$(MODNAME)_cli{,$(DTS)};"
	ssh omn@vb-48 "gunzip bin/$(MODNAME){,_cli}.gz; chmod 755 bin/$(MODNAME){,_cli}"
	# start
	ssh omn@vb-48 "mci stop $(DMODNAME)-1 $(DMODNAME)-2; mci start $(DMODNAME)-1 $(DMODNAME)-2; sleep 10; mci list |grep $(MODNAME)"
	#echo "For Validators ??/META and tc_cconf_vld8r from deployments/OMN-Traffic-Control also need to be built, install(use rpm) and restart process using sci"

