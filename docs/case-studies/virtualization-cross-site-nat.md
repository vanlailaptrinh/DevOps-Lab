# Case Study: Cross-Site VM Communication Behind Double NAT (Proxmox)

## Architecture

```
[Home/Office Router 192.168.1.1]
          |
    [Ubuntu Host - VMware Workstation 17 Pro]
          |
    ┌─────┴─────┐
    │           │
[PVE 1]     [PVE 2]
Main Site    DR Site
192.168.1.100  192.168.1.200
(vmbr0)      (vmbr0)
    │           │
[vmbr1 NAT]  [vmbr1 NAT]
172.27.27.0/24  192.168.100.0/24
    │           │
[Windows Server]  [Windows Server]
[MSSQL 2022]    [MSSQL 2022]
172.27.27.37    192.168.100.203
```

## Context

The goal of this lab is to replicate a real-world DR (Disaster Recovery) setup: two Proxmox sites, each running a Windows Server with MS SQL Server 2022, intended to sync via **SQL Server Always On Availability Groups**. For replication to work, the VMs on both sites must be able to reach each other at the network level.

---

## The Two Questions

### `ping 8.8.8.8` → OK (Why?)

Each Proxmox node has NAT configured on `vmbr1`. When a VM pings the internet, Proxmox translates the private IP (`172.27.27.x` or `192.168.100.x`) to the node's external IP (`192.168.1.100` / `192.168.1.200`) before sending it out. Outbound internet works fine.

### `172.27.27.37` → ping → `192.168.100.203` → ???

This is where it breaks down. Try it yourself:

```
Reply from 172.27.27.37: Request Timed Out
```

**Why?** The VM at Main site tries to reach `192.168.100.203`. Its traffic hits the NAT boundary at PVE 1 — and stops. PVE 1 has no route to `192.168.100.0/24`, and PVE 2 has no route back to `172.27.27.0/24`. The two private networks are completely isolated from each other, hidden behind their respective NATs.

| Test | Result |
|------|--------|
| VM (Main) → `8.8.8.8` | ✅ OK — NAT handles it |
| VM (DR) → `8.8.8.8` | ✅ OK — NAT handles it |
| VM (Main) → VM (DR) | ❌ Request Timed Out |
| VM (DR) → VM (Main) | ❌ Request Timed Out |

---

## The Problem

Both VM subnets are **behind NAT**, meaning:

- Neither subnet is routable from the outside.
- The two Proxmox nodes share the same physical LAN (`192.168.1.0/24`) but have no configured path between their internal VM networks.
- Standard routing alone cannot solve this — you cannot add a static route to a NATed subnet that you don't control the gateway for.

SQL Server Always On requires stable, bidirectional TCP connectivity between nodes. Without VM-to-VM reachability, replication is impossible.

---

## Challenge

> How do you establish direct, routable connectivity between `172.27.27.0/24` (Main) and `192.168.100.0/24` (DR) given that both are behind NAT?

Think about what options exist when two endpoints share a common network (`192.168.1.0/24`) but their internal subnets are not exposed...

> 💡 **Hint:** The two Proxmox nodes can see each other on `192.168.1.0/24`. If there were a way to create an **encrypted tunnel** between them — one that bridges their private subnets — the VMs wouldn't need to know anything about NAT at all.