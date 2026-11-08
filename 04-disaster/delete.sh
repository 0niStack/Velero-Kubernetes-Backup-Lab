#!/usr/bin/env bash
set -euo pipefail
echo "Oops... deleting the demo namespace by accident"
kubectl delete namespace demo --wait=true
echo
kubectl get ns
echo
echo "Confirm it's gone:"
curl -sS --max-time 3 http://localhost:8080 || echo "-> nginx is DOWN (expected)"
