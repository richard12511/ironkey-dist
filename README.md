# ironkey-dist

Prebuilt binaries and install scripts for the **ironkey** CLI — a local-first,
zero-knowledge password manager. (The source lives in a private repo; only the
compiled binaries and these install scripts are published here.)

## Install

**Linux, WSL, or macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/richard12511/ironkey-dist/main/install.sh | sh
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/richard12511/ironkey-dist/main/install.ps1 | iex
```

Each installer detects your OS/architecture, downloads the matching binary from the
latest [release](https://github.com/richard12511/ironkey-dist/releases), verifies its
SHA-256 against the published `checksums.txt`, and installs it to a per-user directory
on your `PATH`. Then:

```bash
ironkey init
ironkey import-csv ~/Downloads/passwords.csv
ironkey get github
```

## Supported platforms

| OS | Architectures |
|----|----|
| macOS | Apple Silicon (arm64) |
| Linux / WSL | x64, arm64 |
| Windows | x64 |

Intel macOS and other platforms: build from source (see the private source repo).

## Verifying manually

Every release includes a `checksums.txt`. To verify a downloaded binary yourself:

```bash
sha256sum -c checksums.txt   # or: shasum -a 256 -c checksums.txt
```
