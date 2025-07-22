# /Infra/terraform.tfvars.template
# Copier ce fichier vers terraform.tfvars et remplir les valeurs

#################################
# Configuration Proxmox
#################################
proxmox_api_url      = "https://your-proxmox-server:8006/api2/json"
proxmox_api_token_id         = "your api token id"  
proxmox_api_token_secret    = "your api key secret "
proxmox_tls_insecure = false  # false si vous avez un certificat valide

#################################
# Configuration des VMs
#################################
vms = [
  # Exemple: Serveur Web
  {
    name          = "web-server-01"
    target_node   = "proxmox-node-1"
    vmid          = 201  # Optionnel, laissez null pour auto-généré
    template      = "ubuntu-22.04-template"
    description   = "Serveur web Apache/Nginx"
    ansible_roles = ["sshd", "dns-host", "users", "packages"]
    
    # Ressources - Profil "Petit serveur"
    cores    = 2
    sockets  = 1
    cpu_type = "host"
    memory   = 4096  # 4GB
    
    # Disque
    disk_size    = "50G"
    disk_type    = "scsi"
    disk_storage = "local-lvm"
    
    # Réseau
    network_bridge = "vmbr0"
    network_model  = "virtio"
    network_tag    = null  # Pas de VLAN
    
    # Cloud-init (optionnel)
    cloud_init = {
      user     = "admin"
      password = "secure-password"  # Obligatoire sinon le compte sera bloqué selon l'OS mais Considérez l'utilisation de clés SSH pour la connection
      ssh_keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... votre-cle-publique"
      ]
      ip_config = {
        ip      = "192.168.1.100/24"
        gateway = "192.168.1.1"
      }
    }
    
    # Options
    boot_order    = "c"
    onboot        = true
    agent_enabled = true
    
    # Tags pour l'organisation
    tags = ["web", "production", "ubuntu"]
  },
  
  # Exemple: Base de données
  {
    name          = "db-server-01"
    target_node   = "proxmox-node-1"
    template      = "ubuntu-22.04-template"
    description   = "Serveur de base de données PostgreSQL"
    
    # Ressources - Profil "Serveur de BDD"
    cores    = 4
    sockets  = 1
    memory   = 8192  # 8GB
    
    # Disque plus important pour la BDD
    disk_size    = "200G"
    disk_type    = "scsi"
    disk_storage = "local-lvm"
    
    # Réseau
    network_bridge = "vmbr0"
    network_model  = "virtio"
    
    # Cloud-init avec IP différente
    cloud_init = {
      user = "admin"
      ssh_keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... votre-cle-publique"
      ]
      ip_config = {
        ip      = "192.168.1.101/24"
        gateway = "192.168.1.1"
      }
    }
    
    onboot = true
    tags   = ["database", "production", "postgresql"]
  },
  
  # Exemple: Serveur de développement
  {
    name          = "dev-server"
    target_node   = "proxmox-node-2"  # Différent nœud
    template      = "debian-12-template"
    description   = "Serveur de développement"
    
    # Ressources - Profil "Dev/Test"
    cores  = 1
    memory = 2048  # 2GB
    
    # Disque plus petit pour le dev
    disk_size    = "30G"
    disk_storage = "local-lvm"
    
    # Réseau avec VLAN
    network_bridge = "vmbr0"
    network_tag    = 100  # VLAN dev
    
    # Pas de cloud-init, utilise DHCP
    cloud_init = null
    
    onboot = false  # Ne pas démarrer automatiquement
    tags   = ["development", "test"]
  }
]

#################################
# Exemples de profils prédéfinis
#################################

# Profil "Micro" - Tests/Dev
# cores = 1, memory = 1024, disk = "20G"

# Profil "Petit" - Services légers
# cores = 2, memory = 4096, disk = "50G"

# Profil "Moyen" - Applications web
# cores = 4, memory = 8192, disk = "100G"

# Profil "Gros" - Bases de données, calcul
# cores = 8, memory = 16384, disk = "500G"

# Profil "Très gros" - Virtualisation imbriquée, big data
# cores = 16, memory = 32768, disk = "1000G"
