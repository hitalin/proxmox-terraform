# yamisskey-terraform

Proxmox VE VM provisioning for yamisskey security research infrastructure.

## VMs

| VM | ID | Spec | Network | Purpose |
|----|-----|------|---------|---------|
| OPNsense | 101 | 4c/4GB/32GB | vmbr0,1,2 | Router/Firewall |
| T-Pot | - | 8c/16GB/256GB | vmbr2 | Honeypot (ELK) |
| Malcolm | - | 12c/24GB/500GB | vmbr2 | Traffic analysis |
| CTF | - | 4c/4GB/100GB | vmbr2 | CTF environment |

## Network

| Bridge | Subnet | Purpose |
|--------|--------|---------|
| vmbr0 | 192.168.1.0/24 | WAN/Management |
| vmbr1 | 10.0.1.0/24 | LAN |
| vmbr2 | 10.0.2.0/24 | DMZ (isolated) |

## Setup

```bash
# 1. Configure secrets (SOPS + age, same key as yamisskey-ansible)
sops secrets.sops.yaml

# 2. Deploy
terraform init
terraform apply -var="opnsense_enabled=true"
```

## Templates (on Proxmox)

```bash
# Ubuntu 24.04 (ID: 9000)
qm create 9000 --name ubuntu-24.04-cloudinit --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 ubuntu-24.04-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0 --boot c --bootdisk scsi0
qm set 9000 --ide2 local-lvm:cloudinit --serial0 socket --vga serial0 --agent enabled=1
qm template 9000

# OPNsense ISO
wget https://mirror.ams1.nl.leaseweb.net/opnsense/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2
bunzip2 OPNsense-25.1-dvd-amd64.iso.bz2
```

## Docs

- [Setup Guide](docs/setup.md) - Detailed setup instructions

## Related

- [yamisskey-ansible](https://github.com/yamisskey-dev/yamisskey-ansible) - Configuration
- [yamisskey-host](https://github.com/yamisskey-dev/yamisskey-host) - Documentation
