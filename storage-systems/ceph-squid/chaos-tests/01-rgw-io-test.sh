#!/bin/bash

BUCKET="s3://prod-01"
LOG_FILE="s3_insert_data.log"

s3cmd mb $BUCKET 2>/dev/null

echo "Starting continuous data injection into RGW..." | tee -a $LOG_FILE
echo "Rate: 1 file / 2 seconds." | tee -a $LOG_FILE
echo "Press [Ctrl + C] to stop at any time!" | tee -a $LOG_FILE
echo "Logs are being written simultaneously to file: $LOG_FILE" | tee -a $LOG_FILE
echo "---------------------------------------------------" | tee -a $LOG_FILE

i=1
while true; do
    FILENAME="data_file_${i}.txt"
    
    echo "Important file number $i - Generated at $(date)" > $FILENAME
    head -c 5000 /dev/urandom | base64 >> $FILENAME
    
    s3cmd put $FILENAME $BUCKET/$FILENAME -q
    
    if [ $? -eq 0 ]; then
        echo "[$(date +'%H:%M:%S')] Successfully uploaded: $FILENAME" | tee -a $LOG_FILE
    else
        echo "[$(date +'%H:%M:%S')] I/O stall detected at: $FILENAME (Ceph peering/recovery in progress?)" | tee -a $LOG_FILE
    fi
    
    rm -f $FILENAME
    
    ((i++))
    sleep 2
done