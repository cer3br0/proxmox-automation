#!/bin/bash

PROX_HOST="proxmox IP"
PROX_USER="Promox user"

read -p "Which VMs to switch on (use space as separaror) : " -a VM_IDS

for id in "${VM_IDS[@]}"; do
  echo "Wake up VM:  $id..."
  ssh ${PROX_USER}@${PROX_HOST} "sudo /usr/sbin/qm start $id" \
    && echo "✅ VM $id is on." \
    || echo "❌ Fail to switch on VM $id."
done
