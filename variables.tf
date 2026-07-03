# ---------------------------------------------------------------------------
# Metadata module variables
# ---------------------------------------------------------------------------

variable "name" {
  description = "Base name for the infrastructure stack."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment for the infrastructure stack."
  type        = string

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must not be empty."
  }
}

variable "extra_tags" {
  description = "Additional tags to merge into the default tag set."
  type        = map(string)
  default     = {}
}

variable "repository_name" {
  description = "Repository name recorded in the default tags."
  type        = string
  default     = "Quantum-L9/infra"
}

# ---------------------------------------------------------------------------
# Infisical provider variables
# ---------------------------------------------------------------------------

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
