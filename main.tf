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
