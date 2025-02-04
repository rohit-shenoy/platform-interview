variable "environment" {
  type        = string
  description = "The name of the environemnts"
}

variable "vault_audit_file_path" {
  type = string
  description = "The vault audit file path to use"
}

variable "vault_auth_backend_type" {
  type = string
  default = "userpass"
  description = "The vault auth backend type to use"
}