#!/bin/bash

PROX_HOST="proxmox IP"
PROX_USER="Promox user"

read -p "Which VMs to shutdown (use space as separaror) : " -a VM_IDS

for id in "${VM_IDS[@]}"; do
  echo "Shutdown VM : $id..."
  ssh ${PROX_USER}@${PROX_HOST} "sudo /usr/sbin/qm stop $id" \
    && echo "✅ VM $id off." \
    || echo "❌ Fail to shutdown VM $id."
done
