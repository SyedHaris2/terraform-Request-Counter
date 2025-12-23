output "redis_endpoint" { value = aws_elasticache_replication_group.main.primary_endpoint_address }
output "redis_secret_arn" { value = aws_secretsmanager_secret.redis.arn }
output "redis_password" { value = random_password.auth.result }