# /Infra/modules/vm/variables.tf

# Configuration de base de la VM
variable "vm_name" {
  description = "Nom de la VM"
  type        = string
  
  validation {
    condition     = length(var.vm_name) > 0 && length(var.vm_name) <= 64
    error_message = "Le nom de la VM doit contenir entre 1 et 64 caractères."
  }
}

variable "target_node" {
  description = "Nœud Proxmox cible"
  type        = string
}

variable "auto_reboot" {
  description = "Reboot automatiquement la VM si des modifications le nécessitent"
  type        = bool
  default     = true
}

variable "vmid" {
  description = "ID unique de la VM (optionnel, auto-généré si non spécifié)"
  type        = number
  default     = null
}

variable "template" {
  description = "Nom du template à utiliser"
  type        = string
}

variable "description" {
  description = "Description de la VM"
  type        = string
  default     = ""
}

# Configuration CPU
variable "cores" {
  description = "Nombre de cœurs CPU"
  type        = number
  
  validation {
    condition     = var.cores > 0 && var.cores <= 128
    error_message = "Le nombre de cœurs doit être entre 1 et 128."
  }
}

variable "sockets" {
  description = "Nombre de sockets CPU"
  type        = number
  default     = 1
  
  validation {
    condition     = var.sockets > 0 && var.sockets <= 4
    error_message = "Le nombre de sockets doit être entre 1 et 4."
  }
}

variable "cpu_type" {
  description = "Type de CPU"
  type        = string
  default     = "host"
}

# Configuration mémoire
variable "memory" {
  description = "Quantité de mémoire en MB"
  type        = number
  
  validation {
    condition     = var.memory >= 512 && var.memory <= 1048576
    error_message = "La mémoire doit être entre 512 MB et 1 TB."
  }
}

# Configuration disque
variable "disk_size" {
  description = "Taille du disque (ex: 20G, 100G)"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]+[KMGT]?$", var.disk_size))
    error_message = "La taille du disque doit être au format: nombre + unité (K, M, G, T)."
  }
}

variable "disk_type" {
  description = "Type de disque (scsi, ide, sata, virtio)"
  type        = string
  default     = "disk"
}  

variable "disk_storage" {
  description = "Storage Proxmox pour le disque"
  type        = string
}

# Configuration réseau
variable "network_bridge" {
  description = "Bridge réseau"
  type        = string
  default     = "vmbr0"
}

variable "network_model" {
  description = "Modèle de carte réseau"
  type        = string
  default     = "virtio"
  
  validation {
    condition     = contains(["virtio", "e1000", "rtl8139"], var.network_model)
    error_message = "Le modèle réseau doit être: virtio, e1000, ou rtl8139."
  }
}

variable "network_tag" {
  description = "VLAN tag (optionnel)"
  type        = number
  default     = null
}

# Configuration Cloud-init
variable "cloud_init" {
  description = "Configuration Cloud-init"
  type = object({
    user     = optional(string)
    password = optional(string)
    ssh_keys = optional(list(string))
    ip_config = optional(object({
      ip      = string
      gateway = string
    }))
  })
  default = null
}

# Options de la VM
variable "boot_order" {
  description = "Ordre de boot"
  type        = string
  default     = "c"
}

variable "onboot" {
  description = "Démarrer automatiquement la VM"
  type        = bool
  default     = true
}

variable "agent_enabled" {
  description = "Activer l'agent QEMU"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags pour organiser les VMs"
  type        = list(string)
  default     = []
}