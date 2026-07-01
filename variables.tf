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
