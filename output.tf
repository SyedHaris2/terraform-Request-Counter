output "alb_dns" {
  value       = module.alb.alb_dns
  description = "HTTP endpoint – curl this!"
}

output "ecr_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "docker push target"
}