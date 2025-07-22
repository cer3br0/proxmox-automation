#!/bin/bash
VM_NAME="$1"
VM_IP="$2"
TEMPLATE_NAME="$3"
shift 3
roles=("$@")
INVENTORY_FILE="../02-Config/inventory.ini"
PLAYBOOK_NAME="../02-Config/main.yaml"

# Conversion des rôles en format JSON pour Ansible (plus sûr que YAML)
roles_json=$(printf '"%s",' "${roles[@]}" | sed 's/,$//')
roles_list="[$roles_json]"

if [[ "$TEMPLATE_NAME" == *deb* ]]; then
  GROUP="Deb-SRV"
elif [[ "$TEMPLATE_NAME" == *rocky* ]]; then
  GROUP="Rocky-srv"
else
  GROUP="Lab"
fi


echo "Running Ansible for $VM_NAME ($VM_IP) in group $GROUP with roles: ${roles[*]} $roles_string"
echo ""
echo "commande lancée : ansible-playbook $PLAYBOOK_NAME \
  -i $INVENTORY_FILE \
  --extra-vars "{\"target\":\"$GROUP\", \"roles\":$roles_list}" -u ansible"
echo ""

# Lancer ansible-playbook avec tags ou rôles dynamiques
ansible-playbook ../02-Config/main.yaml \
  -i ../02-Config/inventory.ini \
  --extra-vars "{\"target\":\"$GROUP\", \"roles\":$roles_list}" -u ansible
