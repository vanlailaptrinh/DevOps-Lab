#!/bin/bash

BUCKET="s3://prod-01"

s3cmd mb $BUCKET

echo "Injecting 500 seed files into Ceph RGW..."

for i in {1..500}; do

    FILENAME="data_file_${i}.txt"

    echo "Important file number $i - Generated at $(date)" > $FILENAME

    head -c 5000 /dev/urandom | base64 >> $FILENAME

    s3cmd put $FILENAME $BUCKET/$FILENAME -q

    rm -f $FILENAME

    if (( i % 50 == 0 )); then
        echo "Injected $i / 500 files..."
    fi

done

echo "Data insertion completed!"