provider "vault" {
  address = var.vault_address
  token   = var.vault_token
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