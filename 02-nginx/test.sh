#!/usr/bin/env bash
set -euo pipefail
echo "== curl http://localhost:8080 =="
if curl -fsS --max-time 5 http://localhost:8080 | grep -qi "Hello from nginx"; then
  echo "OK: nginx is serving"
else
  echo "FAIL: nginx not reachable"; exit 1
fi
