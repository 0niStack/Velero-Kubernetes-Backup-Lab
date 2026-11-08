#!/usr/bin/env bash
set -euo pipefail

VELERO_VERSION="${VELERO_VERSION:-v1.15.2}"
ARCH="$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/')"
TMP="$(mktemp -d)"

if command -v velero >/dev/null; then
  echo "velero already installed:"
  velero version --client-only
  exit 0
fi

echo "Installing velero ${VELERO_VERSION} (${ARCH})..."
curl -fsSL -o "$TMP/velero.tar.gz" \
  "https://github.com/vmware-tanzu/velero/releases/download/${VELERO_VERSION}/velero-${VELERO_VERSION}-linux-${ARCH}.tar.gz"
tar -xzf "$TMP/velero.tar.gz" -C "$TMP"
sudo install -m 0755 "$TMP/velero-${VELERO_VERSION}-linux-${ARCH}/velero" /usr/local/bin/velero
rm -rf "$TMP"

velero version --client-only
