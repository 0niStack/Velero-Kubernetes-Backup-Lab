#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
CLUSTER=velero-lab

for bin in docker kind kubectl; do
  command -v "$bin" >/dev/null || { echo "Missing: $bin"; exit 1; }
done

if kind get clusters | grep -qx "$CLUSTER"; then
  echo "Cluster '$CLUSTER' already exists, skipping create"
else
  kind create cluster --name "$CLUSTER" --config kind-config.yaml
fi

kubectl config use-context "kind-$CLUSTER"
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl get nodes -o wide
