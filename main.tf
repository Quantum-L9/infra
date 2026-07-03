# Metadata module: normalizes stack name, environment, and tags for downstream use.
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

# Fan the service registry out over the reusable module: one project + identity +
# read-only binding (+ optional shared-secret import) per entry.
module "service" {
  source   = "./modules/infisical-service"
  for_each = local.services

  org_id            = var.org_id
  display_name      = each.value.display_name
  slug              = each.value.slug
  environment_slug  = "prod"
  trusted_ips       = each.value.trusted_ips
  import_common     = each.value.import_common
  common_project_id = infisical_project.common.id
}
