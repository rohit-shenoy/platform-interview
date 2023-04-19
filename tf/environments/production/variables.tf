variable "environment" {
  type        = string
  default     = "production"
  description = "The name of an environment"
}

variable "container_vault_address" {
  type        = string
  default     = "http://vault-production:8200"
  description = "The docker container image vault address environment variable"
}

variable "vault_address" {
  type        = string
  description = "The vault address to use"
  default = "http://localhost:8301"
}

variable "vault_token" {
  type        = string
  description = "The vault token to use"
  default = "083672fc-4471-4ec4-9b59-a285e463a973"
}