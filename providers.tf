terraform {
  required_version = ">= 1.7.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

# Load secrets from SOPS-encrypted file
data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

provider "proxmox" {
  pm_api_url          = data.sops_file.secrets.data["proxmox_api_url"]
  pm_api_token_id     = data.sops_file.secrets.data["proxmox_api_token_id"]
  pm_api_token_secret = data.sops_file.secrets.data["proxmox_api_token_secret"]
  pm_tls_insecure     = data.sops_file.secrets.data["proxmox_tls_insecure"] == "true"

  # Uncomment for debugging
  # pm_log_enable = true
  # pm_log_file   = "terraform-plugin-proxmox.log"
  # pm_debug      = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}
