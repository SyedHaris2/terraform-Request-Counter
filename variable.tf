variable "region" { default = "us-east-1" }
variable "app_name" { default = "counter" }
variable "environment" { default = "dev" }

variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidrs" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnet_cidrs" { default = ["10.0.11.0/24", "10.0.12.0/24"] }

variable "container_port" { default = 3000 }
variable "desired_count" { default = 2 }
variable "cpu" { default = 256 }
variable "memory" { default = 512 }