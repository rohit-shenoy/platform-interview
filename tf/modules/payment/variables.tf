variable "environment" {
  type        = string
  description = "The name of the environemnts"
}

variable "db_user" {
  type = string
  default = "account"
  description = "The payment database user to be used in the secret"
}

variable "db_password" {
  type = string
  description = "The payment database password to be used in the secret"
}

variable "policy_capabilities" {
  type = list
  default = ["list", "read"]
  description = "The payment vault policy capabilities to be defined"
}

variable "ignore_absent_fields" {
  type = bool
  default = true
  description = "The payment endpoint ignore fields boolean property"
}

variable "endpoint_password_prefix" {
  type = string
  description = "The payment endpoint password prefix to be used"
}

variable "container_image" {
  type = string
  description = "The payment container image to be used"
  default = "form3tech-oss/platformtest-payment"
}

variable "container_vault_address" {
  type = string
  description = "The container vault address to be used"
}

variable "container_password_prefix" {
  type = string
  description = "The container vault password prefix to be used"
}
