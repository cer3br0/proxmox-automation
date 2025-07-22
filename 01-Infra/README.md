# Proxmox VM Automation with Terraform

# Terraform 

## Projet structure  

```
01-Infra/
├── main.tf              # main terraform file
├── variables.tf         # root vars
├── outputs.tf           # root outputs
├── providers.tf         # providers configuration
├── terraform.tfvars     # Vars values
├── scripts/             # Bash script for ansible automation
└── modules/
    └── vm/
        ├── main.tf      # module VM resources
        ├── variables.tf # module vars
        └── outputs.tf   # module outputs
```

## Configuration

### Vars files

Copy the template variable file and customize it :
```bash
cp example.terraform.tfvars terraform.tfvars
```
## How to use

### Deployment

```bash
# Create terraform working directory
terraform init

# Deployment verification
terraform plan

# Apply deployment/change
terraform apply
```

### Configurations examples

#### Simple VM (Development)
```hcl
{
  name = "dev-vm"
  target_node = "proxmox-node-1"
  template = "ubuntu-22.04-template"
  cores = 2
  memory = 4096
  disk_size = "50G"
  disk_storage = "local-lvm"
}
```

#### VM with Cloud-init
```hcl
{
  name = "web-server"
  target_node = "proxmox-node-1"
  template = "ubuntu-22.04-template"
  cores = 4
  memory = 8192
  disk_size = "100G"
  disk_storage = "local-lvm"
  cloud_init = {
    user = "ansible"
    ssh_keys = ["ssh-rsa AAAAB..."]
    ip_config = {
      ip = "192.168.1.100/24"
      gateway = "192.168.1.1"
    }
  }
  tags = ["web", "production"]
}
```

## Suggested template 

| Profil | CPU | RAM | Disk | Usage |
|--------|-----|-----|--------|-------|
| Micro | 1 | 1GB | 20G | Tests, light dev  |
| Small | 2 | 4GB | 50G | Web services|
| Medium | 4 | 8GB | 100G | Web apps |
| Big | 8 | 16GB | 500G | Database |
| Very big | 16+ | 32GB+ | 1TB+ | Big data, virtualisation |

## Important variables

### Provider config (Proxmox)
```hcl
proxmox_api_url = Promox API url # (ex: "https://yourprox:8006/api2/json")
proxmox_user = User or API token # (ex: "terraform-user@pve!terraform-token")
proxmox_password = Password or API secret # Use API for best practice
proxmox_tls_insecure = false # false for self-signed certificates
```

### VM basic config
```hcl
name = VM name
template = Name of the template to use
cores = Cores numbers
memory = RAM in MB
disk_size = Size of the disk (ex: "50G")
disk_storage = Proxmox storage name
```

## Outputs available

Module provide some outputs for VM information :

```bash
# See all main information for all VMs
terraform output vms_info

# See only the IP address
terraform output vm_ips
```

# Ansible integration 

## For ansible information and configuration, please look at the README.md in each roles directory **./02-Config/roles/**

Terraform output are used to add/remove lines in the file ./02-Config/inventory.ini via bash scripting ./01-Infra/scripts using a "null_resource" and provisionner local-exec for script executing  

```hcl
resource "null_resource" "update_inventory" {
  for_each = module.vms

  triggers = {
    name     = each.value.vm_name
    template = each.value.template
    ip       = each.value.ip_address
  }

  provisioner "local-exec" {
    when    = create
    command = "bash ./scripts/add_to_inventory.sh '${self.triggers.name}' '${self.triggers.ip}' '${self.triggers.template}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ./scripts/remove_from_inventory.sh '${self.triggers.name}'"
  }

  depends_on = [module.vms]
}
```

Four pieces of information are used in the script to customize the inventory file to add ansible hosts, 3 of it are provided by terraform output :  
```bash
VM_NAME="$1"
VM_IP="$2"
TEMPLATE_NAME="$3"
INVENTORY_FILE="../02-Config/inventory.ini"
```

This script is made actualy for 3 groups depending of the template used in terraform, you can easily customize it by editing "./01-Infra/scripts/add_to_inventory.sh" :   
```bash
if [[ "$TEMPLATE_NAME" == *deb* ]]; then
  GROUP="Deb-SRV"
elif [[ "$TEMPLATE_NAME" == *rocky* ]]; then
  GROUP="Rocky-SRV"
else
  GROUP="Lab"
fi
```

## Playbook auto execution
Terraform use another local-exec provisionner to run script ./01-Infra/scripts/run_ansible.sh

### You have to set up the ansible roles you need to execute for each VM deployed with Terraform
```hcl
vms = [
  # Exemple: Serveur Web
  {
    name          = "web-server-01"
    target_node   = "proxmox-node-1"
    vmid          = 201  # Optionnel, laissez null pour auto-généré
    template      = "ubuntu-22.04-template"
    description   = "Serveur web Apache/Nginx"
    ansible_roles = ["sshd", "dns-host", "users", "packages"]   #      <---------------------
    ...
  }
  {
    name          = "database"
    target_node   = "proxmox-node-1"
    vmid          = 202  # Optionnel, laissez null pour auto-généré
    template      = "ubuntu-22.04-template"
    description   = "mysql
    ansible_roles = ["sshd", "dns-host", "users"]  #           <---------------------
    ...
  }
]
```
Provisionner block :  
```hcl
resource "null_resource" "ansible_provision" {
  for_each = module.vms

  triggers = {
    name     = each.value.vm_name
    template = each.value.template
    ip       = each.value.ip_address
    roles    = join(",", local.vm_roles[each.value.vm_name])
  }

  provisioner "local-exec" {
    command = "bash ./scripts/run_ansible.sh '${self.triggers.name}' '${self.triggers.ip}' '${self.triggers.template}' ${join(" ", local.vm_roles[each.value.vm_name])}"
  }
  depends_on = [null_resource.update_inventory]
  
}
```
This script convert the data to json to ensure that is transmitted correctly.  
The same logic is used for apply playbook to VM group in ansible inventory : 
```bash
if [[ "$TEMPLATE_NAME" == *deb* ]]; then
  GROUP="Deb-SRV"
elif [[ "$TEMPLATE_NAME" == *rocky* ]]; then
  GROUP="Rocky-srv"
else
  GROUP="Lab"
fi
```
Please customize it for your use case. 
There is and echo command displaying the final command used by ansible for playbook execution, then you can see if ansible group and roles you want to execute are correct :
```bash 
echo "commande lancée : ansible-playbook ../02-Config/main.yaml \
  -i ../02-Config/inventory.ini \
  --extra-vars "{\"target\":\"$GROUP\", \"roles\":$roles_list}" -u ansible"
# Lancer ansible-playbook avec tags ou rôles dynamiques
ansible-playbook ../02-Config/main.yaml \
  -i ../02-Config/inventory.ini \
  --extra-vars "{\"target\":\"$GROUP\", \"roles\":$roles_list}" -u ansible
```

## Useful commands
```bash
# show current state
terraform state list

# Destroy specific VM
terraform destroy -target=module.vms[\"VM-name\"]

# Destroy all VMs (CAREFUL)
terraform destroy

# Remove VM in state file because someone destroy terraform deployed VM on proxmox UI
terraform state rm 'module.vms[\"VM-name\"].proxmox_vm_qem.vm'

# Import and existing VM
terraform import 'module.vms[\"nom-vm\"].proxmox_vm_qemu.vm' proxmox-node:vmid

# Refresh state
terraform refresh
```

### Terraform state corrupt
```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Rebuild state from Proxmox
terraform import ...
```
