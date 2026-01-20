#!/bin/bash

END_TIME=$((SECONDS + 30))

BUCKETS_5=("dev-01" "dev-02" "stag-01" "stag-02" "prod-01")
BUCKET_HOT="prod-02"

list_5_buckets() {
  while [ $SECONDS -lt $END_TIME ]; do
    for b in "${BUCKETS_5[@]}"; do
      echo "[$(date '+%H:%M:%S')] [5S] s3cmd ls s3://$b"
      s3cmd ls s3://$b >/dev/null
    done
    sleep 5
  done
}

list_hot_bucket() {
  while [ $SECONDS -lt $END_TIME ]; do
    echo "[$(date '+%H:%M:%S')] [HOT] s3cmd ls s3://$BUCKET_HOT"
    s3cmd ls s3://$BUCKET_HOT >/dev/null
  done
}


list_5_buckets &
list_hot_bucket &

wait
echo "Done list load test"