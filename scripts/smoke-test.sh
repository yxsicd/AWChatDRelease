#!/usr/bin/env bash
set -euo pipefail

prefix="${1:?usage: smoke-test.sh INSTALL_PREFIX EXPECTED_SOURCE_REVISION}"
expected_revision="${2:?usage: smoke-test.sh INSTALL_PREFIX EXPECTED_SOURCE_REVISION}"
binary="$prefix/bin/awchatd"
control="$prefix/bin/awchatctl"
config="$prefix/share/awchatd/config/smoke.yaml"
token="awchatd-release-smoke-only"
runtime="$(mktemp -d)"
pid=""

cleanup() {
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    wait "$pid" || true
  fi
  rm -rf "$runtime"
}
trap cleanup EXIT

[[ "$expected_revision" =~ ^[0-9a-f]{40}$ ]]
test -x "$binary"
test -x "$control"
test -f "$config"

AWMCP_VERIFY=smoke-only \
AGENTWEB_RGW_TOKEN=smoke-only \
YXSGIT_SECOND_BRAIN_BASIC_VERIFY=smoke-only \
AWCHATD_OPERATOR_TOKEN="$token" \
AWCHATD_CHAT_PROTECTION_STATE_PATH="$runtime/chat-protection.json" \
  "$binary" --config "$config" serve >"$runtime/service.log" 2>&1 &
pid=$!

ready=false
for _ in $(seq 1 30); do
  if curl --fail --silent --show-error --max-time 2 \
    http://127.0.0.1:18790/health >"$runtime/health.json"; then
    ready=true
    break
  fi
  sleep 1
done
if [[ "$ready" != true ]]; then
  cat "$runtime/service.log" >&2
  exit 1
fi

curl --fail --silent --show-error --max-time 5 \
  http://127.0.0.1:18790/SKILL.md >"$runtime/SKILL.md"
curl --fail --silent --show-error --max-time 5 \
  http://127.0.0.1:18790/service.json >"$runtime/service.json"
curl --fail --silent --show-error --max-time 5 \
  -H "Authorization: Bearer $token" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H 'MCP-Protocol-Version: 2025-11-25' \
  --data-raw '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"awchatd-release-smoke","version":"1"}}}' \
  http://127.0.0.1:18790/mcp >"$runtime/initialize.json"
curl --fail --silent --show-error --max-time 5 \
  -H "Authorization: Bearer $token" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -H 'MCP-Protocol-Version: 2025-11-25' \
  --data-raw '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
  http://127.0.0.1:18790/mcp >"$runtime/tools.json"
curl --fail --silent --show-error --max-time 5 \
  -H "Authorization: Bearer $token" \
  http://127.0.0.1:18790/v1/authority >"$runtime/authority.json"

python3 - "$runtime" "$expected_revision" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
expected = sys.argv[2]
health = json.loads((root / "health.json").read_text())
descriptor = json.loads((root / "service.json").read_text())
skill = (root / "SKILL.md").read_text()
initialize = json.loads((root / "initialize.json").read_text())
tools = json.loads((root / "tools.json").read_text())["result"]["tools"]
authority = json.loads((root / "authority.json").read_text())

assert health["buildRevision"] == expected
assert descriptor["service"]["buildRevision"] == expected
assert descriptor["capabilityCoverage"] == "complete-public-http-application-surface"
assert len(descriptor["capabilities"]) == 16
assert len(tools) == 16
assert len({tool["name"] for tool in tools}) == 16
assert sum(tool["annotations"]["readOnlyHint"] for tool in tools) == 8
assert authority["schema"] == "second-brain.authority-status.v1"
assert authority["phase"] == "phase_a_read_only"
assert authority["authorityMigrationEnabled"] is False
assert authority["runtimeBindingMutationsEnabled"] is False
assert authority["messagingMutationsEnabled"] is False
assert 'service-manifest: "./service.json"' in skill
assert initialize["result"]["protocolVersion"] == "2025-11-25"
print(json.dumps({
    "sourceRevision": expected,
    "health": "ok",
    "capabilities": 16,
    "mcpTools": 16,
    "readOnlyTools": 8,
    "authorityPhase": authority["phase"],
    "mutationToolsInvoked": False,
}))
PY
