#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

AWS_PLUGIN="${AWS_PLUGIN:-velero/velero-plugin-for-aws:v1.11.0}"

command -v velero >/dev/null || { echo "Missing: velero CLI"; exit 1; }

echo "== 1/3 RustFS =="
kubectl apply -f rustfs.yaml
kubectl -n velero rollout status deployment/rustfs --timeout=300s
kubectl -n velero wait --for=condition=complete job/rustfs-create-bucket --timeout=300s

echo "== 2/3 Velero install =="
velero install \
  --provider aws \
  --plugins "$AWS_PLUGIN" \
  --bucket velero \
  --secret-file ./credentials-velero \
  --use-volume-snapshots=false \
  --backup-location-config region=us-east-1,s3ForcePathStyle=true,s3Url=http://rustfs.velero.svc:9000 \
  --wait

echo "== 3/3 Verify =="
velero backup-location get
