#!/bin/bash

# Releasing new pipeline app.
# corrib_router/cobwebs pipeline app added
# wascal - cobwebs added in gui
# sbe - small change port numbers added for cobwebs
# corrib_router/META cobwebs added
# deployments/OMN-Traffic-Control - added to plumbing ddp files, licences added dependant on cobwebs fletch
#
# How to release without breaking build . . . ? :-P
# How to release with breaking build:
# Checkin sbe, wascal, corrib_router/{cobwebs,META}, deployments/OMN-Traffic-Control
#  (did prerelease on them). BEFORE commit remove some james/TODO customisations.
# Generate mod.list. 
#  Add corrib_router/cobwebs just before corrib_router/META. 
#  Remove MOS-WEB TOMCAT libtbx JBOSS openldap-pkg from mod.list
# Run pristine rebuild.pl to just before corrib_router/cobwebs (corrib_charging/app).
# Run pristine scm.pl -release pn corrib_router/cobwebs.
# Run pristine rebuild.pl from just after corrib_router/cobwebs (corrib_router/META).
# 
# 
# TO overcome nebraska cvs problem login to iowa. cd /scratch/james. Run pristine from there.
# Run screen so can attatch from home/remote and check build progress, fix build errors, restart build, do next step, e.t.c. 

# screen
cd /scratch/james
build
/slingshot/sbe/LATEST/scripts/build_order --cvs-modules --root /slingshot/deployments/OMN-Traffic-Control >mod.list
cp -p mod{,.orig}.list; grep -Ev "^(MOS-WEB|TOMCAT|libtbx|JBOSS|openldap-pkg)$" mod.orig.list >mod.list
# you could do it without .orig but warning seen: grep: input file ‘mod.list’ is also the output

/slingshot/sbe/LATEST/scripts/rebuild.pl -plan mod.list sbe corrib_charging/app "pristine for corrib_router/cobwebs release" __wilma 2>&1 |tee b1.log
##__wilma is temp cvs checkout and build area.

rc=$?
[[ $rc -eq 0 ]] && /slingshot/sbe/LATEST/scripts/scm.pl -release corrib_router/cobwebs patch 2>&1 |tee b2.log
rc2=$?
[[ $rc2 -eq 0 ]] && /slingshot/sbe/LATEST/scripts/rebuild.pl -plan mod.list corrib_router/META deployments/OMN-Traffic-Control  "pristine for cobwebs release" __wilma 2>&1 |tee b3.log
echo rc=$rc rc2=$rc2
ls -al b*.log

