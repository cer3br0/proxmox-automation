#!/bin/bash
VM_NAME="$1"
VM_IP="$2"
TEMPLATE_NAME="$3"
shift 3
roles=("$@")

if [[ "$TEMPLATE_NAME" == *deb* ]]; then
  GROUP="Deb-SRV"
elif [[ "$TEMPLATE_NAME" == *rocky* ]]; then
  GROUP="Rocky-SRV"
else
  GROUP="Lab"
fi


# Transformation du tableau roles en chaîne de type YAML pour Ansible
roles_string=$(IFS=','; echo "${roles[*]}")

echo "Running Ansible for $VM_NAME ($VM_IP) in group $GROUP with roles: ${roles[*]}"

# Lancer ansible-playbook avec tags ou rôles dynamiques
ansible-playbook playbooks/main.yml \
  -i /../02-Config/inventory.ini \
  --extra-vars "target=$GROUP roles=[$roles_string]"
