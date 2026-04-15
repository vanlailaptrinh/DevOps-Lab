#!/bin/bash
echo "Rescanning SCSI devices..."

for i in /sys/class/scsi_host/host*/scan; do
    echo "- - -" > "$i"
done

echo "Rescan complete."