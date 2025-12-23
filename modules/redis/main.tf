resource "random_password" "auth" { 
  length = 32
  special = true
  override_special = "_-" 
  }

resource "aws_secretsmanager_secret" "redis" {
  name = "${var.project}-${var.environment}-redis-auth"
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id     = aws_secretsmanager_secret.redis.id
  secret_string = random_password.auth.result
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.project}-${var.environment}-redis-sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.container_sg_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-redis"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project}-${var.environment}-redis"
  description                = "redis for ${var.project}"
  port                       = 6379
  parameter_group_name       = "default.redis7"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 2
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.redis.id]
  auth_token                 = random_password.auth.result
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  apply_immediately          = true
}