LOGFILE=builderr.log
echo "\nDATE=$(date)" |tee -a builderr.log
tail -3 plv-Master.log |tee -a builderr.log
#grep -C7 -E "Error|failed|oikes" plv*.log |tee -a builderr.log
grep -B1 -A3 -E "Error | failed|Zoikes|Yikes|No such|workareas|\[javac\]" plv*.log |grep -Ev " Delete "|tee -a builderr.log

# logrotate not working
#cat > builderr.logrotate.config <<EOF
#"builderr.log" {
# rotate 25
#}
#EOF
#logrotate -s builderr.logrotate.state builderr.logrotate.config

