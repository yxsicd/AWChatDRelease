# AWChatDRelease

Public, source-bound release artifacts for AWChatD. The product source remains in
its owning repository; this repository publishes installable binaries, checksums,
provenance and a GitHub Actions smoke test.

## Install

Linux arm64 and amd64 are available in the current release. The installer
selects the matching archive from `uname -m`:

```sh
curl -fsSLO https://raw.githubusercontent.com/yxsicd/AWChatDRelease/main/install.sh
chmod +x install.sh
AWCHATD_RELEASE_TAG=v0.9.0-awchatd.4db4461 ./install.sh "$HOME/.local"
```

The installer downloads the release archive and `SHA256SUMS`, verifies the exact
archive digest, and installs into the requested prefix without `sudo`.

## Smoke test

```sh
./scripts/smoke-test.sh "$HOME/.local" \
  4db4461b86fd507b33990de2c778fb7e8c96ee6f
```

The smoke test starts a local deployment with unreachable dependencies and fake
credentials. It checks health, Website Skills discovery, the service descriptor,
MCP discovery of 25 tools, fixed-CRC health without OAuth, the read-only MCPGit authority
projection, and equivalent sanitized HTTP/MCP failure for the four-object model
when its isolated smoke authority is intentionally absent. It does not call any
mutation tool. It also verifies browser polling, resident execution and
authority recovery remain disabled in the isolated smoke profile.

GitHub Actions runs the same install and deployment flow on native arm64 and
amd64 runners when a release is published or `Release smoke` is started manually.

## Published contract

Each GitHub Release contains:

- `awchatd-linux-arm64.tar.gz`: `awchatd`, `awchatctl`, smoke configuration and provenance.
- `awchatd-linux-amd64.tar.gz`: the equivalent native amd64 package.
- `SHA256SUMS`: SHA-256 fence for every downloadable release asset.
- A release description identifying the exact private-source revision and tested platform.

Public artifacts contain no operator credentials or production bindings.
