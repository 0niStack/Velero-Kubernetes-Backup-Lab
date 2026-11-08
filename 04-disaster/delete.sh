#!/usr/bin/env bash
set -euo pipefail
URL="${URL:-http://localhost:8080}"

echo "Oops... deleting the demo namespace by accident"
kubectl delete namespace demo --wait=true
echo
kubectl get ns
echo
echo "Confirm it's gone:"
curl -sS --max-time 3 "$URL" || echo "-> nginx is DOWN (expected)"
