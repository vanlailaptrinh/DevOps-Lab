#!/bin/bash

VM_IDS="103 105 106 113 114 115"

TIMEOUT=60
# ---------------------

echo "--- Starting bulk VM SHUTDOWN process ---"

for VMID in $VM_IDS; do
    # Check if VM exists
    if qm status $VMID > /dev/null 2>&1; then
        
        # Check current status
        STATUS=$(qm status $VMID | awk '{print $2}')
        
        if [ "$STATUS" == "running" ]; then
            echo "Sending shutdown signal to VM $VMID..."
            qm shutdown $VMID
            
            # Loop to check if it actually stopped
            waited=0
            while [ "$(qm status $VMID | awk '{print $2}')" == "running" ]; do
                sleep 2
                waited=$((waited+2))
                
                # Check timeout
                if [ $waited -ge $TIMEOUT ]; then
                    echo "WARNING: Timeout reached ($TIMEOUT s). VM $VMID is still running."
                    echo "Moving to next VM..."
                    break
                fi
            done
            
            # Final check message
            NEW_STATUS=$(qm status $VMID | awk '{print $2}')
            if [ "$NEW_STATUS" == "stopped" ]; then
                echo "VM $VMID has stopped successfully."
            fi
            
        else
            echo "VM $VMID is already stopped. Skipping."
        fi
    else
        echo "Error: VM ID $VMID not found."
    fi
    echo "--------------------------------"
done

echo "--- Completed ---"