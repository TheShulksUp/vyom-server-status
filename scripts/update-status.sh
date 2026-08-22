#!/usr/bin/env bash
# Usage: ./scripts/update-status.sh macos   OR   ./scripts/update-status.sh fedora
set -euo pipefail

system="${1:-}"
case "$system" in
  macos|fedora) ;;
  *) echo "Usage: $0 {macos|fedora}" >&2; exit 1 ;;
esac

json_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

if [ "$system" = "macos" ]; then
  os_version="macOS $(sw_vers -productVersion 2>/dev/null || printf 'Unknown')"
else
  # shellcheck disable=SC1091
  . /etc/os-release
  os_version="${PRETTY_NAME:-Fedora Linux}"
fi

architecture="$(uname -m)"
uptime_text="$(uptime | awk -F' up ' '{print $2}' | sed -E 's/,[[:space:]]*[0-9]+ users?.*//')"
disk_space="$(df -h / | awk 'NR == 2 {print $3 " used of " $2 " (" $5 ")"}')"
if pgrep -x nginx >/dev/null 2>&1; then
  nginx_status="Running"
else
  nginx_status="Not detected"
fi

updated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '{\n  "system": "%s",\n  "updatedAt": "%s",\n  "details": {\n    "osVersion": "%s",\n    "architecture": "%s",\n    "uptime": "%s",\n    "diskSpace": "%s",\n    "nginx": "%s"\n  }\n}\n' \
  "$system" "$updated_at" \
  "$(json_escape "$os_version")" "$(json_escape "$architecture")" \
  "$(json_escape "$uptime_text")" "$(json_escape "$disk_space")" \
  "$(json_escape "$nginx_status")" > status.json

git add status.json
if git diff --cached --quiet; then
  exit 0
fi
git commit -m "status: ${system} heartbeat"
git push origin main
