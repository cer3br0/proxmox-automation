# /Infra/modules/vm/main.tf
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}
# Ressource principale de la VM
resource "proxmox_vm_qemu" "vm" {
  # Configuration de base
  name        = var.vm_name
  target_node = var.target_node
  vmid        = var.vmid
  desc        = var.description != "" ? var.description : "VM créée par Terraform - ${var.vm_name}"

  # Template source
  clone = var.template
  
  # Démarrage automatique après création
  automatic_reboot = var.auto_reboot
  # Configuration CPU
  cpu {
  cores   = var.cores
  sockets = var.sockets
  type     = var.cpu_type
  numa = false
  }
  
  # Configuration mémoire
  memory = var.memory
  
  # Configuration du disque principal
  disk {
    size    = var.disk_size
    type    = var.disk_type
    storage = var.disk_storage
    # Options recommandées pour les performances
    iothread = var.disk_type == "virtio" ? true : false
    emulatessd = true
    discard  = "true"
    backup   = true
    slot = "scsi0"
  }
    disk {
    slot    = "ide0"
    type    = "cloudinit"
    storage = var.disk_storage
  }
  # Configuration réseau
  network {
    id = 0
    bridge = var.network_bridge
    model  = var.network_model
    tag    = var.network_tag
  }
  
  # Configuration Cloud-init si fournie
  ipconfig0 = "ip=${var.cloud_init.ip_config.ip},gw=${var.cloud_init.ip_config.gateway}"
    
  
  # Utilisateur Cloud-init
  ciuser = var.cloud_init != null ? var.cloud_init.user : null
  
  # Mot de passe Cloud-init
  cipassword = var.cloud_init != null ? var.cloud_init.password : null
  
  # Clés SSH Cloud-init
  sshkeys = var.cloud_init != null && var.cloud_init.ssh_keys != null ? join("\n", var.cloud_init.ssh_keys) : null
  
  # Options de boot et d'agent
  boot    = var.boot_order
  onboot  = var.onboot
  agent   = var.agent_enabled ? 1 : 0
  
  # Tags si fournis
  tags = length(var.tags) > 0 ? join(",", var.tags) : null
  
  # Options avancées pour les performances
 
   
  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignorer les changements sur ces attributs après création
      cipassword,
      disk,
    ]
  }
}

# Attendre que la VM soit complètement démarrée
resource "time_sleep" "wait_vm_ready" {
  depends_on = [proxmox_vm_qemu.vm]
  
  create_duration = "30s"
}
