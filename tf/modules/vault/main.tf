terraform {
  required_version = ">= 1.0.7"

  required_providers {
    vault = {
      version = "3.0.1"
    }
  }
}

resource "vault_audit" "audit" {
  provider = vault
  type     = "file"

  options = {
    file_path = var.vault_audit_file_path
  }
}

resource "vault_auth_backend" "userpass" {
  provider = vault
  type     = var.vault_auth_backend_type
}