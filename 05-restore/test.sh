#!/usr/bin/env bash
set -euo pipefail
LOCAL_PORT="${LOCAL_PORT:-8081}"

echo "== Resources =="
kubectl -n demo get deploy,svc,pods,cm
echo

kubectl -n demo rollout status deployment/nginx --timeout=120s

kubectl -n demo port-forward svc/nginx-svc "${LOCAL_PORT}:80" >/dev/null 2>&1 &
PF_PID=$!
trap 'kill $PF_PID 2>/dev/null || true' EXIT

echo "== curl http://localhost:${LOCAL_PORT} (via port-forward) =="
for i in $(seq 1 10); do
  if curl -fsS --max-time 3 "http://localhost:${LOCAL_PORT}" | grep -qi "Hello from nginx"; then
    echo "OK: nginx restored and serving"
    exit 0
  fi
  sleep 1
done
echo "FAIL: nginx not serving after restore"
exit 1
