variable "environment" {
  type        = string
  description = "The name of the environemnts"
}

variable "image" {
  type        = string
  description = "The image for the frontend container"
}

variable "internal_port" {
  type = number
  default = 80
  description = "The internal port number to use for the frontend container"
}

variable "external_port" {
  type = number
  description = "The external port number to use for the frontend container"
}
