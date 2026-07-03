terraform {
  # Remote, encrypted, locked state. Machine-identity metadata flows through
  # state, so it must not live on a laptop. Create the bucket + table first with
  # ./bootstrap/bootstrap-state.sh, then match the names below.
  backend "s3" {
    bucket         = "quantum-l9-tfstate"
    key            = "infisical/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "quantum-l9-tflock"
    encrypt        = true
  }
}
