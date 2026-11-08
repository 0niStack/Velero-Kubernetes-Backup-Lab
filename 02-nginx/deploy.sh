#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml -f deployment.yaml -f service.yaml
kubectl -n demo rollout status deployment/nginx --timeout=120s
kubectl -n demo get deploy,svc,pods,cm
echo
echo "Test: curl http://localhost:8080"
