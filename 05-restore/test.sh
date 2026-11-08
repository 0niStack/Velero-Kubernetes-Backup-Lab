#!/usr/bin/env bash
set -euo pipefail
URL="${URL:-http://localhost:8080}"

echo "== Resources =="
kubectl -n demo get deploy,svc,pods,cm
echo
echo "== curl $URL =="
for i in $(seq 1 10); do
  if curl -fsS --max-time 3 "$URL" | grep -qi "Hello from nginx"; then
    echo "OK: nginx restored and serving"
    exit 0
  fi
  sleep 3
done
echo "FAIL: nginx not serving after restore"
exit 1
