# Proxmox VM Automation avec Terraform

Ce projet permet d'automatiser le déploiement de machines virtuelles sur Proxmox en utilisant Terraform avec une approche modulaire.

## Structure du projet

```
Infra/
├── main.tf              # Point d'entrée principal
├── variables.tf         # Variables du niveau root
├── outputs.tf          # Sorties du niveau root
├── providers.tf        # Configuration des providers
├── terraform.tfvars    # Valeurs des variables (à créer)
└── modules/
    └── vm/
        ├── main.tf      # Ressources du module VM
        ├── variables.tf # Variables du module
        └── outputs.tf   # Sorties du module
```

## Prérequis

1. **Terraform/OpenTofu** installé
2. **Proxmox** configuré avec :
   - Un utilisateur dédié avec permissions appropriées
   - Des templates VM prêts à être clonés
   - Storage configuré

## Configuration

### 1. Fichier de variables

Copiez le template et adaptez-le :
```bash
cp terraform.tfvars.template terraform.tfvars
```

### 2. Configuration Proxmox

Créez un utilisateur dédié dans Proxmox :
```bash
# Dans Proxmox
pveum user add terraform-user@pve
pveum passwd terraform-user@pve
pveum role add TerraformProv -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit"
pveum aclmod / -user terraform-user@pve -role TerraformProv
```

## Utilisation

### Déploiement des VMs

```bash
# Initialiser Terraform
terraform init

# Planifier le déploiement
terraform plan

# Appliquer les changements
terraform apply
```

### Exemples de configurations

#### VM Simple (Development)
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

#### VM avec Cloud-init
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

## Profils de ressources recommandés

| Profil | CPU | RAM | Disque | Usage |
|--------|-----|-----|--------|-------|
| Micro | 1 | 1GB | 20G | Tests, dev léger |
| Petit | 2 | 4GB | 50G | Services web légers |
| Moyen | 4 | 8GB | 100G | Applications web |
| Gros | 8 | 16GB | 500G | Bases de données |
| Très gros | 16+ | 32GB+ | 1TB+ | Big data, virtualisation |

## Variables importantes

### Configuration Proxmox
- `proxmox_api_url` : URL de l'API Proxmox
- `proxmox_user` : Utilisateur Proxmox
- `proxmox_password` : Mot de passe

### Configuration VM
- `name` : Nom unique de la VM
- `target_node` : Nœud Proxmox cible
- `template` : Template à cloner
- `cores` : Nombre de cœurs CPU
- `memory` : RAM en MB
- `disk_size` : Taille du disque (ex: "50G")
- `disk_storage` : Storage Proxmox

## Outputs disponibles

Le module génère plusieurs outputs utiles pour l'intégration avec Ansible :

```bash
# Voir toutes les informations des VMs
terraform output vms_info

# Récupérer les IPs pour Ansible
terraform output vm_ips

# Mapping nom -> IP
terraform output vm_inventory
```

## Intégration avec Ansible

Les outputs Terraform peuvent être utilisés pour générer automatiquement l'inventaire Ansible :

```bash
# Générer un inventaire Ansible simple
terraform output -json vm_inventory | jq -r 'to_entries[] | "\(.key) ansible_host=\(.value)"' > inventory
```

## Gestion des erreurs courantes

### Provider Proxmox
```bash
# Si erreur de certificat TLS
proxmox_tls_insecure = true
```

### Templates manquants
Vérifiez que vos templates existent :
```bash
# Dans Proxmox CLI
qm list | grep template
```

### Problèmes de permissions
Vérifiez les permissions de l'utilisateur Terraform dans l'interface Proxmox.

## Commandes utiles

```bash
# Voir l'état actuel
terraform state list

# Détruire une VM spécifique
terraform destroy -target=module.vms[\"nom-vm\"]

# Détruire toutes les VMs
terraform destroy

# Importer une VM existante
terraform import 'module.vms[\"nom-vm\"].proxmox_vm_qemu.vm' proxmox-node:vmid

# Rafraîchir l'état
terraform refresh
```

## Bonnes pratiques

### Sécurité
1. **Ne jamais commiter** `terraform.tfvars` dans git
2. Utiliser des **clés SSH** plutôt que des mots de passe
3. Créer un **utilisateur dédié** Proxmox pour Terraform
4. Utiliser des **certificats valides** si possible

### Organisation
1. **Tagger** les VMs pour faciliter la gestion
2. Utiliser des **noms descriptifs** et cohérents
3. **Documenter** la configuration de chaque VM
4. Faire des **sauvegardes** avant modifications importantes

### Performance
1. Utiliser le **type de disque approprié** (virtio pour les performances)
2. Activer **l'agent QEMU** pour de meilleures informations
3. Configurer **les ressources** selon l'usage réel

## Évolutions futures

Ce module peut être étendu pour supporter :
- **Disques multiples** par VM
- **Interfaces réseau multiples**
- **Snapshots automatiques**
- **Politique de sauvegarde**
- **Monitoring intégré**

## Troubleshooting

### VM qui ne démarre pas
1. Vérifier les logs Proxmox
2. Contrôler les ressources disponibles sur le nœud
3. Vérifier la configuration du template

### Problèmes réseau
1. Vérifier la configuration du bridge
2. Contrôler les VLANs si utilisés
3. Vérifier cloud-init si IP statique

### Terraform state corrompu
```bash
# Sauvegarder l'état actuel
cp terraform.tfstate terraform.tfstate.backup

# Reconstruire l'état depuis Proxmox
terraform import ...
```
