# ⚙️ Terraform Integration: VM Creation via Ansible

This project provisions a new VM on **vSphere/ESXi** using **Terraform**, which is triggered remotely by **Ansible** from the `create-new-vm.yaml` playbook.

---

## 🧱 Terraform Execution Flow

- Terraform is installed on a **Virtual Machine**
- Ansible connects to this server over SSH using `delegate_to`
- **AWX Survey** collects VM specifications, which are passed directly to Terraform using `-var` flags (no `terraform.tfvars` file is created)
