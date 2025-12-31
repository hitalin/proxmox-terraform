# Main Terraform Configuration
# This is a minimal mock configuration for testing Proxmox connectivity

# Test VM Resource (minimal configuration)
resource "proxmox_vm_qemu" "test_vm" {
  count = var.test_vm_enabled ? 1 : 0

  name        = var.test_vm_name
  target_node = var.proxmox_node
  clone       = var.test_vm_template

  # VM Specifications
  cores   = var.test_vm_cores
  sockets = 1
  memory  = var.test_vm_memory

  # Disk Configuration
  disk {
    size    = var.test_vm_disk_size
    storage = var.proxmox_storage
    type    = "scsi"
  }

  # Network Configuration
  network {
    model  = "virtio"
    bridge = var.test_vm_network_bridge
  }

  # Cloud-init Configuration (optional)
  os_type = "cloud-init"

  # SSH key injection (if provided)
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # Lifecycle settings
  lifecycle {
    # Prevent accidental destruction
    # prevent_destroy = true
  }

  # Tags for organization
  tags = "terraform,test"
}

# Production VMs
# Note: Ensure you have appropriate templates/ISOs in Proxmox before applying

# pfSense - Router/Firewall
resource "proxmox_vm_qemu" "pfsense" {
  count = var.pfsense_enabled ? 1 : 0

  name        = "pfsense"
  desc        = "pfSense Router/Firewall with HAProxy and OpenVPN"
  target_node = var.proxmox_node

  # pfSense requires manual ISO installation, not cloud-init
  # clone = var.pfsense_template  # Use if you have a template

  # VM Specifications (4c/4GB/32GB)
  cores   = 4
  sockets = 1
  memory  = 4096  # 4GB

  # Boot from ISO (for initial install)
  # After install, remove this and set boot order
  # iso = "local:iso/pfSense-CE-2.7.2-RELEASE-amd64.iso"

  # Disk Configuration
  disk {
    size    = "32G"
    storage = var.proxmox_storage
    type    = "scsi"
  }

  # Network Configuration - Multiple interfaces
  # vmbr0: WAN
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # vmbr1: LAN
  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  # vmbr2: DMZ
  network {
    model  = "virtio"
    bridge = "vmbr2"
  }

  # vmbr3: Management
  network {
    model  = "virtio"
    bridge = "vmbr3"
  }

  # pfSense requires BIOS boot
  bios = "seabios"

  # Start on boot
  onboot = true

  lifecycle {
    prevent_destroy = true  # Protect critical infrastructure
  }

  tags = "terraform,production,network"
}

# T-Pot Sensor - Honeypot Platform (no ELK)
resource "proxmox_vm_qemu" "tpot" {
  count = var.tpot_enabled ? 1 : 0

  name        = "tpot-sensor"
  desc        = "T-Pot Honeypot Sensor (no ELK stack)"
  target_node = var.proxmox_node
  clone       = var.tpot_template  # Debian/Ubuntu template

  # VM Specifications (8c/8GB/128GB)
  cores   = 8
  sockets = 1
  memory  = 8192  # 8GB

  # Disk Configuration
  disk {
    size    = "128G"
    storage = var.proxmox_storage
    type    = "scsi"
  }

  # Network Configuration - DMZ only
  network {
    model  = "virtio"
    bridge = "vmbr2"  # DMZ
  }

  # Cloud-init
  os_type = "cloud-init"
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # Start on boot
  onboot = true

  lifecycle {
    prevent_destroy = true
  }

  tags = "terraform,production,security,honeypot"
}

# Malcolm - Network Analysis Platform
resource "proxmox_vm_qemu" "malcolm" {
  count = var.malcolm_enabled ? 1 : 0

  name        = "malcolm"
  desc        = "Malcolm Network Analysis (Zeek, Suricata, ELK) + T-Pot log analysis"
  target_node = var.proxmox_node
  clone       = var.malcolm_template  # Ubuntu template

  # VM Specifications (12c/24GB/500GB)
  cores   = 12
  sockets = 1
  memory  = 24576  # 24GB

  # Disk Configuration
  disk {
    size    = "500G"
    storage = var.proxmox_storage
    type    = "scsi"
  }

  # Network Configuration - DMZ for traffic analysis
  network {
    model  = "virtio"
    bridge = "vmbr2"  # DMZ
  }

  # Cloud-init
  os_type = "cloud-init"
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # Start on boot
  onboot = true

  lifecycle {
    prevent_destroy = true
  }

  tags = "terraform,production,security,analysis"
}

# CTF Challenges - Isolated CTF Environment
resource "proxmox_vm_qemu" "ctf_challenges" {
  count = var.ctf_enabled ? 1 : 0

  name        = "ctf-challenges"
  desc        = "Isolated CTF challenge execution environment"
  target_node = var.proxmox_node
  clone       = var.ctf_template  # Ubuntu template

  # VM Specifications (4c/4GB/100GB)
  cores   = 4
  sockets = 1
  memory  = 4096  # 4GB

  # Disk Configuration
  disk {
    size    = "100G"
    storage = var.proxmox_storage
    type    = "scsi"
  }

  # Network Configuration - DMZ for isolation
  network {
    model  = "virtio"
    bridge = "vmbr2"  # DMZ
  }

  # Cloud-init
  os_type = "cloud-init"
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # Don't start on boot (start only during CTF events)
  onboot = false

  tags = "terraform,production,ctf"
}
