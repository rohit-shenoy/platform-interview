output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.payment_container.id
}