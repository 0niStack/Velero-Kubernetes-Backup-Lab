#!/usr/bin/env bash
set -euo pipefail
echo "== Resources =="
kubectl -n demo get deploy,svc,pods,cm
echo
echo "== curl http://localhost:8080 =="
for i in $(seq 1 10); do
  if curl -fsS --max-time 3 http://localhost:8080 | grep -qi "Hello from nginx"; then
    echo "OK: nginx restored and serving"
    exit 0
  fi
  sleep 3
done
echo "FAIL: nginx not serving after restore"
exit 1
