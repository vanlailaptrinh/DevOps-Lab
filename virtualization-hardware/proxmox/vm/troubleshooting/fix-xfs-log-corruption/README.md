## Incident Report: XFS Log Recovery Failure (Proxmox VM)

### Context
- **Platform:** Proxmox VE
- **Guest OS:** Rocky Linux (XFS filesystem)
- **Storage:** LVM (`/dev/dm-0`)
- **Incident Type:** Filesystem Corruption / Boot Failure

---

### Problem Statement

The virtual machine failed to boot and entered **Emergency Mode** with the following error:

#### XFS (dm-0): log mount/recovery failed: error -117

- `XFS`: Filesystem in use
- `dm-0`: Logical Volume containing the root filesystem `/`
- `error -117`: XFS journal (log) replay failed during mount

As a result, the root filesystem could not be mounted, preventing the operating system from completing the boot process.

The root cause was identified as **XFS log corruption**, commonly triggered by:

- Hard stop / force power-off of the VM
- Using **Stop** instead of **Shutdown** in Proxmox
- Host crash or unexpected power loss

In this incident, the VM was terminated abruptly, causing XFS to leave its journal in an inconsistent state. During the next boot, XFS failed to replay the log and refused to mount the filesystem.

---

### 1️⃣ Initial Boot Failure (specifically on 2 vm)

![Initial boot failure](./assets/01-error-vm1.png)

![Initial boot failure](./assets/01-error-vm1.png)

The system dropped into **Emergency Mode** as the root filesystem could not be mounted.

---

### 2️⃣ Filesystem Check

![Filesystem check](./assets/02-check.png)

The affected filesystem was identified on the LVM device `dm-0`, confirming the root partition was impacted.

--- 

### 3️⃣ Repair Execution

![Repair execution](./assets/03-fix-cmd.png)

The `xfs_repair` utility was executed from Emergency Mode to attempt filesystem recovery.

--- 

### 4️⃣ Repair Output

![Repair output](./assets/04-fix-log.png)

The XFS log was cleared using the `-L` option, allowing the filesystem structure to be repaired.

---

### 5️⃣ Reboot Sequence

![Reboot sequence](./assets/05-reboot.png)

After completing the repair process, the VM was rebooted.

---

### 6️⃣ Successful Boot

![Successful boot](./assets/06-success.png)

The system booted successfully, and all services were restored to a healthy state.







