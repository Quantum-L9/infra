# ── platform-common ───────────────────────────────────────────────────────────
# One project for secrets shared by more than one service (e.g. OPENROUTER_API_KEY,
# PERPLEXITY_API_KEY, DATAFORSEO_LOGIN/PASSWORD). Only the project structure is
# codified; the values are entered in the Infisical UI/CLI. Per-service projects
# then import from here (see modules/infisical-service, gated by import_common)
# so a shared key is rotated in exactly one place.
resource "infisical_project" "common" {
  name = "platform-common"
  slug = "platform-common"
}
