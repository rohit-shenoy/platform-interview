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