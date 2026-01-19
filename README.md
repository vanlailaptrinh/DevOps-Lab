# 🏛️ Infrastructure & DevOps Engineering Lab

![Role](https://img.shields.io/badge/Role-DevOps_Intern-blue?style=for-the-badge&logo=linux)
![Context](https://img.shields.io/badge/Context-XPERC_Internship-orange?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-HPC_&_Distributed_Systems-red?style=for-the-badge)

## 📖 Introduction
Welcome to my engineering repository. This project documents my journey in designing, deploying, and maintaining complex infrastructure systems, ranging from **High Performance Computing (HPC)** to **Multi-site Disaster Recovery (DR)** solutions.

This repository is organized by **functional domains** rather than just tool names, reflecting a system-oriented architectural approach.

## 🏗️ Architecture & Projects

### 1. Database Clusters & Distributed Data 🛢️
**Scope:** SQL, NoSQL, and Graph Databases.
* **MSSQL High Availability:**
    * Deployed **Multi-site DR** (2 Sites, 3 nodes/site) using **WSFC** & **Always On Availability Groups (AG)**.
    * Linked sites via **Distributed Availability Group (DAG)** over VPN.
* **PostgreSQL HA:** Built a 3-node cluster using **Patroni**, **Etcd**, and **Consul**.
* **Dgraph (Planned):** Researching distributed Graph Database implementation.

### 2. High Performance Computing (HPC) 🚀
**Scope:** Simulation processing & Job Scheduling.
* **Slurm Cluster:** Deployed workload manager for CFD simulations.
* **Simulation Jobs:** Optimized resource scheduling for **Ansys Fluent 2022R1** and **OpenFOAM** on Rocky Linux.
* **Benchmarks:** Performance testing on variable core configurations.

### 3. Traffic Management & Networking 🌐
**Scope:** L4/L7 Load Balancing, API Gateway, and Overlay Networks.
* **Load Balancing:** **HAProxy** + **Keepalived** (VRRP) for stable failover.
* **VPN Tunneling:** **NetBird** (Self-hosted) & **WireGuard** for Site-to-Site connectivity.
* **Network Bonding:** Configured Linux Bonding on Proxmox to minimize packet loss during NIC failure.
* **API Gateway (In Progress):** Setting up **Kong API Gateway** for centralized traffic control.

### 4. Storage Systems 🐙
**Scope:** Distributed Block/Object Storage.
* **Ceph Reef (v18.2.7):**
    * Deployed and upgraded a 5-node cluster (MON, OSD, RGW).
    * **Deep Dive:** CRUSH Map analysis, Placement Groups (PGs) calculation, and Fault Tolerance testing.

### 5. Kubernetes & DevSecOps ⚓
**Scope:** Container Orchestration & CI/CD.
* **Cluster Ops:** Kubeadm setup with **MetalLB** (Layer 2).
* **CI/CD Pipeline:** Jenkins pipelines integrated with **Trivy** (Security Scan), **Harbor** (Registry), and **JFrog** (Artifacts).
* **Optimization:** Custom DaemonSets for automated image cleanup.

### 6. Security & Identity Management 🔐
**Scope:** IAM & Certificates.
* **Keycloak (Planned):** Implementing SSO (Single Sign-On) and OIDC for internal services.

## 📂 Repository Structure

```text
devops-lab/
├── 📂 database-clusters/           # MSSQL AG, Postgres Patroni, Dgraph
├── 📂 high-performance-computing/  # Slurm configs, Ansys job scripts
├── 📂 traffic-network/             # HAProxy, NetBird, Kong API Gateway
├── 📂 storage-systems/             # Ceph deployment & RGW tests
├── 📂 kubernetes-ecosystem/        # K8s manifests, Jenkins, Harbor
├── 📂 security-identity/           # Keycloak IAM configs
├── 📂 virtualization-hardware/     # Proxmox network bond, Hardware ops logs
└── 📂 docs/                        # Architectural diagrams & PDF reports