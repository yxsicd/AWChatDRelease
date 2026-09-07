# AWChatDRelease maintainer entry

This public repository contains immutable AWChatD release assets and the scripts
that install and smoke-test them. It does not contain AWChatD product source,
credentials, production configuration, or business data.

- Bind every release manifest to an exact 40-character AWChatD source revision.
- Verify SHA-256 before installing an asset.
- Smoke tests use unreachable dependencies, fake credentials and no business tasks.
- Never call mutation tools in public CI.
- Keep installer changes backward-compatible with existing release assets.

