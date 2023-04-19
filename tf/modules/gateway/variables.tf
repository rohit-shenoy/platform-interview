variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "db_user" {
  type = string
  default = "account"
  description = "The gateway database user to be used in the secret"
}

variable "db_password" {
  type = string
  description = "The gateway database password to be used in the secret"
}

variable "ignore_absent_fields" {
  type = bool
  default = true
  description = "The gateway endpoint ignore fields boolean property"
}

variable "endpoint_password_prefix" {
  type = string
  description = "The gateway endpoint password prefix to be used"
}

variable "container_image" {
  type = string
  description = "The gateway container image to be used"
  default = "form3tech-oss/platformtest-gateway"
}

variable "container_vault_address" {
  type = string
  description = "The container vault address to be used"
}

variable "container_password_prefix" {
  type = string
  description = "The container vault password prefix to be used"
}