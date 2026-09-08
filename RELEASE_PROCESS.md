# Release process

AWChatDRelease is the public distribution boundary. A release maintainer builds
from one exact, clean AWChatD source revision in the private source repository and
copies only the resulting binaries, smoke configuration and provenance into the
release archive.

1. Verify the private source revision and its full test gates.
2. Build the declared target architecture from that exact revision.
3. Run the binary with unreachable dependencies and fake credentials. Verify
   the four-object model has equivalent sanitized HTTP and MCP failure semantics.
4. Create `awchatd-linux-arm64.tar.gz` with this layout:

   ```text
   awchatd-release/
     bin/awchatd
     bin/awchatctl
     share/awchatd/RELEASE.json
     share/awchatd/config/smoke.yaml
   ```

5. Generate `SHA256SUMS` after the archive is final.
6. Commit the matching `releases/<tag>/manifest.json` before publishing the tag.
7. Create the GitHub Release with both assets. The `release.published` workflow
   must install the public asset and pass the isolated deployment smoke test.

Do not publish source checkouts, Cargo credentials, operator tokens, production
configuration, runtime volumes, task rows or browser bindings. A successful smoke
test proves installation and protocol discovery for the packaged binary; it does
not prove external dependencies or authorize a production rollout.
