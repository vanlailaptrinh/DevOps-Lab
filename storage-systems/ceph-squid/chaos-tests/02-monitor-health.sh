#!/bin/bash

LOG_FILE="ceph_cluster_health.log"

echo "Starting full Ceph cluster health monitoring (1s interval)..." | tee -a $LOG_FILE
echo "Press [Ctrl + C] to stop." | tee -a $LOG_FILE
echo "Logs are being written simultaneously to file: $LOG_FILE" | tee -a $LOG_FILE
echo "=======================================================================" | tee -a $LOG_FILE

while true; do
    echo -e "\n  [$(date +'%Y-%m-%d %H:%M:%S')] ----------------------------------------" | tee -a $LOG_FILE
    
    echo ">>> CEPH STATUS (ceph -s) <<<" | tee -a $LOG_FILE
    ceph -s | tee -a $LOG_FILE
    
    echo -e "\n>>> HEALTH DETAILS (ceph health detail) <<<" | tee -a $LOG_FILE
    ceph health detail | tee -a $LOG_FILE
    
    sleep 1
done