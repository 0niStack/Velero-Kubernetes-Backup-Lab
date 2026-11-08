#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Pick a plugin version compatible with your Velero CLI (see velero/velero-plugin-for-aws releases)
AWS_PLUGIN="${AWS_PLUGIN:-velero/velero-plugin-for-aws:v1.11.0}"

command -v velero >/dev/null || { echo "Missing: velero CLI"; exit 1; }

echo "== 1/3 MinIO =="
kubectl apply -f minio.yaml
kubectl -n velero rollout status deployment/minio --timeout=180s
kubectl -n velero wait --for=condition=complete job/minio-create-bucket --timeout=180s

echo "== 2/3 Velero install =="
velero install \
  --provider aws \
  --plugins "$AWS_PLUGIN" \
  --bucket velero \
  --secret-file ./credentials-velero \
  --use-volume-snapshots=false \
  --backup-location-config region=minio,s3ForcePathStyle=true,s3Url=http://minio.velero.svc:9000 \
  --wait

echo "== 3/3 Verify =="
velero backup-location get
