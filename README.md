# Bridgetto Agent — Home Assistant add-on repository

Installs the Bridgetto Agent on a Home Assistant OS / Supervised host as an add-on.

[![Add repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fdavid-dvinskykh%2Fbridgetto-agent-hacs)

Or: **Settings → Add-ons → Add-on store → ⋮ → Repositories**, add
`https://github.com/david-dvinskykh/bridgetto-agent-hacs`, then install **Bridgetto Agent**.

> HACS installs integrations and dashboard cards only; Home Assistant add-ons (containers) are installed
> from the add-on store by repository URL, as above.

## What is in this repository — and what is not

Only a bootstrap: `config.yaml`, a `Dockerfile` on plain Alpine and `run.sh`. The agent binary and its
source are **not** here and not in the image. On the first start the add-on downloads the agent from
**your** control plane (`<control plane>/agent/v1/install.sh`), checks its sha256 against the pin in that
script and its Ed25519 release signature, installs it into `/data` and enrolls it with a one-time token.

## Updates without updating or restarting the add-on

The binary lives in the add-on's persistent `/data`. When the control plane rolls out a new agent version,
the agent downloads and verifies it, swaps it in `/data` and exits; the supervisor loop inside the
container (`supervise.sh`) starts the new binary within 5 s. If the new version fails to start three
times, the watchdog restores the previous one. The add-on version stays the same and the container keeps
running. After an add-on restart or update the last installed agent starts again — nothing is downloaded
anew.

See [bridgetto-agent/DOCS.md](bridgetto-agent/DOCS.md) for configuration.
