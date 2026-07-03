#!/bin/sh
# install.sh — install the ironkey CLI (POSIX; WSL/Linux/macOS)
set -eu

BASE_URL="${IRONKEY_BASE_URL:-https://github.com/richard12511/ironkey-dist/releases/latest/download}"
INSTALL_DIR="${IRONKEY_INSTALL_DIR:-$HOME/.local/bin}"

os=$(uname -s); arch=$(uname -m)
case "$os" in Darwin) os=darwin ;; Linux) os=linux ;; *) echo "unsupported OS: $os" >&2; exit 1 ;; esac
case "$arch" in x86_64|amd64) arch=x64 ;; aarch64|arm64) arch=arm64 ;; *) echo "unsupported arch: $arch" >&2; exit 1 ;; esac

asset="ironkey-${os}-${arch}"
case "$asset" in
  ironkey-darwin-arm64|ironkey-linux-x64|ironkey-linux-arm64) : ;;
  *) echo "No prebuilt binary for ${os}-${arch}. Build from source: https://github.com/richard12511/iron_key#building-from-source" >&2; exit 1 ;;
esac
if [ -n "${IRONKEY_DETECT_ONLY:-}" ]; then echo "$asset"; exit 0; fi
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $asset …" >&2
curl -fsSL "$BASE_URL/$asset" -o "$tmp/ironkey"
curl -fsSL "$BASE_URL/checksums.txt" -o "$tmp/checksums.txt"

# Verify only our asset's line.
want=$(grep " ${asset}\$" "$tmp/checksums.txt" | awk '{print $1}')
if [ -z "$want" ]; then echo "no checksum for $asset" >&2; exit 1; fi
if command -v sha256sum >/dev/null 2>&1; then
  got=$(sha256sum "$tmp/ironkey" | awk '{print $1}')
else
  got=$(shasum -a 256 "$tmp/ironkey" | awk '{print $1}')
fi
if [ "$want" != "$got" ]; then echo "checksum mismatch for $asset" >&2; exit 1; fi

mkdir -p "$INSTALL_DIR"
chmod +x "$tmp/ironkey"
mv "$tmp/ironkey" "$INSTALL_DIR/ironkey"
echo "Installed ironkey to $INSTALL_DIR/ironkey" >&2
case ":$PATH:" in *":$INSTALL_DIR:"*) : ;; *) echo "Note: add $INSTALL_DIR to your PATH." >&2 ;; esac
