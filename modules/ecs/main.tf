resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name  = var.project
    image = "${var.ecr_repo_url}:latest"
    portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
    environment = [
      { name = "REDIS_HOST", value = var.redis_endpoint },
      { name = "REDIS_PORT", value = "6379" },
      { name = "REDIS_PASSWORD", value = var.redis_password }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups = [var.alb_security_group_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.project
    container_port   = var.container_port
  }
  depends_on = [var.target_group_arn]
}

resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.project}-${var.environment}-ecs-sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [var.alb_security_group_id] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB"
  type        = string
}
