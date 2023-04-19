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

module "vault" {

  source = "../../modules/vault"

  environment     = var.environment
  vault_address = "http://localhost:8201"
  vault_token = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
  vault_audit_file_path = "/vault/logs/audit"
  vault_auth_backend_type = "userpass"
}

module "frontend" {
  source = "../../modules/frontend"

  environment     = var.environment
  internal_port   = 80
  external_port   = 4080
  image = "docker.io/nginx:latest"
}

module "account" {
  source = "../../modules/account"

  environment     = var.environment
  db_user         = "account"
  db_password     = "965d3c27-9e20-4d41-91c9-61e6631870e7"
  endpoint_password_prefix = "123-account"
  
  container_vault_address = var.container_vault_address
  container_password_prefix = "123-account"
}

module "gateway" {
  source = "../../modules/gateway"

  environment     = var.environment
  db_user         = "gateway"
  db_password     = "10350819-4802-47ac-9476-6fa781e35cfd"
  endpoint_password_prefix = "123-gateway"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-gateway"
}

module "payment" {
  source = "../../modules/payment"

  environment     = var.environment
  db_user         = "payment"
  db_password     = "a63e8938-6d49-49ea-905d-e03a683059e7"
  endpoint_password_prefix = "123-payment"

  container_vault_address = var.container_vault_address
  container_password_prefix = "123-payment"
}
