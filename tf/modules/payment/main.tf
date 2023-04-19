terraform {
  required_version = ">= 1.0.7"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }

    vault = {
      version = "3.0.1"
    }
  }
}

resource "vault_generic_secret" "payment_secret" {
  provider = vault
  path     = "secret/${var.environment}/payment"

  data_json = <<EOT
{
  "db_user":   "${var.db_user}",
  "db_password": "${var.db_password}"
}
EOT
}

resource "vault_policy" "payment_policy" {
  provider = vault
  name     = "payment-${var.environment}"

  policy = <<EOT

path "secret/data/${var.environment}/payment" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "payment_endpoint" {
  provider             = vault
  #depends_on           = [vault.vault_auth_backend.userpass]
  path                 = "auth/userpass/users/payment-${var.environment}"
  ignore_absent_fields = var.ignore_absent_fields

  data_json = <<EOT
{
  "policies": ["payment-${var.environment}"],
  "password": "${var.endpoint_password_prefix}-${var.environment}"
}
EOT
}

resource "docker_container" "payment_container" {
  image = var.container_image
  name  = "payment_${var.environment}"

  env = [
    "VAULT_ADDR=${var.container_vault_address}",
    "VAULT_USERNAME=payment-${var.environment}",
    "VAULT_PASSWORD=${var.container_password_prefix}-${var.environment}",
    "ENVIRONMENT=${var.environment}"
  ]

  networks_advanced {
    name = "vagrant_${var.environment}"
  }

  lifecycle {
    ignore_changes = all
  }
}