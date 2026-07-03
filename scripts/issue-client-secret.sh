#!/usr/bin/env bash
#
# Mint a Universal Auth CLIENT SECRET for a machine identity, out-of-band, so it
# never lands in Terraform state. Prints the 3 bootstrap vars a runtime needs.
#
# Usage:
#   export INFISICAL_ADMIN_CLIENT_ID=<terraform-admin client id>
#   export INFISICAL_ADMIN_CLIENT_SECRET=<terraform-admin client secret>
#   ./issue-client-secret.sh <identity_id> <project_id> [--format systemd]
#   ./issue-client-secret.sh <identity_id> <project_id> --github-repo <owner/repo>
#
# Options:
#   --format systemd        write a chmod-600 EnvironmentFile to ./<slug>.infisical.env
#   --github-repo O/R        push the 3 vars as Actions secrets via `gh secret set`
#   (default)               print the 3 export lines to stdout
#
# Env:
#   INFISICAL_HOST          default https://app.infisical.com
#
# Requires: curl, jq  (and `gh` if using --github-repo).
set -euo pipefail

HOST="${INFISICAL_HOST:-https://app.infisical.com}"
IDENTITY_ID="${1:-}"
PROJECT_ID="${2:-}"
MODE="${3:-}"
MODE_ARG="${4:-}"

if [[ -z "$IDENTITY_ID" || -z "$PROJECT_ID" ]]; then
  echo "Usage: $0 <identity_id> <project_id> [--format systemd | --github-repo <owner/repo>]" >&2
  exit 1
fi
: "${INFISICAL_ADMIN_CLIENT_ID:?set INFISICAL_ADMIN_CLIENT_ID (terraform-admin identity)}"
: "${INFISICAL_ADMIN_CLIENT_SECRET:?set INFISICAL_ADMIN_CLIENT_SECRET}"
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

# 1) Authenticate as the admin identity.
TOKEN="$(curl -fsS -X POST "$HOST/api/v1/auth/universal-auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"clientId\":\"$INFISICAL_ADMIN_CLIENT_ID\",\"clientSecret\":\"$INFISICAL_ADMIN_CLIENT_SECRET\"}" \
  | jq -r '.accessToken')"
[[ -n "$TOKEN" && "$TOKEN" != "null" ]] || { echo "admin auth failed" >&2; exit 1; }

# 2) Resolve the target identity's client id.
CLIENT_ID="$(curl -fsS "$HOST/api/v1/auth/universal-auth/identities/$IDENTITY_ID" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.identityUniversalAuth.clientId')"
[[ -n "$CLIENT_ID" && "$CLIENT_ID" != "null" ]] || { echo "could not resolve client id for $IDENTITY_ID" >&2; exit 1; }

# 3) Mint a fresh client secret for it.
CLIENT_SECRET="$(curl -fsS -X POST \
  "$HOST/api/v1/auth/universal-auth/identities/$IDENTITY_ID/client-secrets" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"description":"issued by infra/scripts/issue-client-secret.sh","ttl":0,"numUsesLimit":0}' \
  | jq -r '.clientSecret.clientSecret // .clientSecret')"
[[ -n "$CLIENT_SECRET" && "$CLIENT_SECRET" != "null" ]] || { echo "client secret mint failed" >&2; exit 1; }

case "$MODE" in
  --github-repo)
    REPO="$MODE_ARG"
    [[ -n "$REPO" ]] || { echo "--github-repo needs <owner/repo>" >&2; exit 1; }
    command -v gh >/dev/null || { echo "gh CLI required for --github-repo" >&2; exit 1; }
    gh secret set INFISICAL_CLIENT_ID     --repo "$REPO" --body "$CLIENT_ID"
    gh secret set INFISICAL_CLIENT_SECRET --repo "$REPO" --body "$CLIENT_SECRET"
    gh secret set INFISICAL_PROJECT_ID    --repo "$REPO" --body "$PROJECT_ID"
    echo "✅ Set INFISICAL_CLIENT_ID/_SECRET/_PROJECT_ID as Actions secrets on $REPO"
    ;;
  --format)
    [[ "$MODE_ARG" == "systemd" ]] || { echo "only --format systemd is supported" >&2; exit 1; }
    OUT="./${PROJECT_ID}.infisical.env"
    umask 077
    cat > "$OUT" <<EOF
INFISICAL_CLIENT_ID=$CLIENT_ID
INFISICAL_CLIENT_SECRET=$CLIENT_SECRET
INFISICAL_PROJECT_ID=$PROJECT_ID
EOF
    chmod 600 "$OUT"
    echo "✅ Wrote $OUT (chmod 600). Point systemd EnvironmentFile= at it, then delete this copy."
    ;;
  "")
    cat <<EOF
# Bootstrap vars — deliver to the runtime securely; do NOT commit.
export INFISICAL_CLIENT_ID=$CLIENT_ID
export INFISICAL_CLIENT_SECRET=$CLIENT_SECRET
export INFISICAL_PROJECT_ID=$PROJECT_ID
EOF
    ;;
  *)
    echo "unknown option: $MODE" >&2; exit 1;;
esac
