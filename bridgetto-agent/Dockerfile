# Plain Alpine on purpose: the Supervisor default base (s6-overlay) cannot
# run under the Docker init that `init: true` gives this app.
FROM docker.io/library/alpine:3.20

# Only a bootstrap lives in this image: no agent binary, no agent source.
# The agent is downloaded from the user's own control plane on first start,
# verified (sha256 pin + Ed25519 release signature) and kept in /data, so it
# survives restarts and updates itself without a new add-on version.
RUN apk add --no-cache ca-certificates curl jq util-linux-misc \
 && mkdir -p /usr/local/lib /etc /var/lib \
 && ln -s /data/lib /usr/local/lib/bridgetto \
 && ln -s /data/etc /etc/bridgetto \
 && ln -s /data/state /var/lib/bridgetto

COPY run.sh /run.sh
RUN chmod 0755 /run.sh

ENTRYPOINT []
CMD ["/run.sh"]
