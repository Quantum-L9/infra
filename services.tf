locals {
  # ── The service registry ──────────────────────────────────────────────────
  # Add a repo/service to secret management by adding ONE entry here, then
  # `terraform apply` + issue-client-secret.sh. Each entry gets its own Infisical
  # project + a read-only machine identity scoped to it.
  #
  #   display_name  : human name / Infisical project name
  #   slug          : url-safe id (project slug + identity name prefix)
  #   trusted_ips   : CIDRs the runtime may authenticate from (lock to the VPS /
  #                   CI egress where possible; 0.0.0.0/0 = anywhere)
  #   import_common : pull shared keys from platform-common (see common.tf).
  #                   Left false until you confirm cross-project secret_import in
  #                   your pinned provider version — flip to true after that.
  services = {
    seo_bot = {
      display_name  = "SEO-Bot"
      slug          = "seo-bot"
      trusted_ips   = ["0.0.0.0/0"]
      import_common = false
    }
    website_bot = {
      display_name  = "Website-Bot"
      slug          = "website-bot"
      trusted_ips   = ["0.0.0.0/0"]
      import_common = false
    }
  }
}
