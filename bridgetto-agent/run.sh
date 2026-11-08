#!/bin/sh
# Bridgetto Agent add-on entrypoint.
#
# First start: download the control plane's install.sh (it pins the sha256
# of the agent binaries it serves), let it verify and install the agent as
# instance "homeassistant" and enroll it with the one-time token. Every path
# the installer writes is a symlink into /data, so the binary, its settings
# and its identity persist across add-on restarts and add-on updates.
#
# Every start: run the agent under supervise.sh. After a self-update the
# agent exits, the supervisor runs the rollback watchdog and starts the new
# binary from /data: the add-on itself is neither updated nor restarted.
set -eu

INSTANCE=homeassistant
OPTIONS=/data/options.json
BIN=/usr/local/lib/bridgetto/agents/$INSTANCE/bridgetto-agent
IDENTITY=/var/lib/bridgetto/agents/$INSTANCE/identity.json
SUPERVISE=/usr/local/lib/bridgetto/supervise.sh

log() { echo "[bridgetto-agent] $*" >&2; }
die() { log "$*"; exit 1; }
opt() { [ -f "$OPTIONS" ] && jq -r --arg k "$1" '.[$k] // empty' "$OPTIONS" || true; }

mkdir -p /data/lib /data/etc /data/state
chmod 0700 /data/state

if [ ! -x "$BIN" ] || [ ! -f "$IDENTITY" ] || [ ! -f "$SUPERVISE" ]; then
	CP="$(opt control_plane_url)"
	TOKEN="$(opt enroll_token)"
	[ -n "$CP" ] || die "set control_plane_url in the add-on configuration"
	[ -n "$TOKEN" ] || die "set enroll_token (from the control plane: Servers -> Add server) in the add-on configuration"
	case "$CP" in https://*) ;; *) die "control_plane_url must start with https://" ;; esac
	CP="${CP%/}"

	set -- --instance "$INSTANCE" --token "$TOKEN" --service none
	HUB="$(opt hub_url)";        [ -z "$HUB" ] || set -- "$@" --hub-url "$HUB"
	PIN="$(opt hub_ca_sha256)";  [ -z "$PIN" ] || set -- "$@" --hub-ca-sha256 "$PIN"
	ORG="$(opt org_id)";         [ -z "$ORG" ] || set -- "$@" --org "$ORG"
	[ ! -f "$IDENTITY" ] || set -- "$@" --force

	TMP="$(mktemp -d)"
	trap 'rm -rf "$TMP"' EXIT
	log "installing the agent from $CP"
	curl -fsSL --tlsv1.2 --retry 3 -o "$TMP/install.sh" "$CP/agent/v1/install.sh" \
		|| die "cannot download $CP/agent/v1/install.sh"
	sh "$TMP/install.sh" "$@" || die "installation failed (see the lines above)"
	rm -rf "$TMP"
	trap - EXIT
	log "installed and enrolled; the enrollment token is no longer needed and can be removed from the configuration"
fi

BRIDGETTO_LOG_LEVEL="$(opt log_level)"
export BRIDGETTO_LOG_LEVEL="${BRIDGETTO_LOG_LEVEL:-info}"
log "starting agent $("$BIN" version 2>/dev/null || echo '?')"
exec /bin/sh "$SUPERVISE" "$INSTANCE"
