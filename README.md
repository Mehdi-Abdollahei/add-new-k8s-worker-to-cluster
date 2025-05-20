# 🚀 Add New Worker Node to RKE2 Kubernetes Cluster

This project fully automates the provisioning and configuration of a new **RKE2 worker node** using:

- **AWX** (Ansible UI)
- **Terraform**
- **Ansible**
- **vCenter/ESXi**
- **Jinja2 templates**


## 🧩 Project Overview

The goal is to **create a new virtual machine and join it to an existing RKE2 cluster** as a worker node. The workflow is triggered from **AWX** and driven by **Survey input** (e.g. VM specs like name, IP, gateway, etc).


## 📸 Architecture Diagram
![Add-k8s-worker-github (1)](https://github.com/user-attachments/assets/a59bdd87-659a-4d13-9f14-4dda3d3c4f4d)

## 🔁 Workflow Summary

1. **AWX Survey** collects VM specifications:
   - VM Name
   - IP Address
   - Gateway
   - Netmask
   - VLAN on ESXi
   - Master Node IP (for joining cluster)
   - Backup Tag (optional)

2. **Step 1**: `create-new-vm.yaml`
   - Triggers Terraform to create a new VM in vSphere

3. **Step 2**: `rke2-installation.yaml`
   - Installs RKE2 agent on the new VM

4. **Step 3**: `add-new-vm-to-k8s.yaml`
   - Applies config from Jinja2 template using survey values `rke2-config-worker.yaml.j2`
   - Starts and enables RKE2 service
   - Registers node with the RKE2 Kubernetes cluster

## 🧰 Tools & Technologies

| Tool            | Description                              |
|-----------------|------------------------------------------|
| **Terraform**    | Creates VMs in vSphere/ESXi              |
| **Ansible**      | Installs and configures RKE2             |
| **AWX**          | Executes workflows with survey prompts   |
| **GitLab**       | Stores Ansible playbooks                 |
| **RKE2**         | Lightweight Kubernetes distribution      |
| **Jinja2**       | Dynamically generates config files       |

---

## 🗂 Repository Structure

```bash
.
├── templates/
│   └── rke2-config-worker.yaml.j2     # RKE2 config template
├── main.yaml                          # Manage other these below playbbok
├── create-new-vm.yaml                 # Step 1: Trigger Terraform
├── rke2-installation.yaml             # Step 2: Install RKE2
├── add-new-vm-to-k8s.yaml             # Step 3: Join cluster
