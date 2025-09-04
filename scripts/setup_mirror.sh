#!/usr/bin/env bash
set -euo pipefail
: "${GIT_REMOTE_URI:?missing GIT_REMOTE_URI}"
: "${DEFAULT_BRANCH:=main}"
: "${MIRROR_REMOTE_NAME:=gitlab}"
: "${BARE_REPO_PATH:=/srv/git/repo.git}"
mkdir -p "$(dirname "$BARE_REPO_PATH")"
if [[ ! -d "$BARE_REPO_PATH" ]]; then
  git clone --bare --initial-branch="$DEFAULT_BRANCH" "$GIT_REMOTE_URI" "$BARE_REPO_PATH"
  git -C "$BARE_REPO_PATH" remote rename origin "$MIRROR_REMOTE_NAME"
fi
mkdir -p "$BARE_REPO_PATH/hooks"
cat > "$BARE_REPO_PATH/hooks/update" <<'SH'
#!/bin/sh
refname="$1"
case "$refname" in
  refs/heads/contribute/*) exit 0 ;;
  refs/tags/*)             exit 0 ;;
  *) echo "Denied: protected ref $refname" >&2; exit 1 ;;
esac
SH
chmod +x "$BARE_REPO_PATH/hooks/update"
cat > "$BARE_REPO_PATH/hooks/post-receive" <<SH
#!/bin/sh
set -eu
git push --mirror "$MIRROR_REMOTE_NAME"
git gc --auto || true
SH
chmod +x "$BARE_REPO_PATH/hooks/post-receive"
echo "[ok] bare mirror ready at $BARE_REPO_PATH"
