variable "org_id" {
  type        = string
  description = "Infisical organization id."
}

variable "display_name" {
  type        = string
  description = "Human/project name for the service."
}

variable "slug" {
  type        = string
  description = "URL-safe id: project slug and identity name prefix."
}

variable "environment_slug" {
  type        = string
  description = "Environment slug secrets live under (Infisical default project has dev/staging/prod)."
  default     = "prod"
}

variable "trusted_ips" {
  type        = list(string)
  description = "CIDRs the machine identity may authenticate from."
  default     = ["0.0.0.0/0"]
}

variable "import_common" {
  type        = bool
  description = "Import shared keys from the platform-common project."
  default     = false
}

variable "common_project_id" {
  type        = string
  description = "platform-common project id (source for shared-secret import)."
  default     = ""
}
