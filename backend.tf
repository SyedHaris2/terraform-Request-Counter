# backend.tf
terraform {
  backend "s3" {
    bucket         = "tf-state-haris-1766491516"   # <-- paste your real bucket
    key            = "request-counter/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
    encrypt        = true
  }
}