#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

KCADM="${KCADM:-/opt/keycloak/bin/kcadm.sh}"
KCADM_CONFIG="${KCADM_CONFIG:-/tmp/kcadm.config}"

require_common_env() {
  : "${KEYCLOAK_URL:?KEYCLOAK_URL is required}"
  : "${KEYCLOAK_AUTH_REALM:?KEYCLOAK_AUTH_REALM is required}"
  : "${KEYCLOAK_REALM:?KEYCLOAK_REALM is required}"
  : "${KEYCLOAK_ADMIN_USER:?KEYCLOAK_ADMIN_USER is required}"
  : "${KEYCLOAK_ADMIN_PASSWORD:?KEYCLOAK_ADMIN_PASSWORD is required}"
}

authenticate() {
  "$KCADM" config credentials \
    --config "$KCADM_CONFIG" \
    --server "$KEYCLOAK_URL" \
    --realm "$KEYCLOAK_AUTH_REALM" \
    --user "$KEYCLOAK_ADMIN_USER" \
    --password "$KEYCLOAK_ADMIN_PASSWORD"
}

wait_for_realm() {
  local attempts="${REALM_WAIT_ATTEMPTS:-60}"
  local interval="${REALM_WAIT_INTERVAL_SECONDS:-5}"
  local attempt

  for ((attempt = 1; attempt <= attempts; attempt++)); do
    if authenticate >/dev/null 2>&1 &&
      "$KCADM" get "realms/${KEYCLOAK_REALM}" \
        --config "$KCADM_CONFIG" >/dev/null 2>&1; then
      echo "Realm '${KEYCLOAK_REALM}' is available."
      return 0
    fi

    echo "Waiting for realm '${KEYCLOAK_REALM}' (${attempt}/${attempts})..."
    sleep "$interval"
  done

  echo "Realm '${KEYCLOAK_REALM}' did not appear in time." >&2
  return 1
}

create_client() {
  local client_id="$1"
  shift

  local uuid
  uuid="$(
    "$KCADM" get clients \
      --config "$KCADM_CONFIG" \
      -r "$KEYCLOAK_REALM" \
      -q "clientId=${client_id}" \
      --fields id \
      --format csv \
      --noquotes
  )"
  uuid="${uuid//$'\r'/}"
  uuid="${uuid//$'\n'/}"

  if [[ -n "$uuid" ]]; then
    echo "Client ${client_id} already exists, skipping..."
  else
    "$KCADM" create clients \
      --config "$KCADM_CONFIG" \
      -r "$KEYCLOAK_REALM" \
      -s "clientId=${client_id}" \
      "$@"
  fi
}

#
# Entrypoint
#

require_common_env

case "${1:-}" in
  wait-for-realm)
    wait_for_realm
    ;;
  create-client)
    client_id="${2:-}"
    shift 2
    create_client "$client_id" "$@"
    ;;
  *)
    echo "Usage: $0 {wait-for-realm|create-client}" >&2
    exit 2
    ;;
esac
