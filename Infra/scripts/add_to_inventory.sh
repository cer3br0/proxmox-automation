#!/bin/bash

# Variables passées par Terraform
VM_NAME="$1"
VM_IP="$2"
TEMPLATE_NAME="$3"
INVENTORY_FILE="../config/inventory.ini"

cp "$INVENTORY_FILE" "$INVENTORY_FILE.old"
# Déterminer le groupe Ansible basé sur le nom du template
if [[ "$TEMPLATE_NAME" == *deb* ]]; then
  GROUP="Deb-SRV"
elif [[ "$TEMPLATE_NAME" == *rocky* ]]; then
  GROUP="Rocky-SRV"
else
  GROUP="Lab"
fi

# Ligne à ajouter
NEW_LINE="$VM_NAME ansible_host=$VM_IP"

# Créer le groupe s’il n'existe pas
if ! grep -q "^\[$GROUP\]" "$INVENTORY_FILE"; then
  echo -e "\n[$GROUP]" >> "$INVENTORY_FILE"
fi

# Vérifie si la ligne existe déjà (évite les doublons)
if grep -qF "$NEW_LINE" "$INVENTORY_FILE"; then
  echo "Entrée déjà existante pour $VM_NAME dans $GROUP, rien à faire."
  exit 0
fi

# Trouver la ligne du groupe et insérer la VM juste en dessous
awk -v group="[$GROUP]" -v newline="$NEW_LINE" '
  BEGIN { added=0 }
  {
    print $0
    if ($0 == group && !added) {
      print newline
      added=1
    }
  }
' "$INVENTORY_FILE" > "$INVENTORY_FILE.tmp" && mv "$INVENTORY_FILE.tmp" "$INVENTORY_FILE"

echo "Ajouté : $NEW_LINE dans le groupe [$GROUP]"
