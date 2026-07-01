output "name" {
  description = "Normalized infrastructure stack name."
  value       = local.name
}

output "environment" {
  description = "Normalized deployment environment."
  value       = local.environment
}

output "tags" {
  description = "Merged default and custom tags for downstream resources."
  value       = local.tags
}
