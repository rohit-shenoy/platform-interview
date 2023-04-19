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

variable "vault_address" {
  type        = string
  description = "The vault address to use"
  default = "http://localhost:8201"
}

variable "vault_token" {
  type        = string
  description = "The vault token to use"
  default = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
}