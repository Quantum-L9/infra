#!/usr/bin/env bash
#
# One-time: create the encrypted, versioned S3 bucket + DynamoDB lock table that
# backend.tf uses for remote Terraform state. Run with AWS credentials that can
# create these resources. Idempotent-ish: skips creation if they already exist.
#
# Env overrides:
#   AWS_REGION        default us-east-1
#   TF_STATE_BUCKET   default quantum-l9-tfstate   (must match backend.tf)
#   TF_LOCK_TABLE     default quantum-l9-tflock     (must match backend.tf)
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
BUCKET="${TF_STATE_BUCKET:-quantum-l9-tfstate}"
TABLE="${TF_LOCK_TABLE:-quantum-l9-tflock}"
command -v aws >/dev/null || { echo "aws CLI is required" >&2; exit 1; }

echo "Region=$REGION Bucket=$BUCKET Table=$TABLE"

# ── S3 state bucket ───────────────────────────────────────────────────────────
if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "bucket $BUCKET already exists — skipping create"
else
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=$REGION"
  fi
fi

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# ── DynamoDB lock table ───────────────────────────────────────────────────────
if aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" >/dev/null 2>&1; then
  echo "table $TABLE already exists — skipping create"
else
  aws dynamodb create-table --table-name "$TABLE" --region "$REGION" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
fi

echo "✅ State backend ready. Ensure backend.tf uses bucket=$BUCKET table=$TABLE region=$REGION, then: terraform init"
