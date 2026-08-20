# 02-vmware-vmmon-vmnet-secure-boot-remediation

## Initial State

| Item | Value |
|---|---|
| Product | VMware® Workstation 17 Pro |
| Version | 17.6.2 build-24409262 |
| Linux Kernel | 6.8.0-136-generic (checked using `uname -r`) |
| OS | Ubuntu 22.04.5 LTS (checked using `hostnamectl`) |

## vmmon (Virtual Machine Monitor)

**Role:**
A host-side kernel module for VMware Workstation that provides the kernel-side components required for VMware virtualization.

**Location:**
Linux Kernel Space — built as `vmmon.ko` and loaded into the currently running kernel.

**Main responsibilities:**
- Interfaces with CPU hardware virtualization mechanisms such as Intel VT-x / AMD-V.
- Provides a kernel-side interface for communication between the VMware VMM/User Space and the host virtualization subsystem.
- Manages the low-level resources and mechanisms required to execute virtual machines.
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

## 1. Build and Install the VMware Host Kernel Modules

**Purpose:**
Ask VMware to check, build, and install the required VMware Workstation host kernel modules for the currently running Linux kernel.

```bash
sudo vmware-modconfig --console --install-all
```

**Log detail:**
`/virtualization-hardware/vmware/case study/load_vmmon_problem/log_1.logs`

**Output:**

```
+ LD [M]  /tmp/modconfig-sqzhkZ/vmmon-only/vmmon.ko
```
→ `vmmon.ko` was successfully created.

```
+ LD [M]  /tmp/modconfig-sqzhkZ/vmnet-only/vmnet.ko
```
→ `vmnet.ko` was successfully built.

However, when VMware attempted to start its services:

```
+ Starting VMware services:
   Virtual machine monitor                                            failed
   Virtual machine communication interface                             done
   VM communication interface socket family                            done
   Virtual ethernet                                                   failed
   VMware Authentication Daemon                                        done


Unable to start services
```

**Interpretation:**

`vmware-modconfig` successfully compiled `vmmon.ko` and `vmnet.ko`, but VMware could not start the corresponding services.

At this point, the log does not yet show the exact reason why the kernel rejected the modules.

## 2. Attempt to Load the Modules into the Running Kernel

**Purpose:**
Ask the Linux kernel to load the vmmon and vmnet modules into the currently running kernel.

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

is commonly associated with a kernel module signature / Secure Boot trust issue.

## 3. Verify Secure Boot Status

### 3.1 Check whether Secure Boot is enabled

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

The following command filters the Linux kernel log for messages related to kernel modules, signatures, and keys:

```bash
sudo dmesg | grep -iE 'module|signature|key'
```

**Log detail:**
`/virtualization-hardware/vmware/case study/load_vmmon_problem/log_3.logs`

**Interpretation:**

The kernel log shows that Linux is performing module signature verification, and VMware modules are being rejected.

## Solution: Sign the VMware Kernel Modules

### 1. Generate a key pair for module signing

Create a directory for the signing keys:

```bash
mkdir -p ~/module-signing
cd ~/module-signing
```

Generate a private key and a self-signed certificate:

```bash
openssl req -new -x509 -newkey rsa:2048 \
  -keyout MOK.priv \
  -outform DER \
  -out MOK.der \
  -nodes \
  -days 36500 \
  -subj "/CN=VMware Kernel Module Signing/"
```

This creates:
- `MOK.priv` → private key used to sign the kernel modules.
- `MOK.der` → public certificate that will be enrolled into the system's Machine Owner Key (MOK) database.

### 2. Enroll the public key into MOK

Import the certificate into MOK:

```bash
sudo mokutil --import MOK.der
```

Then reboot:

```bash
sudo reboot
```

When the system boots, the MOK Manager screen should appear.

Select:

```
Enroll MOK
    ↓
Continue
    ↓
Yes
    ↓
Enter password
    ↓
Reboot
```

After the reboot, the certificate should be enrolled and trusted by the system.

### 3. Verify that the certificate was enrolled

```bash
mokutil --list-enrolled | grep 'VMware Kernel Module Signing'
```

The command should return the enrolled VMware module-signing certificate.

### 4. Identify the exact .ko module paths

Check where the modules are located:

```bash
modinfo vmmon | grep filename
modinfo vmnet | grep filename
```

This ensures that the correct `vmmon.ko` and `vmnet.ko` files are signed.

### 5. Sign vmmon.ko and vmnet.ko

Sign `vmmon.ko`:

```bash
sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file \
    sha256 \
    ~/module-signing/MOK.priv \
    ~/module-signing/MOK.der \
    /lib/modules/$(uname -r)/misc/vmmon.ko
```

Sign `vmnet.ko`:

```bash
sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file \
    sha256 \
    ~/module-signing/MOK.priv \
    ~/module-signing/MOK.der \
    /lib/modules/$(uname -r)/misc/vmnet.ko
```

The `sign-file` script is provided by the Linux kernel headers and is used to add a cryptographic signature to the kernel modules.

### 6. Verify the module signatures

For vmmon:

```bash
modinfo vmmon | grep -E 'filename|signer|sig_key|sig_id'
```

For vmnet:

```bash
modinfo vmnet | grep -E 'filename|signer|sig_key|sig_id'
```

Expected information should include the certificate identity under the `signer` field.

### 7. Update module dependencies

```bash
sudo depmod -a
```

This updates the kernel module dependency database so that the newly signed modules are correctly recognized.

### 8. Load the kernel modules

Load vmmon:

```bash
sudo modprobe vmmon
```

Load vmnet:

```bash
sudo modprobe vmnet
```

Check whether the modules are loaded:

```bash
lsmod | grep -E 'vmmon|vmnet'
```

If successful, both `vmmon` and `vmnet` should appear in the output.

### 9. Restart VMware

Restart the VMware service:

```bash
sudo systemctl restart vmware
```

At this point, VMware should be able to load the signed `vmmon.ko` and `vmnet.ko` modules while UEFI Secure Boot remains enabled.

## Overall Flow

```
VMware Workstation
        │
        ▼
vmmon.ko / vmnet.ko
        │
        ▼
Modules successfully compiled
        │
        ▼
UEFI Secure Boot enabled
        │
        ▼
Kernel verifies module signature
        │
        ▼
Signature not trusted
        │
        ▼
"Key was rejected by service"
        │
        ▼
Kernel rejects modules
        │
        ▼
VMware services fail
        │
        ▼
Generate MOK key pair
        │
        ▼
Enroll MOK certificate
        │
        ▼
Sign vmmon.ko / vmnet.ko
        │
        ▼
Update module dependencies
        │
        ▼
Load vmmon / vmnet
        │
        ▼
Restart VMware
        │
        ▼
VM can start successfully
```