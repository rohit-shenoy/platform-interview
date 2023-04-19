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