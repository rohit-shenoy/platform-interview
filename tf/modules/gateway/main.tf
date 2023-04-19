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

resource "vault_generic_secret" "gateway_secret" {
  provider = vault
  path     = "secret/${var.environment}/gateway"

  data_json = <<EOT
{
  "db_user":   "${var.db_user}",
  "db_password": "${var.db_password}"
}
EOT
}

resource "vault_policy" "gateway_policy" {
  provider = vault
  name     = "gateway-${var.environment}"

  policy = <<EOT

path "secret/data/${var.environment}/gateway" {
    capabilities = ["list", "read"]
}

EOT
}

resource "vault_generic_endpoint" "gateway_endpoint" {
  provider             = vault
  #depends_on           = [vault.vault_auth_backend.userpass]
  path                 = "auth/userpass/users/gateway-${var.environment}"
  ignore_absent_fields = var.ignore_absent_fields

  data_json = <<EOT
{
  "policies": ["gateway-${var.environment}"],
  "password": "${var.endpoint_password_prefix}-${var.environment}"
}
EOT
}

resource "docker_container" "gateway_container" {
  image = var.container_image
  name  = "gateway_${var.environment}"

  env = [
    "VAULT_ADDR=${var.container_vault_address}",
    "VAULT_USERNAME=gateway-${var.environment}",
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