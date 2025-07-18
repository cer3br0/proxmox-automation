#!/bin/bash

VM_NAME="$1"
INVENTORY_FILE="../config/inventory.ini"

# Vérifie si le fichier existe
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "Fichier $INVENTORY_FILE introuvable"
  exit 1
fi

# Sauvegarde
cp "$INVENTORY_FILE" "$INVENTORY_FILE.bak"

# Supprime la ligne correspondant à la VM (sans casser le fichier)
grep -v "^$VM_NAME " "$INVENTORY_FILE.bak" > "$INVENTORY_FILE"
