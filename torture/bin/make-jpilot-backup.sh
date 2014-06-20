#!/bin/bash

ts=`date +"%Y%m%d%H%M%S"`
cd ~/.jpilot
tar -zcvf backup$ts.tgz *.pdb *.pc3 next_id jpilot* backup/*
