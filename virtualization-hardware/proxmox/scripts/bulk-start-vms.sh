VM_IDS="100 101 102 105"

DELAY=3
# ---------------------
echo "--- Starting bulk VM startup process ---"

for VMID in $VM_IDS; do
    if qm status $VMID > /dev/null 2>&1; then
        
        STATUS=$(qm status $VMID | awk '{print $2}')
        
        if [ "$STATUS" == "stopped" ]; then
            echo "Starting VM $VMID..."
            qm start $VMID
            echo "Waiting $DELAY seconds..."
            sleep $DELAY
        else
            echo "VM $VMID is already running (status: $STATUS). Skipping."
        fi
    else
        echo "Error: VM ID $VMID not found."
    fi
done

echo "--- Completed ---"