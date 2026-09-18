# docker-container-shim

Rewrites common `docker` subcommands to Apple's `container` CLI syntax, so
you can keep muscle-memory `docker ...` commands without socktainer/Docker
Desktop in the loop.

This only helps the interactive CLI — anything that talks to a Docker
*socket* directly (docker-compose, Testcontainers, SDKs, docker-py, etc.)
still needs socktainer or a real docker daemon, since there's no socket
here at all.

## Install

```bash
brew install zackwag/tap/docker-container-shim
```

Then add to your `~/.zshrc` (or `~/.bashrc`):

```bash
source "$(brew --prefix)/share/docker-container-shim/docker_container_shim.sh"
```

## Command coverage

Command coverage is best-effort — `container --help` / `container <cmd>
--help` is the source of truth if something behaves unexpectedly. See
[`docker_container_shim.sh`](./docker_container_shim.sh) for the full
translation table.
