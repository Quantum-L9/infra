output "identity_id" {
  description = "Machine identity id (feed to issue-client-secret.sh)."
  value       = infisical_identity.this.id
}

output "client_id" {
  description = "Universal Auth client id for the runtime (INFISICAL_CLIENT_ID)."
  value       = infisical_identity_universal_auth.this.client_id
}

output "project_id" {
  description = "The app's Infisical project id (INFISICAL_PROJECT_ID)."
  value       = infisical_project.this.id
}
