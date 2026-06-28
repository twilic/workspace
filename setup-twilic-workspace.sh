#!/usr/bin/env sh
#
# Clone all repositories from the twilic GitHub organization and generate a VS Code workspace file.
#
# Requirements: git, gh (GitHub CLI, authenticated)
#
# Usage:
#   ./setup-twilic-workspace.sh
#

set -eu

ORG=twilic
WORKSPACE_FILE=twilic.code-workspace
LIMIT="${REPO_LIMIT:-1000}"

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' is required but not installed."
}

require_cmd git
require_cmd gh

if ! gh auth status >/dev/null 2>&1; then
  die "gh is not authenticated. Run: gh auth login"
fi

if ! gh api "orgs/${ORG}" >/dev/null 2>&1; then
  die "cannot access organization '${ORG}'. Check the org name and your GitHub permissions."
fi

TARGET_DIR=$(pwd)
printf 'target directory: %s\n' "$TARGET_DIR"
printf 'workspace file:   %s\n' "$WORKSPACE_FILE"
printf '\n'

TMP_REPOS=$(mktemp 2>/dev/null || mktemp -t twilic-repos)

if ! gh repo list "$ORG" \
  --limit "$LIMIT" \
  --json name \
  --jq '.[].name' >"$TMP_REPOS"; then
  die "failed to list repositories for organization '${ORG}'"
fi

if [ ! -s "$TMP_REPOS" ]; then
  die "no repositories found for organization '${ORG}'"
fi

REPO_COUNT=0
CLONED_COUNT=0
UPDATED_COUNT=0
FAILED_COUNT=0

TMP_CLONED=$(mktemp 2>/dev/null || mktemp -t twilic-cloned)
trap 'rm -f "$TMP_REPOS" "$TMP_CLONED"' EXIT INT TERM
: >"$TMP_CLONED"

while IFS= read -r repo || [ -n "$repo" ]; do
  [ -n "$repo" ] || continue
  REPO_COUNT=$((REPO_COUNT + 1))

  if [ -d "$repo/.git" ]; then
    printf '[update] %s\n' "$repo"
    if (cd "$repo" && git pull --ff-only 2>/dev/null || git pull); then
      UPDATED_COUNT=$((UPDATED_COUNT + 1))
      printf '%s\n' "$repo" >>"$TMP_CLONED"
    else
      FAILED_COUNT=$((FAILED_COUNT + 1))
      printf 'warning: failed to update %s\n' "$repo" >&2
    fi
    continue
  fi

  if [ -e "$repo" ]; then
    FAILED_COUNT=$((FAILED_COUNT + 1))
    printf 'warning: skipping %s (path exists but is not a git repository)\n' "$repo" >&2
    continue
  fi

  printf '[clone] %s/%s\n' "$ORG" "$repo"
  if gh repo clone "${ORG}/${repo}" "$repo"; then
    CLONED_COUNT=$((CLONED_COUNT + 1))
    printf '%s\n' "$repo" >>"$TMP_CLONED"
  else
    FAILED_COUNT=$((FAILED_COUNT + 1))
    printf 'warning: failed to clone %s/%s\n' "$ORG" "$repo" >&2
  fi
done <"$TMP_REPOS"

if [ ! -s "$TMP_CLONED" ]; then
  die "no repositories were cloned or updated successfully"
fi

{
  printf '{\n'
  printf '  "folders": [\n'

  first=1
  while IFS= read -r repo || [ -n "$repo" ]; do
    [ -n "$repo" ] || continue
    if [ "$first" -eq 1 ]; then
      first=0
    else
      printf ',\n'
    fi
    # Escape backslashes and double quotes for JSON string values.
    escaped_repo=$(printf '%s' "$repo" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '    { "path": "./%s" }' "$escaped_repo"
  done <"$TMP_CLONED"

  printf '\n  ],\n'
  printf '  "settings": {}\n'
  printf '}\n'
} >"$WORKSPACE_FILE"

printf '\n'
printf 'done.\n'
printf '  repositories found:  %s\n' "$REPO_COUNT"
printf '  cloned:              %s\n' "$CLONED_COUNT"
printf '  updated:             %s\n' "$UPDATED_COUNT"
printf '  failed:              %s\n' "$FAILED_COUNT"
printf '  workspace file:      %s\n' "$WORKSPACE_FILE"
printf '\n'
printf 'open with: code "%s"\n' "$WORKSPACE_FILE"
