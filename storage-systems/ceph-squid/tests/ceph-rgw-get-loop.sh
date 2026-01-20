#!/bin/bash
# ------------------------------------------------------------------
# Script Name: ceph-rgw-get-loop.sh
# Description: Generates continuous READ traffic (GET requests) to Ceph RGW
#              to trigger Prometheus/Grafana metrics.
# Author:      [Van Tran]
# Target:      Bucket: prod-02 | File: testfile.10MB
# Usage:       ./ceph-rgw-get-loop.sh
# ------------------------------------------------------------------

TARGET_BUCKET="s3://prod-02"
TARGET_FILE="testfile.10MB"

echo "[INFO] Starting S3 Read Load Generator against ${TARGET_BUCKET}..."
echo "[INFO] Press Ctrl+C to stop."

while true; do 
    s3cmd get "${TARGET_BUCKET}/${TARGET_FILE}" /dev/null --force >/dev/null 2>&1
    echo -n "."
done