# HANDOFF — push this to Quantum-L9/infra

This repo was generated in a session where `Quantum-L9/infra` was **out of GitHub
scope**, so it couldn't be pushed from there. Push it from a session/terminal
where the repo is writable.

## What this is
Pillars 1–2 of the unified Infisical plan: the central Terraform (per-app projects +
read-only machine identities + `platform-common`) with an S3/DynamoDB backend, plus
`scripts/issue-client-secret.sh` (mints the Universal Auth client secret out-of-band)
and `bootstrap/bootstrap-state.sh` (creates the state bucket + lock table). See
`README.md` for the full runbook.

## Option A — push the included git bundle (preserves the commit)
```bash
git clone infra.bundle infra && cd infra
git remote set-url origin https://github.com/Quantum-L9/infra.git
git push -u origin main
```

## Option B — push the tarball contents
```bash
mkdir infra && tar -xzf infra.tar.gz -C infra && cd infra
git init -b main && git add . && git commit -m "chore: bootstrap infra (Infisical Terraform + scripts)"
git remote add origin https://github.com/Quantum-L9/infra.git
git push -u origin main
```

## Before it will `apply` (do these on your side)
1. **Not validated locally** — Terraform CLI wasn't available in the generating env.
   Run first: `terraform init && terraform validate && terraform plan`.
2. **Provider attribute schemas** — resource *names* target the `Infisical/infisical`
   provider, but a few *attributes* (e.g. `infisical_identity_universal_auth.client_id`
   output, and the cross-project `infisical_secret_import` source) can differ by
   version. `terraform plan` will flag any mismatch; adjust and re-plan. `import_common`
   ships `false` so the base apply is clean before you wire shared-secret imports.
3. **Bootstrap** — create the terraform-admin identity by hand, export
   `TF_VAR_org_id` / `TF_VAR_tf_provisioner_client_id` / `TF_VAR_tf_provisioner_client_secret`,
   run `./bootstrap/bootstrap-state.sh`, then `terraform apply`.

## Then (Pillars 3–4, still to do — need their repos in scope)
- Publish `@quantum-l9/infisical-config` (generalize SEO-Bot's `secrets.ts`) — needs a
  package repo connected.
- Retrofit SEO-Bot (npm loader) + Website-Bot (`infisical run` in CI).

## Security note
No secret values or client secrets are in this repo. `*.tfvars` and `*.infisical.env`
are gitignored. Keep the terraform-admin credentials in env only.
