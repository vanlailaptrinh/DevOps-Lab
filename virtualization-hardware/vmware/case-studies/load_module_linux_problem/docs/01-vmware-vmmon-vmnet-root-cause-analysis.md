# 01-vmware-vmmon-vmnet-root-cause-analysis

## Initial State

| Item | Value |
|---|---|
| Product | VMware® Workstation 17 Pro |
| Version | 17.6.2 build-24409262 |
| Linux Kernel | 6.8.0-136-generic (checked using `uname -r`) |
| OS | Ubuntu 22.04.5 LTS (checked using `hostnamectl`) |

## vmmon (Virtual Machine Monitor)

**Role:**
A VMware Workstation host kernel module that provides the kernel-side components required for virtualization.

**Location:**
Linux Kernel Space — built as `vmmon.ko` and loaded into the currently running kernel.

**Main responsibilities:**
- Interfaces with CPU hardware virtualization mechanisms such as Intel VT-x / AMD-V.
- Provides the kernel-side interface for communication between the VMware VMM/userspace and the host virtualization subsystem.
- Manages low-level resources and mechanisms required to execute virtual machines.
- Exposes the character device `/dev/vmmon` for communication between VMware userspace components and the kernel module.

## vmnet (Virtual Networking)

**Role:**
A kernel module that provides the kernel-side networking functionality for VMware virtual machines.

**Location:**
Linux Kernel Space — built as `vmnet.ko`.

**Main responsibilities:**
- Provides VMware's virtual networking components.
- Connects the VM's virtual NIC to the host's networking stack.
- Supports networking modes such as Bridged, NAT, and Host-only.
- Handles and routes traffic between the VM, host, and physical network depending on the selected network mode.

## VMware Kernel Module Architecture

```
VMware Workstation
       │
       ├───────────────┐
       │               │
       ▼               ▼
    vmmon.ko        vmnet.ko
       │               │
       ▼               ▼
   Virtualization    Networking
       │               │
       └───────┬───────┘
               ▼
          Linux Kernel
               │
               ▼
       Physical Hardware
```

## Problem

VMware cannot start the virtual machine because the `vmmon.ko` and `vmnet.ko` kernel modules were successfully built for the current kernel, but they are not signed with a signature trusted by the kernel, while UEFI Secure Boot is enabled.

As a result, the Linux kernel rejects the modules when VMware attempts to load them.

```
Kernel update
    ↓
VMware rebuilds vmmon/vmnet
    ↓
Secure Boot checks module signatures
    ↓
Signature is not trusted
    ↓
Kernel rejects the modules
    ↓
VMware cannot start the VM
```

## 1. Build and Install the VMware Host Kernel Modules

**Command:**

```bash
sudo vmware-modconfig --console --install-all
```

**Log detail:**
`/virtualization-hardware/vmware/case study/load_vmmon_problem/log_1.logs`

**Relevant output:**

```
+ LD [M]  /tmp/modconfig-sqzhkZ/vmmon-only/vmmon.ko
```
→ `vmmon.ko` was successfully built.

```
+ LD [M]  /tmp/modconfig-sqzhkZ/vmnet-only/vmnet.ko
```
→ `vmnet.ko` was successfully built.

However, when VMware attempted to start its services:

```
Starting VMware services:
   Virtual machine monitor                                            failed
   Virtual machine communication interface                             done
   VM communication interface socket family                            done
   Virtual ethernet                                                   failed
   VMware Authentication Daemon                                        done


Unable to start services
```

**Interpretation:**

`vmware-modconfig` successfully compiled `vmmon.ko` and `vmnet.ko`, but VMware was unable to start the corresponding services.

At this point, the log does not yet show the exact reason why the kernel rejected the modules.

## 2. Attempt to Load the Modules into the Running Kernel

**Commands:**

```bash
sudo modprobe vmmon
sudo modprobe vmnet
```

**Log detail:**
`/virtualization-hardware/vmware/case study/load_vmmon_problem/log_2.logs`

**Output:**

```
modprobe: ERROR: could not insert 'vmmon': Key was rejected by service
```

**Interpretation:**

Linux successfully located the vmmon module, but the kernel refused to load it.

The message:

```
Key was rejected by service
```

strongly indicates a kernel module signature / Secure Boot trust issue.

## 3. Verify Secure Boot Status

### 3.1 Check whether Secure Boot is enabled

**Command:**

```bash
mokutil --sb-state
```

**Log detail:**
`/virtualization-hardware/vmware/case study/load_vmmon_problem/log_3.logs`

**Output:**

```
SecureBoot enabled
```

→ UEFI Secure Boot is enabled.

### 3.2 Check kernel logs for module-signing errors

**Command:**

```bash
sudo dmesg | grep -iE 'module|signature|key'
```

**Log detail:**
`/virtualization-hardware/vmware/case study/load_vmmon_problem/log_3.logs`

**Interpretation:**

The kernel log shows that Linux is performing kernel module signature verification, and the VMware modules are being rejected during this process.

Therefore, the evidence points to the following root cause:

```
vmmon.ko / vmnet.ko
        ↓
Successfully compiled
        ↓
Attempt to load into Linux kernel
        ↓
UEFI Secure Boot = enabled
        ↓
Kernel verifies module signature
        ↓
Module signature is not trusted
        ↓
Kernel rejects module
        ↓
VMware services fail to start
        ↓
VM cannot run
```