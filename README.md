# Proxmox VM Automation :  

This project automates the deployment and configuration of VMs on Proxmox server using Terraform and Ansible  

## Requirements

 **Terraform/OpenTofu** installed  
 **Ansible**  installed  
 **Proxmox** with:  
   - Dedicated user with appropriate permissions (using API token if possible)
   - VM template ready for use (with cloud-init if you need it)


## Projet structure  

There are 2 main directories in this projet :  
```
Infra -> Terraform directory to create VM
- Cloud-init can be used to customize user/network/ssh key
- Bash script to automatically add/remove the deployed/destroyed VM in the inventory.ini (ansible)

config -> ansible directory with roles for :
- create /manage users
- hardening / config ssh
- Config DNS/ host file
- add packages
```

```
Proxmox-automation
.
├── config
│   ├── ansible.cfg
│   ├── dns-config.yaml
│   ├── inventory.ini
│   ├── roles
│   ├── sshd-config.yaml
│   └── users.yaml
└── Infra
    ├── main.tf
    ├── modules
    ├── outputs.tf
    ├── providers.tf
    ├── README.md
    ├── scripts
    ├── terraform.tfstate.backup
    ├── terraform.tfvars
    └── variables.tf
```

## Configuration

### 1. Vars files

Copy the template variable file and customize it :
```bash
cp terraform.tfvars.template terraform.tfvars
```

### 2. Configuration Proxmox

Create dedicated user in proxmox with good permissions :
```bash
# On Proxmox
pveum user add terraform-user@pve
pveum passwd terraform-user@pve
pveum role add TerraformProv -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
pveum aclmod / -user terraform-user@pve -role TerraformProv
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

## Variables importantes

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

## Ansible integration 

# For ansible information and configuration, please look at the README.md in each roles directory **./config/roles/**

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


## Common mistakes

### Provider Proxmox
```bash
# If tls certificate error
proxmox_tls_insecure = true -> false
```

### bad template
List and find your template :
```bash
# Proxmox CLI
qm list 
```

### Permissions denied for user/API token
Verify your token as the correct permissions for create and manage VM :
```
VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit
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

## Best practices

### Safety
1. **Never commit** `terraform.tfvars` or sensitive information in git
2. Use **SSH keys** instead of passwords
3. Create a **dedicated** Proxmox user for Terraform
4. Use **valid certificates** if possible

### Organization
1. **Tag** VMs for easier management
2. Use **descriptive** and consistent names
3. **Document** each VM's configuration
4. Make **backups** before major modifications

### Performance
1. Use the **appropriate disk type** (virtio for performance)
2. Enable **QEMU agent** for better information
3. Configure **resources** according to actual usage

## Future developments

This module can be extended to support :
- Multiple **disks** per VM
- Multiple network interfaces
- Automatic snapshots
- Add another roles specific configuration (database, webserver,...)


## Troubleshooting

### VM won't start
1. Check Proxmox logs
2. Check resources available on node
3. Check template configuration

### Network problems
1. Check bridge configuration
2. Check VLANs if used
3. Check cloud-init if static IP

### Terraform state corrupt
```bash
# Backup current state
cp terraform.tfstate terraform.tfstate.backup

# Rebuild state from Proxmox
terraform import ...
```
