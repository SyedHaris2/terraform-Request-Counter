provider "aws" { region = var.region }

module "vpc" {
  source        = "./modules/vpc"
  project       = var.app_name
  environment   = var.environment
  vpc_cidr      = var.vpc_cidr
  public_cidrs  = var.public_subnet_cidrs
  private_cidrs = var.private_subnet_cidrs
}

module "alb" {
  source            = "./modules/alb"
  project           = var.app_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
  container_sg_id   = module.ecs.ecs_sg_id
}

module "redis" {
  source             = "./modules/redis"
  project            = var.app_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  container_sg_id    = module.ecs.ecs_sg_id
}

module "ecs" {
  source                = "./modules/ecs"
  project               = var.app_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  container_port        = var.container_port
  desired_count         = var.desired_count
  cpu                   = var.cpu
  memory                = var.memory
  ecr_repo_url          = aws_ecr_repository.app.repository_url
  redis_endpoint        = module.redis.redis_endpoint
  redis_password        = module.redis.redis_password
  target_group_arn      = module.alb.tg_arn
  execution_role_arn    = aws_iam_role.ecs_execution.arn
  task_role_arn         = aws_iam_role.ecs_task.arn
  alb_security_group_id = module.alb.alb_sg_id
}

resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
}

# IAM roles (could be moved to module later)
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name_prefix         = "${var.app_name}-exec-"
  assume_role_policy  = data.aws_iam_policy_document.ecs_assume.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role" "ecs_task" {
  name_prefix        = "${var.app_name}-task-"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
  inline_policy {
    name = "secrets"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = module.redis.redis_secret_arn
      }]
    })
  }
}