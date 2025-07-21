# /Infra/variables.tf

# Configuration Proxmox
variable "proxmox_api_url" {
  description = "URL de l'API Proxmox"
  type        = string
}

variable "proxmox_user" {
  description = "Utilisateur Proxmox"
  type        = string
}

variable "proxmox_password" {
  description = "Mot de passe Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Ignorer les certificats TLS invalides"
  type        = bool
  default     = true
}

# Configuration des VMs
variable "vms" {
  description = "Liste des VMs à créer"
  type = list(object({
    name        = string
    target_node = string
    vmid        = optional(number)
    template    = string
    description = optional(string)

    # Ressources CPU/RAM
    cores    = number
    sockets  = optional(number, 1)
    cpu_type = optional(string, "host")
    memory   = number

    # Configuration disque
    disk_size    = string
    disk_type    = optional(string, "scsi")
    disk_storage = string

    # Configuration réseau
    network_bridge = optional(string, "vmbr0")
    network_model  = optional(string, "virtio")
    network_tag    = optional(number)

    # Configuration cloud-init (optionnel)
    cloud_init = optional(object({
      user     = optional(string)
      password = optional(string)
      ssh_keys = optional(list(string))
      ip_config = optional(object({
        ip      = string
        gateway = string
      }))
    }))

    # Options additionnelles
    boot_order    = optional(string, "c")
    onboot        = optional(bool, true)
    agent_enabled = optional(bool, true)

    # Tags pour l'organisation
    tags = optional(list(string), [])
  }))
  default = []
}