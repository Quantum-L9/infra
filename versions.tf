terraform {
  required_version = ">= 1.6.0"

  required_providers {
    infisical = {
      source = "Infisical/infisical"
      # Pin to the version you validate against; attribute schemas can shift
      # between minors. Bump deliberately after re-running `terraform plan`.
      version = "~> 0.15"
    }
  }
}
