#!/usr/bin/env bash
set -euo pipefail

echo "Oops... deleting the demo namespace by accident"
kubectl delete namespace demo --wait=true
echo
kubectl get ns
echo
if kubectl get namespace demo >/dev/null 2>&1; then
  echo "FAIL: namespace demo still exists"; exit 1
else
  echo "-> namespace demo and nginx are gone (expected)"
fi
