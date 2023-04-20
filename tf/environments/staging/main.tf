module "vault" {

  source = "../../modules/vault"

  environment             = var.environment
  vault_audit_file_path   = "/vault/logs/audit"
  vault_auth_backend_type = "userpass"
}

module "frontend" {
  source = "../../modules/frontend"

  environment     = var.environment
  internal_port   = 80
  external_port   = 4082
  image           = "docker.io/nginx:1.22.0-alpine"
}


module "account" {
  source = "../../modules/account"

  environment              = var.environment
  db_user                  = "account"
  #db_password              = "645e82e8-67d9-5c1q-de2a-c256bb6f5544"
  db_password              = "965d3c27-9e20-4d41-91c9-61e6631870e7"
  endpoint_password_prefix = "123-account"

  container_vault_address   = var.container_vault_address
  container_password_prefix = "123-account"

  depends_on = [module.vault]
}

module "gateway" {
  source = "../../modules/gateway"

  environment     = var.environment
  db_user         = "gateway"
  #db_password     = "22eb9bb7-a9d2-3b95-7be5-b6cbd1694218"
  db_password     = "10350819-4802-47ac-9476-6fa781e35cfd"
  endpoint_password_prefix = "123-gateway"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-gateway"

  depends_on = [module.vault]
}

module "payment" {
  source = "../../modules/payment"

  environment     = var.environment
  db_user         = "payment"
  #db_password     = "719351c6-36ea-39ba-z11z-z47656591d28"
  db_password     = "a63e8938-6d49-49ea-905d-e03a683059e7"
  endpoint_password_prefix = "123-payment"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-payment"

  depends_on = [module.vault]
}