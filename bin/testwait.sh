#!/bin/bash
sleep 300 &
jobs
ps -elf |grep sleep

