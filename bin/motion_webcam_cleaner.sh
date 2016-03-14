#!/bin/bash
find /var/motion -name "*.avi"  -mtime +30 -exec rm {} \;
find /var/motion -name "*.jpeg"  -mtime +30 -exec rm {} \;
find /var/motion -name "*.mpg"  -mtime +180 -exec rm {} \;



