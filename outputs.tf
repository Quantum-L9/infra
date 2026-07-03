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

output "identities" {
  description = <<-EOT
    Per-service machine identity + project ids. Feed identity_id + project_id to
    scripts/issue-client-secret.sh to mint each runtime's client secret.
    The client SECRET is intentionally NOT here (never in state) — it is issued
    out-of-band.
  EOT
  value = {
    for k, m in module.service : k => {
      identity_id = m.identity_id
      client_id   = m.client_id
      project_id  = m.project_id
    }
  }
}

output "common_project_id" {
  description = "platform-common project id (shared secrets)."
  value       = infisical_project.common.id
}
