provider "infisical" {
  # Defaults to Infisical Cloud; override for a self-hosted instance.
  host = var.infisical_host

  # Authenticate as the hand-created "terraform-admin" machine identity.
  # Credentials come from TF_VAR_* env, never a committed tfvars.
  auth {
    universal_auth {
      client_id     = var.tf_provisioner_client_id
      client_secret = var.tf_provisioner_client_secret
    }
  }
}
