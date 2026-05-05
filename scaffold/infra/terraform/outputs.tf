output "bucket_name" {
  description = "Nombre del bucket S3 creado"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.main.arn
}

output "bucket_region" {
  description = "Región del bucket"
  value       = aws_s3_bucket.main.region
}

output "bucket_domain_name" {
  description = "Domain name del bucket (acceso vía S3 API)"
  value       = aws_s3_bucket.main.bucket_domain_name
}
