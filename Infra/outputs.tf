# Informations sur les VMs créées
output "vms_info" {
  description = "Informations sur toutes les VMs créées"
  value = {
    for name, vm in module.vms : name => {
      vmid        = vm.vm_id
      name        = vm.vm_name
      target_node = vm.target_node
      template    = vm.template
      ip_address  = vm.ip_address
      status      = vm.vm_status
    }
  }
}

# Liste des IPs pour Ansible
output "vm_ips" {
  description = "Liste des adresses IP des VMs pour Ansible"
  value = [
    for vm in module.vms : vm.ip_address
    if vm.ip_address != null
  ]
}

# Mapping nom -> IP pour les inventaires
output "vm_inventory" {
  description = "Mapping nom de VM vers adresse IP"
  value = {
    for name, vm in module.vms : name => vm.ip_address
    if vm.ip_address != null
  }
}