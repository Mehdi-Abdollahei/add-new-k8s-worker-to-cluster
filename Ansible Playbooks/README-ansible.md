All Ansible playbooks used in this project are stored in a GitLab repository, which serves as the primary source of playbooks.

## 🗂 Repository Structure
├── templates/
│   └── rke2-config-worker.yaml.j2     # RKE2 config template
├── main.yaml                          # Workflow entry point
├── create-new-vm.yaml                 # Step 1: Trigger Terraform
├── rke2-installation.yaml             # Step 2: Install RKE2
├── add-new-vm-to-k8s.yaml             # Step 3: Join cluster
