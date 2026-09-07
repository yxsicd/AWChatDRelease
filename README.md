# AWChatDRelease

Public, source-bound release artifacts for AWChatD. The product source remains in
its owning repository; this repository publishes installable binaries, checksums,
provenance and a GitHub Actions smoke test.

## Install

Linux arm64 is available in the first release:

```sh
curl -fsSLO https://raw.githubusercontent.com/yxsicd/AWChatDRelease/main/install.sh
chmod +x install.sh
AWCHATD_RELEASE_TAG=v0.1.0-awchatd.09e6638 ./install.sh "$HOME/.local"
```

The installer downloads the release archive and `SHA256SUMS`, verifies the exact
archive digest, and installs into the requested prefix without `sudo`.

## Smoke test

```sh
./scripts/smoke-test.sh "$HOME/.local" \
  09e663848395c09ea18b2938a2ad231b0bb44e29
```

The smoke test starts a local deployment with unreachable dependencies and fake
credentials. It checks health, Website Skills discovery, the service descriptor,
and authenticated MCP discovery of 15 tools. It does not call any mutation tool.

GitHub Actions runs the same install and deployment flow when a release is
published or when `Release smoke` is started manually with a release tag.

## Published contract

Each GitHub Release contains:

- `awchatd-linux-arm64.tar.gz`: `awchatd`, `awchatctl`, smoke configuration and provenance.
- `SHA256SUMS`: SHA-256 fence for every downloadable release asset.
- A release description identifying the exact private-source revision and tested platform.

Public artifacts contain no operator credentials or production bindings.
