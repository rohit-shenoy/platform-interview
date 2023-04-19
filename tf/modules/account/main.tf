resource "vault_generic_secret" "account_secret" {
  provider = vault
  path     = "secret/${var.environment}/account"

  data_json = <<EOT
{
  "db_user":   "${var.db_user}",
  "db_password": "${var.db_password}"
}
EOT
}

resource "vault_policy" "account_policy" {
  provider = vault
  name     = "account-${var.environment}"

  policy = <<EOT

path "secret/data/${var.environment}/account" {
    capabilities = ${var.policy_capabilities}
}

EOT
}

resource "vault_generic_endpoint" "account_endpoint" {
  provider             = vault
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/account-${var.environment}"
  ignore_absent_fields = var.ignore_absent_fields

  data_json = <<EOT
{
  "policies": ["account-${var.environment}"],
  "password": "${var.endpoint_password_prefix}-${var.environment}"
}
EOT
}

resource "docker_container" "account_container" {
  image = var.container_image
  name  = "account_${var.environment}"

  env = [
    "VAULT_ADDR=${var.container_vault_address}",
    "VAULT_USERNAME=account-${var.environment}",
    "VAULT_PASSWORD=${container_password_prefix}-${var.environment}",
    "ENVIRONMENT=${var.environment}"
  ]

  networks_advanced {
    name = "vagrant_${var.environment}"
  }

  lifecycle {
    ignore_changes = all
  }
}