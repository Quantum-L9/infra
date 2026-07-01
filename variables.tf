variable "infisical_host" {
  type        = string
  description = "Infisical API host. Cloud default; set to your self-hosted URL if applicable."
  default     = "https://app.infisical.com"
}

variable "org_id" {
  type        = string
  description = "Infisical organization id that owns the projects/identities."
}

variable "tf_provisioner_client_id" {
  type        = string
  description = "Universal Auth client id of the hand-created terraform-admin identity."
  sensitive   = true
}

variable "tf_provisioner_client_secret" {
  type        = string
  description = "Universal Auth client secret of the terraform-admin identity (pass via TF_VAR_*)."
  sensitive   = true
}
