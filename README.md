# AWChatDRelease

Public, source-bound release artifacts for AWChatD. The product source remains in
its owning repository; this repository publishes installable binaries, checksums,
provenance and a GitHub Actions smoke test.

## Install

Linux arm64 is available in the current release:

```sh
curl -fsSLO https://raw.githubusercontent.com/yxsicd/AWChatDRelease/main/install.sh
chmod +x install.sh
AWCHATD_RELEASE_TAG=v0.2.0-awchatd.1f5ce1c ./install.sh "$HOME/.local"
```

The installer downloads the release archive and `SHA256SUMS`, verifies the exact
archive digest, and installs into the requested prefix without `sudo`.

## Smoke test

```sh
./scripts/smoke-test.sh "$HOME/.local" \
  1f5ce1cc42b31eedbd82f26086e416aa55f357f8
```

The smoke test starts a local deployment with unreachable dependencies and fake
credentials. It checks health, Website Skills discovery, the service descriptor,
authenticated MCP discovery of 16 tools, and the read-only MCPGit authority
projection. It does not call any mutation tool.

GitHub Actions runs the same install and deployment flow when a release is
published or when `Release smoke` is started manually with a release tag.

## Published contract

Each GitHub Release contains:

- `awchatd-linux-arm64.tar.gz`: `awchatd`, `awchatctl`, smoke configuration and provenance.
- `SHA256SUMS`: SHA-256 fence for every downloadable release asset.
- A release description identifying the exact private-source revision and tested platform.

Public artifacts contain no operator credentials or production bindings.
