# /Infra/main.tf

# Appel du module VM pour chaque VM définie
module "vms" {
  source = "./modules/vm"

  # On passe chaque VM individuellement au module
  for_each = { for vm in var.vms : vm.name => vm }

  # Configuration Proxmox (héritée du root)
  # Pas besoin de passer les credentials car le provider est configuré au niveau root

  # Configuration de la VM
  vm_name     = each.value.name
  target_node = each.value.target_node
  vmid        = each.value.vmid
  template    = each.value.template
  description = each.value.description
  roles       = join(",", each.value.ansible_roles)

  # Ressources
  cores    = each.value.cores
  sockets  = each.value.sockets
  cpu_type = each.value.cpu_type
  memory   = each.value.memory

  # Disque
  disk_size    = each.value.disk_size
  disk_type    = each.value.disk_type
  disk_storage = each.value.disk_storage

  # Réseau
  network_bridge = each.value.network_bridge
  network_model  = each.value.network_model
  network_tag    = each.value.network_tag

  # Cloud-init
  cloud_init = each.value.cloud_init

  # Options
  boot_order    = each.value.boot_order
  onboot        = each.value.onboot
  agent_enabled = each.value.agent_enabled

  # Tags
  tags = each.value.tags
}

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

resource "null_resource" "ansible_provision" {
  for_each = module.vms

  triggers = {
    name     = each.value.vm_name
    template = each.value.template
    ip       = each.value.ip_address
    roles   = join(",", each.value.ansible_roles)
  }

  provisioner "local-exec" {
    command = "bash ./scripts/run_ansible.sh '${self.triggers.name}' '${self.triggers.ip}' '${self.triggers.template}' '${self.triggers.roles}'"

  depends_on = [for r in null_resource.update_inventory : r]
  }
}
