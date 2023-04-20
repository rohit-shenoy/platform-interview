variable "environment" {
  type        = string
  default     = "staging"
  description = "The name of an environment"
}

variable "container_vault_address" {
  type        = string
  default     = "http://vault-staging:8200"
  description = "The docker container image vault address environment variable"
}

variable "vault_address" {
  type        = string
  description = "The vault address to use"
  default = "http://localhost:8401"
}

variable "vault_token" {
  type        = string
  description = "The vault token to use"
  default = "e12501de-713c-3195-8d83-d20z5cb7dc7c"
}