# infra

Reusable Terraform module for normalizing infrastructure stack metadata.

## Usage

```hcl
module "infra_metadata" {
  source = "github.com/Quantum-L9/infra"

  name        = "api"
  environment = "production"
  extra_tags = {
    Team = "platform"
  }

  repository_name = "Quantum-L9/infra"
}
```

## Outputs

- `name`: normalized stack name
- `environment`: normalized deployment environment
- `tags`: merged default and custom tags