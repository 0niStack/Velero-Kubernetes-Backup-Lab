#!/usr/bin/env bash
set -euo pipefail
BACKUP="${1:-nginx-backup}"

velero restore create --from-backup "$BACKUP" --wait
velero restore get
kubectl -n demo rollout status deployment/nginx --timeout=120s
kubectl -n demo get deploy,svc,pods,cm
