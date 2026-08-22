#!/usr/bin/env bash
# Installs the included systemd user timer for the current Fedora user.
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
unit_dir="$HOME/.config/systemd/user"

mkdir -p "$unit_dir"
cp "$project_dir/systemd/vyom-server-status.service" "$unit_dir/"
cp "$project_dir/systemd/vyom-server-status.timer" "$unit_dir/"
systemctl --user daemon-reload
systemctl --user enable --now vyom-server-status.timer
systemctl --user start vyom-server-status.service

echo "Installed. Fedora will send a heartbeat every minute while you are logged in."
echo "Check it with: systemctl --user status vyom-server-status.timer"
