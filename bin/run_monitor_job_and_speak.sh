#!/bin/bash

export PATH=/home/james/bin:$PATH
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_Staging
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_Staging_Retry
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_MEMLEAKTEST
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_MEMLEAKTEST_Retry
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_MMSC
#monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_MMSC_Retry
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_APPROUTER
#monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_APPROUTER_Retry
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_RUPTEST
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_RUPTEST_Retry
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs yellowstone_QA_CLEAN

monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs QA-Valhalla-Traffic
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs valhalla_QA_CHAOS
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs valhalla_QA_CLEAN

monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs redwood_QA_FULLRUP
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs redwood_QA_TEST
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs redwood_QA_INSTALL_CURRENT

monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs nfv10_APPROUTER_QA_TEST
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs nfv10_MMSC_QA_TEST
monitor_job_and_speak.sh omn@hp-bl-06 /var/lib/jenkins/jobs system_test_regression_Docker_PRODUCTOMN-TC-NFV_LATEST_DRIVERhp-bl-06_SUTphinneas_SUSERnfv10








