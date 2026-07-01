# Quantum-L9 · infra

Infrastructure-as-code for the org's secret management (Infisical). **Terraform owns
the _structure_** — projects, machine identities, read-only access, shared-secret
imports. Two things are deliberately **out** of Terraform:

- **Secret _values_** — entered in Infisical (UI/CLI); never in Git or TF state.
- **Universal Auth _client secrets_** — minted out-of-band by `scripts/issue-client-secret.sh`
  so they never land in the S3 state file.

Adding a new repo/service to secret management = **one entry in `services.tf`** + one
`issue-client-secret.sh` run. See the full design in the session plan (Pillars 1–4).

> ⚠️ **Provider schema:** resource _names_ here are correct for the `Infisical/infisical`
> provider, but attribute names occasionally change between provider versions. Run
> `terraform init && terraform validate && terraform plan` first and adjust any
> attribute the plan flags. Pin the version in `versions.tf`.

## Topology
- **One Infisical project per app** (blast-radius isolation) — a compromised identity
  can only read its own project.
- **One `platform-common` project** for keys shared across apps (e.g. `OPENROUTER_API_KEY`,
  `PERPLEXITY_API_KEY`, `DATAFORSEO_*`). Consumed via `infisical_secret_import` so you
  rotate them once. (Import is opt-in per service — see `services.tf`.)

## One-time bootstrap
1. **Provisioner identity** — in Infisical, create a machine identity (org-admin scope)
   by hand. Its Universal Auth `client_id` / `client_secret` drive the Terraform provider.
   Pass them as env, never commit:
   ```bash
   export TF_VAR_org_id=<infisical-org-id>
   export TF_VAR_tf_provisioner_client_id=<provisioner-client-id>
   export TF_VAR_tf_provisioner_client_secret=<provisioner-client-secret>
   ```
2. **State backend** — create the encrypted S3 bucket + DynamoDB lock table:
   ```bash
   ./bootstrap/bootstrap-state.sh          # uses your AWS credentials
   ```
   Then set the matching `bucket` / `dynamodb_table` / `region` in `backend.tf`.
3. **Apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
   Creates the per-app projects, machine identities, read-only bindings, and the
   `platform-common` project.

## Issue a runtime client secret (per service)
```bash
export INFISICAL_ADMIN_CLIENT_ID=<provisioner-client-id>
export INFISICAL_ADMIN_CLIENT_SECRET=<provisioner-client-secret>

# from `terraform output identities`
./scripts/issue-client-secret.sh <identity_id> <project_id> --format systemd
# or push straight into a repo's Actions secrets:
./scripts/issue-client-secret.sh <identity_id> <project_id> --github-repo Quantum-L9/Website-Bot
```
Delivers the 3 bootstrap vars (`INFISICAL_CLIENT_ID`, `INFISICAL_CLIENT_SECRET`,
`INFISICAL_PROJECT_ID`). Rotation = re-run, update destination, revoke the old secret.

## Add a new service
1. Add an entry to `local.services` in `services.tf`.
2. `terraform apply`.
3. `./scripts/issue-client-secret.sh` for the new identity → deliver bootstrap vars.
4. Enter the service's secret values in its Infisical project.

## Runtime consumption (the "both" model)
- **Node long-running services** (e.g. SEO-Bot): `@quantum-l9/infisical-config` loader,
  in-process, one `await loadSecrets()` before config.
- **CI / serverless / non-Node** (e.g. Website-Bot Actions): `infisical run -- <cmd>`.
Both use the same identity + the 3 bootstrap vars.
