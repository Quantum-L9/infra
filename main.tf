locals {
  name        = lower(replace(trimspace(var.name), " ", "-"))
  environment = lower(trimspace(var.environment))
  tags = merge({
    Name        = local.name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Repository  = var.repository_name
  }, var.extra_tags)
}
