# Changelog

## 1.0.1

- Fix start-up («s6-overlay-suexec: fatal: can only run as pid 1»): the image is built on plain Alpine set in the
  Dockerfile; the deprecated `build.yaml` is removed.

## 1.0.0

- First release: installs the Bridgetto Agent from your control plane, keeps it in `/data` and lets it update
  itself without a new add-on version or an add-on restart.
