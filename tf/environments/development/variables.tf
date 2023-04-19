variable "environment" {
  type        = string
  default     = "development"
  description = "The name of an environment"
}

variable "container_vault_address" {
  type        = string
  default     = "http://vault-development:8200"
  description = "The docker container image vault address environment variable"
}