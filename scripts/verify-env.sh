#!/usr/bin/env bash
set -euo pipefail
command -v git >/dev/null 2>&1 || { echo "missing: git"; exit 1; }
echo "[ok] git present: $(git --version)"
