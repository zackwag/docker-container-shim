# shellcheck shell=bash
# docker → container shim
#
# Rewrites common `docker` subcommands to Apple's `container` CLI syntax so
# you can keep muscle-memory `docker ...` commands without socktainer/Docker
# Desktop in the loop. This only helps the interactive CLI — anything that
# talks to a Docker *socket* directly (docker-compose, Testcontainers, SDKs,
# docker-py, etc.) still needs socktainer or a real docker daemon, since
# there's no socket here at all.
#
# Install: save this file, then add to ~/.zshrc:
#   source /path/to/docker-container-shim.sh
#
# Command coverage is best-effort — `container --help` / `container <cmd>
# --help` is the source of truth if something behaves unexpectedly.

docker() {
  if ! command -v container >/dev/null 2>&1; then
    echo "docker (shim): 'container' CLI not found. Install Apple's container tool first." >&2
    return 127
  fi

  local cmd="$1"
  [ $# -gt 0 ] && shift

  case "$cmd" in
    # container listing
    ps)
      # translate -a/--all, drop unsupported docker-only flags as they come up
      local args=()
      for a in "$@"; do
        case "$a" in
          -a|--all) args+=(--all) ;;
          *) args+=("$a") ;;
        esac
      done
      container list "${args[@]}"
      ;;

    # image management
    images)
      container image list "$@"
      ;;
    pull)
      container image pull "$@"
      ;;
    push)
      container image push "$@"
      ;;
    tag)
      container image tag "$@"
      ;;
    rmi)
      container image delete "$@"
      ;;
    save)
      container image save "$@"
      ;;
    load)
      container image load "$@"
      ;;

    # registry auth
    login)
      container registry login "$@"
      ;;
    logout)
      container registry logout "$@"
      ;;

    # info / version
    info)
      container system status "$@"
      ;;
    version)
      container system version "$@"
      ;;

    # commands that already share a name with `container` and pass straight
    # through: run, build, create, start, stop, kill, rm, exec, logs,
    # inspect, stats, cp, prune, network, volume, system
    run|build|create|start|stop|kill|rm|exec|logs|inspect|stats|cp|prune|network|volume|system)
      container "$cmd" "$@"
      ;;

    # compose (Apple's `container` has no built-in compose support —
    # delegate to the third-party container-compose tool if it's installed)
    compose)
      if command -v container-compose >/dev/null 2>&1; then
        container-compose "$@"
      else
        echo "docker (shim): 'container-compose' not found. Install it with: brew install container-compose" >&2
        return 127
      fi
      ;;

    *)
      echo "docker (shim): no translation for '$cmd', passing through to 'container $cmd' as-is." >&2
      container "$cmd" "$@"
      ;;
  esac
}
