locals {
  name        = lower(replace(trimspace(var.name), " ", "-"))
  environment = lower(trimspace(var.environment))
  tags = merge({
    Name        = local.name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Repository  = "Quantum-L9/infra"
  }, var.extra_tags)
}
