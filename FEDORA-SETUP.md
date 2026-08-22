# Fedora setup and troubleshooting

Use this guide after you boot Fedora on the MacBook. It makes Fedora update the
public status dashboard automatically while Fedora is running.

## What this will do

- The first command sends a Fedora heartbeat to the GitHub repository.
- A background timer then sends one every minute while you are logged in.
- When Fedora is shut down, the heartbeats stop and the dashboard changes to
  offline after a few minutes.

## Normal first-time setup

Open Terminal in Fedora and run these commands **one at a time**:

```bash
git clone https://github.com/TheShulksUp/vyom-server-status.git ~/vyom-server-status
cd ~/vyom-server-status
chmod +x scripts/update-status.sh scripts/install-fedora-heartbeat.sh
```

The `cd` and `chmod` commands normally show no message when they work. That is
expected.

Set Git's author name and email before the first heartbeat. Use the email on
your GitHub account:

```bash
git config --global user.name "Your Name"
git config --global user.email "your-github-email@example.com"
```

Now send one heartbeat manually:

```bash
./scripts/update-status.sh fedora
```

It should create a `status: fedora heartbeat` commit and push it to GitHub.
Only after that succeeds, install the background timer:

```bash
./scripts/install-fedora-heartbeat.sh
systemctl --user status vyom-server-status.timer
```

Press `q` to leave the status screen. The timer continues in the background;
you may close Terminal.

## Check that it worked

Wait a minute, then open:

<https://theshulksup.github.io/vyom-server-status/>

It should show **ONLINE**, current system **Fedora Linux**, and the live Fedora
details. A short delay is normal while GitHub Pages updates.

## Common errors

## If a command says `No such file or directory`

Do not run more repair commands yet. First collect this diagnostic information:

```bash
pwd
ls -la
ls -la ~/vyom-server-status
find ~/vyom-server-status -maxdepth 2 -type f 2>&1
```

`pwd` shows your current folder. The next commands show whether the project was
cloned in the expected place and whether it has the latest scripts.

To copy the result from the Fedora Terminal, select the printed text with the
mouse and press **Ctrl+Shift+C**. This Codex task cannot be opened in Fedora's
web browser, so return to this task on macOS and paste the result with
**Command+V**. If you instead open a new ChatGPT chat on Fedora, include this
repository link and the full copied output.

### `git: command not found`

Install Git, then repeat the setup command that failed:

```bash
sudo dnf install git
```

### `fatal: destination path ... already exists`

The repository was already cloned. Do not clone it again. Use:

```bash
cd ~/vyom-server-status
git pull --ff-only
```

### `Permission denied` when running a script

Make both scripts executable again:

```bash
cd ~/vyom-server-status
chmod +x scripts/update-status.sh scripts/install-fedora-heartbeat.sh
```

### `Author identity unknown`

Git needs your name and email before it can create a heartbeat commit. Run:

```bash
git config --global user.name "Your Name"
git config --global user.email "your-github-email@example.com"
```

Then retry:

```bash
./scripts/update-status.sh fedora
```

### `Permission to TheShulksUp/vyom-server-status.git denied` or `Authentication failed`

Cloning a public repository does not require a GitHub sign-in, but pushing the
heartbeat does. The easiest setup is GitHub CLI authentication:

```bash
sudo dnf install gh
gh auth login
gh auth setup-git
```

In the sign-in questions, choose **GitHub.com**, then **HTTPS**, then the web
browser sign-in option. Finish authorizing GitHub in the browser. Confirm it
worked:

```bash
gh auth status
```

Then return to the repository and retry the heartbeat:

```bash
cd ~/vyom-server-status
./scripts/update-status.sh fedora
```

Do not enter your GitHub account password directly into Git; use the browser
sign-in above.

### `fatal: not a git repository`

You are not in the project folder. Run:

```bash
cd ~/vyom-server-status
pwd
```

The last command should print `/home/your-linux-username/vyom-server-status`.
Then retry the previous command.

### `status.json: Permission denied`

First check who owns the folder:

```bash
ls -ld ~/vyom-server-status
```

If the owner is not your Fedora username (for example, it says `root`), fix the
ownership of **only this repository**:

```bash
sudo chown -R "$USER":"$USER" ~/vyom-server-status
```

Then retry the heartbeat.

### `rejected` or `non-fast-forward` when pushing

Another heartbeat reached GitHub first. Update your clone, then retry:

```bash
cd ~/vyom-server-status
git pull --rebase origin main
./scripts/update-status.sh fedora
```

If Git reports a merge conflict, stop and copy the entire message before trying
other commands.

### The timer is not active, or the dashboard stays offline

Check the timer and the most recent service output:

```bash
systemctl --user status vyom-server-status.timer --no-pager
journalctl --user -u vyom-server-status.service -n 50 --no-pager
```

If the timer does not say `active (waiting)`, reinstall it:

```bash
cd ~/vyom-server-status
./scripts/install-fedora-heartbeat.sh
```

If the service output mentions GitHub authentication, complete the GitHub CLI
sign-in steps above, then run `./scripts/update-status.sh fedora` once manually.

## Stop the Fedora heartbeat later

To turn off the Fedora background timer:

```bash
systemctl --user disable --now vyom-server-status.timer
```

To start it again later:

```bash
systemctl --user enable --now vyom-server-status.timer
```
