# 🏛️ Centralized Infrastructure & DevOps Configuration Repository

![Role](https://img.shields.io/badge/Role-DevOps_Engineering-blue?style=for-the-badge&logo=linux)
![Context](https://img.shields.io/badge/Context-XPERC-orange?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-IaC_&_Distributed_Systems-red?style=for-the-badge)

## 📖 Overview
This repository serves as the **centralized source of truth** for Infrastructure as Code (IaC), deployment manifests, and system configurations. It contains the operational code, scripts, and state files required to provision, configure, and maintain complex distributed environments, ranging from **High Performance Computing (HPC)** clusters to **Multi-site Disaster Recovery (DR)** architectures.

The structure is organized by **functional domains** rather than isolated tools, reflecting a comprehensive, system-oriented architectural approach to infrastructure management.

## 🏗️ Domain Configurations & Managed Architectures

### 1. Database Clusters & Distributed Data 🛢️
**Stored Artifacts:** High Availability (HA) configurations, failover scripts, and replication topologies for SQL/NoSQL systems.
* **MSSQL High Availability:** Configurations for **Multi-site DR** (2 Sites, 3 nodes/site) utilizing **WSFC** & **Always On Availability Groups (AG)**, including **Distributed Availability Group (DAG)** networking over VPN.
* **PostgreSQL HA:** Cluster manifests and configuration files for a 3-node HA setup using **Patroni**, **Etcd**, and **Consul**.
* **Dgraph:** Deployment manifests for distributed Graph Database architectures (WIP).

### 2. High Performance Computing (HPC) 🚀
**Stored Artifacts:** Workload manager configurations, node definitions, and job scheduling scripts.
* **Slurm Cluster:** Control node and compute node configuration files (`slurm.conf`, cgroups) for CFD simulations.
* **Simulation Workloads:** Optimized resource allocation scripts for **Ansys Fluent 2022R1** and **OpenFOAM** environments on Rocky Linux.

### 3. Traffic Management & Networking 🌐
**Stored Artifacts:** Proxy routing rules, overlay network configs, and Load Balancer definitions.
* **Load Balancing:** **HAProxy** routing configurations and **Keepalived** (VRRP) definitions for seamless stateful failover.
* **VPN Tunneling:** Routing tables and peer configurations for **NetBird** (Self-hosted) & **WireGuard** Site-to-Site connections.
* **Network Bonding:** LACP and Active-Backup bonding configurations for Proxmox hypervisors.
* **API Gateway:** **Kong API Gateway** declarative routing and plugin configurations.

### 4. Storage Systems 🐙
**Stored Artifacts:** Storage topology maps, daemon configurations, and disaster recovery scripts.
* **Ceph Reef (v18.2.7):** * `ceph.conf` and deployment specs for a 5-node distributed cluster (MON, OSD, RGW).
    * Custom **CRUSH Map** definitions, Placement Groups (PGs) tuning configurations, and automated Fault Tolerance testing scripts.

### 5. Kubernetes & DevSecOps ⚓
**Stored Artifacts:** YAML manifests, Helm values, and CI/CD pipeline definitions.
* **Cluster Ops:** Kubeadm initialization configs and **MetalLB** (Layer 2) routing manifests.
* **CI/CD Pipelines:** Declarative **Jenkinsfiles** integrated with **Trivy** (Security Scanning), **Harbor** (Registry), and **JFrog** (Artifact Storage).
* **Optimization:** Custom DaemonSet manifests for cluster-wide node maintenance and automated image pruning.

### 6. Security & Identity Management 🔐
**Stored Artifacts:** Access policies, realm configurations, and TLS management.
* **Keycloak:** JSON realm exports and configurations for SSO and OIDC integration across internal infrastructure services.

## 📂 Repository Structure

```text
devops-lab/
├── 📂 database-clusters/           # Patroni YAMLs, Postgres conf, MSSQL AG scripts
├── 📂 high-performance-computing/  # slurm.conf, munge keys, Ansys job bash scripts
├── 📂 traffic-network/             # haproxy.cfg, keepalived.conf, wireguard wg0.conf
├── 📂 storage-systems/             # ceph.conf, CRUSH maps, RGW tuning parameters
├── 📂 kubernetes-ecosystem/        # K8s YAML manifests, Jenkinsfiles, Helm values
├── 📂 security-identity/           # Keycloak realm exports, OIDC configurations
├── 📂 virtualization-hardware/     # Proxmox /etc/network/interfaces, Bond configs
└── 📂 docs/                        # Architecture diagrams (Draw.io/Mermaid) & Reports
