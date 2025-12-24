variable "project" {}
variable "environment" {}
variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "container_port" {}
variable "container_sg_id" {}