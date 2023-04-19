module "vault" {

  source = "../../modules/vault"

  environment             = var.environment
  vault_audit_file_path   = "/vault/logs/audit"
  vault_auth_backend_type = "userpass"
}

module "frontend" {
  source = "../../modules/frontend"

  environment   = var.environment
  internal_port = 80
  external_port = 4081
  image         = "docker.io/nginx:1.22.0-alpine"
}

module "account" {
  source = "../../modules/account"

  environment              = var.environment
  db_user                  = "account"
  db_password              = "396e73e7-34d5-4b0a-ae1b-b128aa7f9977"
  endpoint_password_prefix = "123-account"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-account"

  depends_on = [module.vault]
}

module "gateway" {
  source = "../../modules/gateway"

  environment     = var.environment
  db_user         = "gateway"
  db_password     = "33fc0cc8-b0e3-4c06-8cf6-c7dce2705329"
  endpoint_password_prefix = "123-gateway"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-gateway"

  depends_on = [module.vault]
}

module "payment" {
  source = "../../modules/payment"

  environment     = var.environment
  db_user         = "payment"
  db_password     = "821462d7-47fb-402c-a22a-a58867602e39"
  endpoint_password_prefix = "123-payment"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-payment"

  depends_on = [module.vault]
}