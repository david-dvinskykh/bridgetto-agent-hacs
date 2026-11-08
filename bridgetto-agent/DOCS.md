# Bridgetto Agent

## Before installing

1. In the Bridgetto console: **Servers → Add server**, copy the control plane address, the one-time
   enrollment token and (if shown) `--hub-ca-sha256`.
2. The agent manages Docker on this host, so the add-on needs Docker API access: after installing, turn
   **Protection mode** off on the add-on page. Without it the agent connects but cannot see containers.

## Configuration

| Option | Required | Meaning |
|---|---|---|
| `control_plane_url` | yes | `https://…` address of your control plane; the agent is downloaded from it |
| `enroll_token` | first start | one-time token; not stored, can be cleared after the first start |
| `hub_url` | no | overrides the hub address the control plane serves (`wss://…`) |
| `hub_ca_sha256` | no | pin of the hub certificate from the install command |
| `org_id` | no | the agent refuses commands for other organizations |
| `log_level` | no | `debug`, `info` (default), `warn`, `error` |

## Where things live

Everything is in the add-on's `/data` (included in Home Assistant backups):
`/data/lib` (agent binary, supervisor, watchdog), `/data/etc` (hub URL, pins, release key — no secrets
beyond the agent's own identity), `/data/state` (identity, local database).

To enroll the host again (another organization, revoked identity): uninstall the add-on (this clears
`/data`), install it again and enter a new token.

## Updates

The agent updates itself from the control plane, without a new add-on version and without restarting
the add-on; a failed version is rolled back automatically. Add-on updates only change this bootstrap.
