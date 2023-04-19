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