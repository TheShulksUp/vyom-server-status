# Vyom's Server Status

A free status site for one MacBook Air M2 that can boot either macOS or Fedora.

## How it works

GitHub Pages hosts `index.html`. The operating system currently booted runs
`scripts/update-status.sh` once a minute. That script records a timestamp in
`status.json` and pushes it to GitHub. The dashboard calls a system **online**
only when its latest heartbeat is less than three minutes old. Therefore, when
the machine is off (or neither OS is running the heartbeat), the site naturally
changes to **offline** without needing a paid monitoring service.

While a heartbeat is fresh, the dashboard also shows safe system details:
operating-system version, CPU architecture, uptime, disk-space summary, and
whether Nginx is detected. It intentionally does not publish network addresses,
usernames, or file paths.

## First-time setup on macOS

```bash
cd ~/vyom-server-status
chmod +x scripts/update-status.sh
git add .
git commit -m "Add status site and heartbeat"
git push origin main
./scripts/update-status.sh macos
```

Then enable GitHub Pages in the repository: **Settings → Pages → Deploy from a
branch → main → /(root) → Save**. The published dashboard will be at
`https://theshulksup.github.io/vyom-server-status/`.

To run the macOS heartbeat automatically in the background, create this
LaunchAgent once:

```bash
mkdir -p ~/Library/LaunchAgents ~/Library/Logs
cp launchd/com.vyom.server-status.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.vyom.server-status.plist
```

It runs at login and then once a minute. Check it with
`launchctl print gui/$(id -u)/com.vyom.server-status`.

## Fedora setup after Fedora boots

Clone this same repository in Fedora, authenticate Git pushes, then run:

```bash
cd ~/vyom-server-status
chmod +x scripts/update-status.sh scripts/install-fedora-heartbeat.sh
./scripts/update-status.sh fedora
./scripts/install-fedora-heartbeat.sh
```

The final command installs a Fedora user timer. It runs in the background at
login and then once a minute. Check it with:

```bash
systemctl --user status vyom-server-status.timer
```

The Fedora page is `fedora.html`; the live status dashboard is always
`index.html`.
