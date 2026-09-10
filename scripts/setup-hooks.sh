#!/usr/bin/env bash
# Points this clone's git hooks at the tracked `.githooks/` directory.
#
# Run once per clone, from either repo — this file is byte-identical in
# the product repo (`Scripts/`) and the hub (`scripts/`):
#
#   Scripts/setup-hooks.sh        # a product repo
#   scripts/setup-hooks.sh        # the hub
#
# `core.hooksPath` is per-clone local config — it cannot be committed, which is
# the one part of this mechanism that has to be done by hand. Everything else
# is in the repo. Running it twice is harmless; `--check` reports without
# changing anything and exits non-zero when the hooks are not wired up.
#
# What the hooks do: `.githooks/prepare-commit-msg` seeds the commit message
# from a session's `.commit-subject` and says what is actually staged;
# `.githooks/post-commit` removes that file once a commit lands. Neither can
# block a commit. Rationale: `Docs/Conventions.md` → Git.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WANTED=".githooks"
CURRENT="$(git config --get core.hooksPath || true)"

if [[ "${1:-}" == "--check" ]]; then
  if [[ "$CURRENT" == "$WANTED" ]]; then
    echo "hooks: core.hooksPath = $WANTED"
    exit 0
  fi
  echo "hooks: NOT wired up (core.hooksPath = ${CURRENT:-unset})" >&2
  echo "       run $0" >&2
  exit 1
fi

if [[ -n "$CURRENT" && "$CURRENT" != "$WANTED" ]]; then
  echo "hooks: core.hooksPath is already set to '$CURRENT'." >&2
  echo "       Not overwriting it — something else in this clone owns hooks." >&2
  echo "       Set it by hand if that is stale: git config core.hooksPath $WANTED" >&2
  exit 1
fi

chmod +x "$ROOT/$WANTED"/* 2>/dev/null || true
git config core.hooksPath "$WANTED"

echo "hooks: core.hooksPath = $WANTED"
for hook in "$ROOT/$WANTED"/*; do
  [[ -f "$hook" ]] && echo "       $(basename "$hook")"
done
