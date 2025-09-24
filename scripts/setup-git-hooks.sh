#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "${REPO_ROOT_DIR}" ]]; then
  echo "Run this script from within a Git repository." >&2
  exit 1
fi
cd "$REPO_ROOT_DIR"

HOOKS_DIR=".githooks"
HOOK_FILE="$HOOKS_DIR/pre-commit"

if [[ ! -f "$HOOK_FILE" ]]; then
  echo "Hook file '$HOOK_FILE' not found. Aborting." >&2
  exit 1
fi

chmod +x "$HOOK_FILE"
git config core.hooksPath "$HOOKS_DIR"

echo "Git hooks configured: core.hooksPath -> $HOOKS_DIR"
echo "Pre-commit hook is executable. You're all set."

