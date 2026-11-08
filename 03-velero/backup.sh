#!/usr/bin/env bash
set -euo pipefail
BACKUP="${1:-nginx-backup}"

velero backup create "$BACKUP" --include-namespaces demo --wait
velero backup describe "$BACKUP"
velero backup get
