#!/usr/bin/env bash
set -euo pipefail
: "${BARE_REPO_PATH:?missing BARE_REPO_PATH}"
git -C "$BARE_REPO_PATH" config receive.denyDeletes true
git -C "$BARE_REPO_PATH" config receive.denyNonFastforwards true
echo "[ok] hardened receive settings"
