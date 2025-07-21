# Proxmox VM Automation with Terraform

# Terraform 

## Projet structure  

```
Infra/
├── main.tf              # main terraform file
├── variables.tf         # root vars
├── outputs.tf           # root outputs
├── providers.tf         # providers configuration
├── terraform.tfvars     # Vars values
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
cp terraform.tfvars.template terraform.tfvars
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
    user = "admin"
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
proxmox_api_url = Promox API url #(ex: "https://yourprox:8006/api2/json")
proxmox_user = User or API token #(ex: "terraform-user@pve!terraform-token")
proxmox_password = Password or API secret #Use API for best practice
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

## For ansible information and configuration, please look at the README.md in each roles directory **./config/roles/**

Terraform output are used to add/remove lines in the file ./config/inventory.ini via bash scripting ./Infra/scripts using a "null_resource" and provisionner local-exec for script executing
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
INVENTORY_FILE="../config/inventory.ini"
```

This script is made actualy for 3 groups depending of the template used in terraform, you can easily customize it by editing "./Infra/scripts/add_to_inventory.sh" :   
```bash
if [[ "$TEMPLATE_NAME" == *deb* ]]; then
  GROUP="Deb-SRV"
elif [[ "$TEMPLATE_NAME" == *rocky* ]]; then
  GROUP="Rocky-SRV"
else
  GROUP="Lab"
fi
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
