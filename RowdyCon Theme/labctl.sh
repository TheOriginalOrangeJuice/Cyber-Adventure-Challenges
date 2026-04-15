#!/usr/bin/env bash

set -euo pipefail

THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
GENERATED_DIR="${THEME_DIR}/.generated"
THEME_NAME="$(basename -- "${THEME_DIR}")"

find_switchboard_dir() {
  if [[ -n "${SWITCHBOARD_DIR:-}" ]]; then
    [[ -d "${SWITCHBOARD_DIR}" ]] || return 1
    printf '%s\n' "$(cd -- "${SWITCHBOARD_DIR}" && pwd -P)"
    return 0
  fi

  if [[ -d "${THEME_DIR}/../Docker-TCP-Switchboard" ]]; then
    printf '%s\n' "$(cd -- "${THEME_DIR}/../Docker-TCP-Switchboard" && pwd -P)"
    return 0
  fi

  if [[ -d "${THEME_DIR}/Docker-TCP-Switchboard" ]]; then
    printf '%s\n' "$(cd -- "${THEME_DIR}/Docker-TCP-Switchboard" && pwd -P)"
    return 0
  fi

  return 1
}

SWITCHBOARD_DIR="$(find_switchboard_dir || true)"
SWITCHBOARD_COMPOSE_FILE="${SWITCHBOARD_DIR}/compose.switchboard.yml"
SWITCHBOARD_PROJECT="cyber-adventure-switchboard"
SYSTEMD_TEMPLATE="${SWITCHBOARD_DIR}/docker-tcp-switchboard.service.template"
SUPPORT_COMPOSE_FILE="${THEME_DIR}/Hack/Box 1/docker-compose.yml"

readonly PROFILES=(
  crypto
  linux_box1_breadcrumbs
  linux_box2_haystack
  linux_box3_locked_pipeline
  windows_box1_ghosts
  windows_box2_restricted_protocol
  windows_box3_persistence
  hack_box1_network_recon
  hack_box2_cracking_suite
  hack_box3_web_enum
)

log() {
  printf '[labctl:%s] %s\n' "${THEME_NAME}" "$*"
}

die() {
  printf '[labctl:%s] Error: %s\n' "${THEME_NAME}" "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  ./labctl.sh build
  ./labctl.sh up
  ./labctl.sh down
  ./labctl.sh status
  ./labctl.sh generate-config
  ./labctl.sh generate-service

Environment overrides:
  SWITCHBOARD_DIR           Path to Docker-TCP-Switchboard if it is not a sibling directory
  SWITCHBOARD_BIND_ADDRESS  Interface for switchboard listeners (default: all interfaces)
  SWITCHBOARD_PORT_BASE     First public challenge port (default: 40000)
  SWITCHBOARD_LOG_LEVEL     Switchboard log level (default: INFO)
EOF
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

require_prereqs() {
  require_command docker
  require_command bash
  [[ -n "${SWITCHBOARD_DIR}" ]] || die "Could not find Docker-TCP-Switchboard. Put it next to this theme folder or set SWITCHBOARD_DIR."
  [[ -f "${SWITCHBOARD_COMPOSE_FILE}" ]] || die "Switchboard compose file not found: ${SWITCHBOARD_COMPOSE_FILE}"
  [[ -f "${SYSTEMD_TEMPLATE}" ]] || die "Systemd template not found: ${SYSTEMD_TEMPLATE}"
  docker compose version >/dev/null 2>&1 || die "Docker Compose plugin is required."
  [[ "$(uname -s)" == "Linux" ]] || die "The switchboard container uses host networking and currently requires a Linux host."
}

detect_theme() {
  if [[ -d "${THEME_DIR}/Windows/box3_persistence/IPN_Summit_Data" ]]; then
    THEME_SLUG="ipn"
    SUPPORT_PROJECT="cyber-adventure-ipn-support"
    HACK_BOX1_NETWORK="hack_ipn1_net"
    HACK_BOX3_NETWORK="hack_ipn3_net"
    WINDOWS_EVIDENCE_HOST_DIR="${THEME_DIR}/Windows/box3_persistence/IPN_Summit_Data"
    WINDOWS_EVIDENCE_CONTAINER_DIR="/mnt/ipn_summit_data"
    return 0
  fi

  if [[ -d "${THEME_DIR}/Windows/box3_persistence/RCC_Con_Data" ]]; then
    THEME_SLUG="rowdycon"
    SUPPORT_PROJECT="cyber-adventure-rowdycon-support"
    HACK_BOX1_NETWORK="hack_rcc1_net"
    HACK_BOX3_NETWORK="hack_rcc3_net"
    WINDOWS_EVIDENCE_HOST_DIR="${THEME_DIR}/Windows/box3_persistence/RCC_Con_Data"
    WINDOWS_EVIDENCE_CONTAINER_DIR="/mnt/rcc_con_data"
    return 0
  fi

  die "Could not determine which theme this folder contains."
}

image_name() {
  local profile="$1"
  case "${profile}" in
    crypto) printf 'cyber-adventure-%s-crypto:latest\n' "${THEME_SLUG}" ;;
    linux_box1_breadcrumbs) printf 'cyber-adventure-%s-linux1:latest\n' "${THEME_SLUG}" ;;
    linux_box2_haystack) printf 'cyber-adventure-%s-linux2:latest\n' "${THEME_SLUG}" ;;
    linux_box3_locked_pipeline) printf 'cyber-adventure-%s-linux3:latest\n' "${THEME_SLUG}" ;;
    windows_box1_ghosts) printf 'cyber-adventure-%s-win1:latest\n' "${THEME_SLUG}" ;;
    windows_box2_restricted_protocol) printf 'cyber-adventure-%s-win2:latest\n' "${THEME_SLUG}" ;;
    windows_box3_persistence) printf 'cyber-adventure-%s-win3:latest\n' "${THEME_SLUG}" ;;
    hack_box1_network_recon) printf 'cyber-adventure-%s-hack1:latest\n' "${THEME_SLUG}" ;;
    hack_box2_cracking_suite) printf 'cyber-adventure-%s-hack2:latest\n' "${THEME_SLUG}" ;;
    hack_box3_web_enum) printf 'cyber-adventure-%s-hack3:latest\n' "${THEME_SLUG}" ;;
    *)
      die "Unknown profile '${profile}'."
      ;;
  esac
}

context_dir() {
  local profile="$1"
  case "${profile}" in
    crypto) printf '%s/Crypto\n' "${THEME_DIR}" ;;
    linux_box1_breadcrumbs) printf '%s/Linux/box1_breadcrumbs\n' "${THEME_DIR}" ;;
    linux_box2_haystack) printf '%s/Linux/box2_haystack\n' "${THEME_DIR}" ;;
    linux_box3_locked_pipeline) printf '%s/Linux/box3_locked_pipeline\n' "${THEME_DIR}" ;;
    windows_box1_ghosts) printf '%s/Windows/box1_ghosts\n' "${THEME_DIR}" ;;
    windows_box2_restricted_protocol) printf '%s/Windows/box2_restricted_protocol\n' "${THEME_DIR}" ;;
    windows_box3_persistence) printf '%s/Windows/box3_persistence\n' "${THEME_DIR}" ;;
    hack_box1_network_recon) printf '%s/Hack/Box 1\n' "${THEME_DIR}" ;;
    hack_box2_cracking_suite) printf '%s/Hack/Box2\n' "${THEME_DIR}" ;;
    hack_box3_web_enum) printf '%s/Hack/Box3\n' "${THEME_DIR}" ;;
    *)
      die "Unknown profile '${profile}'."
      ;;
  esac
}

ensure_generated_dirs() {
  mkdir -p \
    "${GENERATED_DIR}/state" \
    "${GENERATED_DIR}/switchboard" \
    "${GENERATED_DIR}/systemd"
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "${value}"
}

switchboard_config_path() {
  printf '%s/switchboard/current.conf\n' "${GENERATED_DIR}"
}

compose_down_quiet() {
  local config_path="$1"

  ensure_generated_dirs
  [[ -f "${config_path}" ]] || : > "${config_path}"

  SWITCHBOARD_CONFIG_PATH="${config_path}" \
  SWITCHBOARD_STATE_DIR="${GENERATED_DIR}/state" \
  docker compose -f "${SWITCHBOARD_COMPOSE_FILE}" -p "${SWITCHBOARD_PROJECT}" down --remove-orphans >/dev/null 2>&1 || true
}

generate_switchboard_config() {
  ensure_generated_dirs
  detect_theme

  local config_path
  config_path="$(switchboard_config_path)"
  local log_level="${SWITCHBOARD_LOG_LEVEL:-INFO}"
  local port_base="${SWITCHBOARD_PORT_BASE:-40000}"
  local evidence_json

  evidence_json="{\"$(json_escape "${WINDOWS_EVIDENCE_HOST_DIR}")\": {\"bind\": \"$(json_escape "${WINDOWS_EVIDENCE_CONTAINER_DIR}")\", \"mode\": \"ro\"}}"

  cat > "${config_path}" <<EOF
[global]
logfile = /state/docker-tcp-switchboard.log
loglevel = ${log_level}

[profile:crypto]
innerport = 22
outerport = $((port_base + 0))
container = $(image_name crypto)
limit = 0
reuse = false

[profile:linux_box1_breadcrumbs]
innerport = 22
outerport = $((port_base + 1))
container = $(image_name linux_box1_breadcrumbs)
limit = 0
reuse = false

[profile:linux_box2_haystack]
innerport = 22
outerport = $((port_base + 2))
container = $(image_name linux_box2_haystack)
limit = 0
reuse = false

[profile:linux_box3_locked_pipeline]
innerport = 22
outerport = $((port_base + 3))
container = $(image_name linux_box3_locked_pipeline)
limit = 0
reuse = false

[profile:windows_box1_ghosts]
innerport = 22
outerport = $((port_base + 4))
container = $(image_name windows_box1_ghosts)
limit = 0
reuse = false

[profile:windows_box2_restricted_protocol]
innerport = 22
outerport = $((port_base + 5))
container = $(image_name windows_box2_restricted_protocol)
limit = 0
reuse = false

[profile:windows_box3_persistence]
innerport = 22
outerport = $((port_base + 6))
container = $(image_name windows_box3_persistence)
limit = 0
reuse = false

[profile:hack_box1_network_recon]
innerport = 22
outerport = $((port_base + 7))
container = $(image_name hack_box1_network_recon)
limit = 0
reuse = false

[profile:hack_box2_cracking_suite]
innerport = 22
outerport = $((port_base + 8))
container = $(image_name hack_box2_cracking_suite)
limit = 0
reuse = false

[profile:hack_box3_web_enum]
innerport = 22
outerport = $((port_base + 9))
container = $(image_name hack_box3_web_enum)
limit = 0
reuse = false

[dockeroptions:hack_box1_network_recon]
cap_add = ["NET_RAW", "NET_ADMIN"]
network = ${HACK_BOX1_NETWORK}

[dockeroptions:hack_box3_web_enum]
cap_add = ["NET_RAW", "NET_ADMIN"]
network = ${HACK_BOX3_NETWORK}

[dockeroptions:windows_box3_persistence]
volumes = ${evidence_json}
EOF

  printf '%s\n' "${config_path}"
}

build_theme_images() {
  detect_theme

  local profile
  for profile in "${PROFILES[@]}"; do
    local context
    context="$(context_dir "${profile}")"
    log "Building ${profile} -> $(image_name "${profile}")"
    docker build -t "$(image_name "${profile}")" "${context}"
  done
}

start_support_stack() {
  detect_theme
  log "Starting support stack"
  docker compose -f "${SUPPORT_COMPOSE_FILE}" -p "${SUPPORT_PROJECT}" up -d --remove-orphans
}

start_switchboard() {
  local config_path="$1"

  log "Starting switchboard with ${config_path}"
  SWITCHBOARD_CONFIG_PATH="${config_path}" \
  SWITCHBOARD_STATE_DIR="${GENERATED_DIR}/state" \
  SWITCHBOARD_BIND_ADDRESS="${SWITCHBOARD_BIND_ADDRESS:-}" \
  docker compose -f "${SWITCHBOARD_COMPOSE_FILE}" -p "${SWITCHBOARD_PROJECT}" up -d --build --force-recreate
}

stop_stack() {
  detect_theme
  log "Stopping switchboard and support stack"
  compose_down_quiet "$(switchboard_config_path)"
  docker compose -f "${SUPPORT_COMPOSE_FILE}" -p "${SUPPORT_PROJECT}" down --remove-orphans >/dev/null 2>&1 || true
}

render_service_unit() {
  ensure_generated_dirs

  local output="${GENERATED_DIR}/systemd/cyber-adventure-${THEME_SLUG}.service"
  local escaped_theme_dir
  escaped_theme_dir="$(printf '%s' "${THEME_DIR}" | sed 's/[\\/&]/\\&/g')"

  sed "s/__THEME_DIR__/${escaped_theme_dir}/g" "${SYSTEMD_TEMPLATE}" > "${output}"
  printf '%s\n' "${output}"
}

status() {
  log "Theme slug: ${THEME_SLUG}"
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' | awk 'NR == 1 || $1 ~ /cyber-adventure/ || $1 ~ /ipnsummit-web/ || $1 ~ /rcc-web/ || $1 ~ /scout-/'
}

detect_theme
cmd="${1:-}"

case "${cmd}" in
  build)
    require_prereqs
    build_theme_images
    ;;
  generate-config)
    require_prereqs
    generate_switchboard_config
    ;;
  up)
    require_prereqs
    compose_down_quiet "$(switchboard_config_path)"
    build_theme_images
    config_path="$(generate_switchboard_config)"
    start_support_stack
    start_switchboard "${config_path}"
    ;;
  down)
    require_prereqs
    stop_stack
    ;;
  status)
    require_prereqs
    status
    ;;
  generate-service)
    require_prereqs
    output_path="$(render_service_unit)"
    log "Rendered ${output_path}"
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    usage
    die "Unknown command '${cmd}'."
    ;;
esac
