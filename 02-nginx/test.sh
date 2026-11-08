#!/usr/bin/env bash
set -euo pipefail
URL="${URL:-http://localhost:8080}"

echo "== curl $URL =="
if curl -fsS --max-time 5 "$URL" | grep -qi "Hello from nginx"; then
  echo "OK: nginx is serving"
else
  echo "FAIL: nginx not reachable"; exit 1
fi
