#!/bin/bash

LOG_FILE="pg_osd0_monitor.log"

echo "Identifying PGs where OSD 0 is the Primary..."
TARGET_PGS=$(ceph pg ls-by-pool default.rgw.buckets.data | grep ']p0 ' | awk '{print $1}' | tr '\n' '|' | sed 's/|$//')

echo "Target PGs locked: $TARGET_PGS"
echo "Logging to file: $LOG_FILE. Press [Ctrl + C] to stop."
echo "--------------------------------------------------------------------------------"

echo -e "TIME\tPG_ID\tSTATE\t\tUP_SET\t\tACTING_SET" | tee -a $LOG_FILE

while true; do
    NOW=$(date +'%H:%M:%S')
    
    ceph pg ls-by-pool default.rgw.buckets.data | grep -E "^($TARGET_PGS)\s" | awk -v time="$NOW" '{printf "%s\t%-5s\t%-15s\t%-15s\t%-15s\n", time, $1, $11, $15, $16}' | tee -a $LOG_FILE
    
    sleep 1
done