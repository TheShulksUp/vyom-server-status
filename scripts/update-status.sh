#!/usr/bin/env bash
# Usage: ./scripts/update-status.sh macos   OR   ./scripts/update-status.sh fedora
set -euo pipefail

system="${1:-}"
case "$system" in
  macos|fedora) ;;
  *) echo "Usage: $0 {macos|fedora}" >&2; exit 1 ;;
esac

updated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '{\n  "system": "%s",\n  "updatedAt": "%s"\n}\n' "$system" "$updated_at" > status.json

git add status.json
if git diff --cached --quiet; then
  exit 0
fi
git commit -m "status: ${system} heartbeat"
git push origin main
