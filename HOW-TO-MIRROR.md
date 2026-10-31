# How to Mirror This Repository

This guide shows how to make your own copy of this project on GitHub and keep it up to date — no special tools beyond `git` and GitHub's `gh` CLI.

Upstream sources:

| Project   | Original (upstream)                                              | How to copy      |
|-----------|------------------------------------------------------------------|------------------|
| Eglantine | https://github.com/Djihads80/Eglantine                           | GitHub **Fork**  |
| PokeDinner| https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork   | Clone + push mirror |

Both projects are licensed under **GPLv3**. You may redistribute them, but keep `LICENSE.txt` intact and credit the original authors.

---

## 1. Install the tools (one time)

### macOS

```bash
xcode-select --install   # installs git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh
```

### Windows

```powershell
winget install Git.Git
winget install GitHub.cli
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install git gh
```

---

## 2. Log in to GitHub (one time)

```bash
gh auth login -h github.com -p https -s workflow -w
gh auth setup-git
```

- Copy the one-time code it prints, open https://github.com/login/device, paste it, click **Authorize**.
- `-s workflow` is **required**: these repos contain `.github/workflows/` files, and GitHub rejects pushes of workflow files without that permission.
- `gh auth setup-git` lets plain `git push` use your GitHub login.

Optional — keep your personal email out of commits:

```bash
git config --global user.name  "YOUR_GITHUB_USERNAME"
git config --global user.email "YOUR_ID+YOUR_GITHUB_USERNAME@users.noreply.github.com"
```

(Find your noreply address at GitHub → Settings → Emails.)

---

## 3a. Repo already on GitHub → Fork it (Eglantine)

```bash
gh repo fork Djihads80/Eglantine --clone
```

Or on the website: open the repo → click **Fork** (top right).

Forks stay linked to the original, so people can see where the code came from and send changes back upstream.

## 3b. Repo hosted elsewhere → Mirror it (PokeDinner)

GitHub cannot fork from other sites, so clone and push:

```bash
git clone https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork.git PokeDinner
cd PokeDinner

gh repo create YOUR_GITHUB_USERNAME/PokeDinner --public \
  --description "Mirror of Franseven's PokeDinner (GPLv3)"

git remote add github https://github.com/YOUR_GITHUB_USERNAME/PokeDinner.git
git push github master
```

Now the folder has two remotes:

| Remote   | Points to           | Used for |
|----------|---------------------|----------|
| `origin` | original author     | `git pull` (get updates) |
| `github` | your GitHub copy    | `git push` (publish)     |

Check with `git remote -v`.

**Full mirror (every branch and tag)** instead of just `master`:

```bash
git clone --mirror https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork.git
cd PokeDinner-a-Eglantine-Fork.git
git push --mirror https://github.com/YOUR_GITHUB_USERNAME/PokeDinner.git
```

⚠️ `--mirror` overwrites everything on the destination — only use it on a repo that holds nothing but the mirror.

---

## 4. Keep your copy up to date

**Fork (Eglantine):**

```bash
gh repo sync YOUR_GITHUB_USERNAME/Eglantine
```

Or click **Sync fork** on the repo page.

**Mirror (PokeDinner):**

```bash
cd PokeDinner
git pull origin master
git push github master
```

### Automatic sync (optional)

Add `.github/workflows/sync-upstream.yml` to your mirror to pull upstream daily:

```yaml
name: Sync upstream
on:
  schedule:
    - cron: "0 6 * * *"
  workflow_dispatch:
permissions:
  contents: write
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: |
          git config user.name  "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git pull --no-edit https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork.git master
          git push origin HEAD:master
```

---

## 5. Troubleshooting

| Error | Fix |
|-------|-----|
| `refusing to allow an OAuth App to create or update workflow` | `gh auth refresh -h github.com -s workflow` |
| `Authentication failed` or asked for a password | `gh auth setup-git` (GitHub no longer accepts account passwords for git) |
| `received credentials for X, did you use the correct account` | Account was renamed — `gh auth logout`, then `gh auth login` again |
| `File ... exceeds GitHub's file size limit of 100 MB` | Use Git LFS (`git lfs install`) or remove the file from history |
| `! [rejected] master -> master (fetch first)` | Your GitHub copy has commits the local one lacks — `git pull github master`, then push again |
| `remote github already exists` | `git remote set-url github <new-url>` |

---

## No command line? Use GitHub Desktop

1. Install [GitHub Desktop](https://desktop.github.com) and sign in.
2. **File → Clone Repository → URL** → paste the upstream URL.
3. Create an empty repo on github.com.
4. **Repository → Repository Settings → Remote** → paste your new repo's URL.
5. Click **Push origin**.

For repos already on GitHub, just use the **Fork** button on the website.
