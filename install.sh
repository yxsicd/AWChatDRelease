#!/usr/bin/env bash
set -euo pipefail

repository="${AWCHATD_RELEASE_REPOSITORY:-yxsicd/AWChatDRelease}"
tag="${AWCHATD_RELEASE_TAG:-}"
prefix="${1:-${AWCHATD_INSTALL_PREFIX:-$HOME/.local}}"
asset="awchatd-linux-arm64.tar.gz"

case "$(uname -s)/$(uname -m)" in
  Linux/aarch64|Linux/arm64) ;;
  *)
    echo "AWChatDRelease currently supports Linux arm64 only." >&2
    exit 2
    ;;
esac

if [[ -n "$tag" ]]; then
  base="https://github.com/${repository}/releases/download/${tag}"
else
  base="https://github.com/${repository}/releases/latest/download"
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl --fail --silent --show-error --location \
  --retry 3 --retry-delay 1 \
  "$base/$asset" -o "$work/$asset"
curl --fail --silent --show-error --location \
  --retry 3 --retry-delay 1 \
  "$base/SHA256SUMS" -o "$work/SHA256SUMS"

expected="$(awk -v asset="$asset" '$2 == asset { print $1 }' "$work/SHA256SUMS")"
if [[ ! "$expected" =~ ^[0-9a-f]{64}$ ]]; then
  echo "SHA256SUMS does not contain an exact digest for $asset." >&2
  exit 1
fi
actual="$(sha256sum "$work/$asset" | awk '{print $1}')"
if [[ "$actual" != "$expected" ]]; then
  echo "Release archive checksum mismatch." >&2
  exit 1
fi

mkdir -p "$prefix/bin" "$prefix/share/awchatd"
tar -xzf "$work/$asset" -C "$work"
install -m 0755 "$work/awchatd-release/bin/awchatd" "$prefix/bin/awchatd"
install -m 0755 "$work/awchatd-release/bin/awchatctl" "$prefix/bin/awchatctl"
cp -R "$work/awchatd-release/share/awchatd/." "$prefix/share/awchatd/"

echo "Installed AWChatD into $prefix"
echo "Provenance: $prefix/share/awchatd/RELEASE.json"
