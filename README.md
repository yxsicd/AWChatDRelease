# AWChatDRelease

Public, source-bound release artifacts for AWChatD. The product source remains in
its owning repository; this repository publishes installable binaries, checksums,
provenance and a GitHub Actions smoke test.

## Install

Linux arm64 is available in the current release:

```sh
curl -fsSLO https://raw.githubusercontent.com/yxsicd/AWChatDRelease/main/install.sh
chmod +x install.sh
AWCHATD_RELEASE_TAG=v0.8.0-awchatd.94d9c34 ./install.sh "$HOME/.local"
```

The installer downloads the release archive and `SHA256SUMS`, verifies the exact
archive digest, and installs into the requested prefix without `sudo`.

## Smoke test

```sh
./scripts/smoke-test.sh "$HOME/.local" \
  94d9c341c676673c46176ffa01b40a02a259516d
```

The smoke test starts a local deployment with unreachable dependencies and fake
credentials. It checks health, Website Skills discovery, the service descriptor,
MCP discovery of 25 tools, fixed-CRC health without OAuth, the read-only MCPGit authority
projection, and equivalent sanitized HTTP/MCP failure for the four-object model
when its isolated smoke authority is intentionally absent. It does not call any
mutation tool. It also verifies browser polling, resident execution and
authority recovery remain disabled in the isolated smoke profile.

GitHub Actions runs the same install and deployment flow when a release is
published or when `Release smoke` is started manually with a release tag.

## Published contract

Each GitHub Release contains:

- `awchatd-linux-arm64.tar.gz`: `awchatd`, `awchatctl`, smoke configuration and provenance.
- `SHA256SUMS`: SHA-256 fence for every downloadable release asset.
- A release description identifying the exact private-source revision and tested platform.

Public artifacts contain no operator credentials or production bindings.
