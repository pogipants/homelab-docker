#!/usr/bin/env bash
# Start, stop, and update the homelab Compose stacks.
# Each stack stays its own Compose project so existing volumes keep their names.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# Add your favorite stacks here, remove your unfavorite stacks here too!
STACKS=(immich jellyfin nginx samba autopulse wordpress pihole wireguard)
# Add any networks to be precreated here.
NETWORKS=(immich_net jellyfin_net wordpress_net pihole_net)

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [stack]

Commands:
  up [stack]       Start all stacks (default), or one stack
  down [stack]     Stop all stacks, or one stack
  pull [stack]     Pull newer images
  restart [stack]  Restart
  ps               Show containers for every stack
  logs [stack]     Tail logs (follow)

Stacks: ${STACKS[*]}
EOF
}

is_stack() {
  local name="$1"
  local stack
  for stack in "${STACKS[@]}"; do
    if [[ "$stack" == "$name" ]]; then
      return 0
    fi
  done
  return 1
}

require_stack() {
  local name="$1"
  if ! is_stack "$name"; then
    echo "Unknown stack: $name" >&2
    echo "Known stacks: ${STACKS[*]}" >&2
    exit 1
  fi
}

ensure_networks() {
  local net
  for net in "${NETWORKS[@]}"; do
    if ! docker network inspect "$net" >/dev/null 2>&1; then
      echo "Creating docker network: $net"
      docker network create "$net"
    fi
  done
}

compose_stack() {
  local stack="$1"
  shift
  docker compose \
    -f "$ROOT/$stack/docker-compose.yml" \
    --project-directory "$ROOT/$stack" \
    "$@"
}

stacks_to_run() {
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    printf '%s\n' "${STACKS[@]}"
    return
  fi
  require_stack "$target"
  printf '%s\n' "$target"
}

cmd="${1:-}"
target="${2:-}"

case "$cmd" in
  up)
    ensure_networks
    while IFS= read -r stack; do
      echo "==> up $stack"
      compose_stack "$stack" up -d
    done < <(stacks_to_run "$target")
    ;;
  down)
    while IFS= read -r stack; do
      echo "==> down $stack"
      compose_stack "$stack" down
    done < <(stacks_to_run "$target")
    ;;
  pull)
    while IFS= read -r stack; do
      echo "==> pull $stack"
      compose_stack "$stack" pull
    done < <(stacks_to_run "$target")
    ;;
  restart)
    while IFS= read -r stack; do
      echo "==> restart $stack"
      compose_stack "$stack" restart
    done < <(stacks_to_run "$target")
    ;;
  ps)
    while IFS= read -r stack; do
      echo "==> $stack"
      compose_stack "$stack" ps
    done < <(stacks_to_run "$target")
    ;;
  logs)
    if [[ -z "$target" ]]; then
      echo "logs requires a stack name" >&2
      exit 1
    fi
    require_stack "$target"
    compose_stack "$target" logs -f --tail=100
    ;;
  -h|--help|help)
    usage
    ;;
  "")
    usage
    exit 1
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
