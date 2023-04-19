terraform {
  required_version = ">= 1.0.7"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

resource "docker_container" "frontend" {
  image = "${var.image}"
  name  = "frontend_${var.environment}"

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  networks_advanced {
    name = "vagrant_${var.environment}"
  }

  lifecycle {
    ignore_changes = all
  }
}