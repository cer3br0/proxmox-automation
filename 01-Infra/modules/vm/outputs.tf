# /Infra/modules/vm/outputs.tf

# Informations de base de la VM
output "vm_id" {
  description = "ID de la VM"
  value       = proxmox_vm_qemu.vm.vmid
}

output "vm_name" {
  description = "Nom de la VM"
  value       = proxmox_vm_qemu.vm.name
}

output "target_node" {
  description = "Nœud Proxmox où la VM est déployée"
  value       = proxmox_vm_qemu.vm.target_node
}

# Informations réseau
output "ip_address" {
  description = "Adresse IP de la VM"
  value       = length(proxmox_vm_qemu.vm.default_ipv4_address) > 0 ? proxmox_vm_qemu.vm.default_ipv4_address : null
}

output "mac_address" {
  description = "Adresse MAC de la VM"
  value       = length(proxmox_vm_qemu.vm.network) > 0 ? proxmox_vm_qemu.vm.network[0].macaddr : null
}

# Informations sur les ressources

output "vm_memory" {
  description = "Quantité de mémoire allouée (MB)"
  value       = proxmox_vm_qemu.vm.memory
}

output "vm_disk_size" {
  description = "Taille du disque principal"
  value       = var.disk_size
}

# Statut de la VM
output "vm_status" {
  description = "Statut actuel de la VM"
  value       = proxmox_vm_qemu.vm.qemu_os
}

# Informations pour Ansible
output "ansible_host" {
  description = "Adresse IP formatée pour Ansible"
  value       = length(proxmox_vm_qemu.vm.default_ipv4_address) > 0 ? proxmox_vm_qemu.vm.default_ipv4_address : null
}
output "template" {
  description = "Template utilisé pour cloner la VM"
  value       = var.template
}
# Informations complètes de la VM
output "vm_info" {
  description = "Informations complètes de la VM"
  value = {
    vmid        = proxmox_vm_qemu.vm.vmid
    name        = proxmox_vm_qemu.vm.name
    node        = proxmox_vm_qemu.vm.target_node
    memory      = proxmox_vm_qemu.vm.memory
    disk_size   = var.disk_size
    template    = var.template
    ip_address  = length(proxmox_vm_qemu.vm.default_ipv4_address) > 0 ? proxmox_vm_qemu.vm.default_ipv4_address : null
    mac_address = length(proxmox_vm_qemu.vm.network) > 0 ? proxmox_vm_qemu.vm.network[0].macaddr : null
    tags        = var.tags
  }
}