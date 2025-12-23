variable "project"     {}
variable "environment" {}
variable "vpc_id"      {}
variable "private_subnet_ids" { type = list(string) }
variable "container_port"    {}
variable "desired_count"     {}
variable "cpu"               {}
variable "memory"            {}
variable "ecr_repo_url"      {}
variable "redis_endpoint"    {}
variable "redis_password"    {}
variable "target_group_arn"  {}
variable "execution_role_arn" {}
variable "task_role_arn"    {}