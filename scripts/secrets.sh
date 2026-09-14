#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

########################################################################################################################
# Configuration
########################################################################################################################

export KEYCLOAK_NAMESPACE="keycloak"
export PLATFORM_NAMESPACE="graphwise-platform"

export KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME="keycloak-admin-credentials"
export KEYCLOAK_GRAPH_MODELING_SECRETS_SECRET_NAME="keycloak-graph-modeling-secret-properties"

export GRAPHDB_INITIAL_USERS_SECRET_NAME="graphdb-initial-users"
export GRAPHDB_ADMIN_CREDENTIALS_SECRET_NAME="graphdb-admin-credentials"
export GRAPHDB_PROVISIONER_CREDENTIALS_SECRET_NAME="graphdb-provisioner-credentials"
export GRAPHDB_PROVISIONER_TOKEN_SECRET_NAME="graphdb-provisioner-token"
export GRAPHDB_CLUSTER_TOKEN_SECRET_NAME="graphdb-cluster-token"

export GRAPH_MODELING_SECRET_PROPERTIES_SECRET_NAME="graph-modeling-secret-properties"
export GRAPH_MODELING_ADMIN_CREDENTIALS_SECRET_NAME="graph-modeling-admin-credentials"

export GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET_NAME="graph-automation-workflows-encryption"
export GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN_SECRET_NAME="graph-automation-workflows-task-runners-token"

export GRAPHRAG_CONVERSATION_DATABASE_CREDENTIALS_SECRET_NAME="graphrag-conversation-database-credentials"
export GRAPHRAG_CONVERSATION_KEYCLOAK_SECRETS_SECRET_NAME="graphrag-conversation-keycloak-secrets"
export GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET_NAME="graphrag-workflows-encryption"

########################################################################################################################
# Functions
########################################################################################################################

main() {
  if [[ $# -eq 0 ]]; then
    usage
    exit 1
  fi

  local func="$1"
  shift

  if declare -F "$func" >/dev/null; then
    "$func" "$@"
  else
    echo "Error: unknown function '$func'" >&2
    echo >&2
    usage >&2
    exit 1
  fi
}

usage() {
  echo "Usage: $0 <function>"
  echo
  echo "Available functions:"
  echo " cleanup_secrets"
  echo " create_secrets"
}

check_binary() {
  local binary="$1"

  if ! command -v "$binary" >/dev/null 2>&1; then
    echo "Error: $binary is required by this script"
    exit 1
  fi
}

namespace_exists() {
  local namespace="$1"
  kubectl get namespace "$namespace" >/dev/null 2>&1
}

secret_exists() {
  local namespace="$1"
  local secret_name="$2"
  kubectl -n "$namespace" get secret "$secret_name" >/dev/null 2>&1
}

cleanup_secrets() {
  # Keycloak
  if secret_exists ${KEYCLOAK_NAMESPACE} ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME}; then
    kubectl -n ${KEYCLOAK_NAMESPACE} delete secret ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME}
  fi
  if secret_exists ${KEYCLOAK_NAMESPACE} ${KEYCLOAK_GRAPH_MODELING_SECRETS_SECRET_NAME}; then
    kubectl -n ${KEYCLOAK_NAMESPACE} delete secret ${KEYCLOAK_GRAPH_MODELING_SECRETS_SECRET_NAME}
  fi
  # GraphDB
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_INITIAL_USERS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHDB_INITIAL_USERS_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_ADMIN_CREDENTIALS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHDB_ADMIN_CREDENTIALS_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_PROVISIONER_CREDENTIALS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHDB_PROVISIONER_CREDENTIALS_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_PROVISIONER_TOKEN_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHDB_PROVISIONER_TOKEN_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_CLUSTER_TOKEN_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHDB_CLUSTER_TOKEN_SECRET_NAME}
  fi
  # Graph Modeling
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_MODELING_SECRET_PROPERTIES_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPH_MODELING_SECRET_PROPERTIES_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_MODELING_ADMIN_CREDENTIALS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPH_MODELING_ADMIN_CREDENTIALS_SECRET_NAME}
  fi
  # Graph Automation
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN_SECRET_NAME}
  fi
  # GraphRAG
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHRAG_CONVERSATION_DATABASE_CREDENTIALS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHRAG_CONVERSATION_DATABASE_CREDENTIALS_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHRAG_CONVERSATION_KEYCLOAK_SECRETS_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHRAG_CONVERSATION_KEYCLOAK_SECRETS_SECRET_NAME}
  fi
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET_NAME}; then
    kubectl -n ${PLATFORM_NAMESPACE} delete secret ${GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET_NAME}
  fi
}

create_secrets() {
  #
  # PLATFORM NAMESPACE
  #
  if namespace_exists ${PLATFORM_NAMESPACE}; then
    echo "Namespace ${PLATFORM_NAMESPACE} already exists, skipping..."
  else
    kubectl create namespace ${PLATFORM_NAMESPACE} || true
  fi

  KEYCLOAK_ADMIN_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPH_MODELING_ADMIN_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPH_MODELING_TAXONOMY_KEYCLOAK_LOGIN_CLIENTSECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPH_MODELING_EXTRACTOR_KEYCLOAK_LOGIN_CLIENTSECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPH_MODELING_GRAPH_SEARCH_KEYCLOAK_LOGIN_CLIENTSECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPH_MODELING_RECOMMENDER_KEYCLOAK_LOGIN_CLIENTSECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  #
  # Keycloak admin credentials
  #
  if secret_exists ${KEYCLOAK_NAMESPACE} ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME}; then
    echo "Secret ${KEYCLOAK_NAMESPACE}/${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${KEYCLOAK_NAMESPACE} create secret generic ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME} \
            --from-literal=KEYCLOAK_ADMIN="admin" \
            --from-literal=KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}"
  fi
  # Copy to platform as well as it is needed by provisioning scripts
  if secret_exists ${PLATFORM_NAMESPACE} ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME}; then
      echo "Secret ${PLATFORM_NAMESPACE}/${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME} already exists, skipping..."
    else
      kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${KEYCLOAK_ADMIN_CREDENTIALS_SECRET_NAME} \
              --from-literal=KEYCLOAK_ADMIN="admin" \
              --from-literal=KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}"
    fi

  #
  # Keycloak Graph Modeler credentials
  #
  if secret_exists ${KEYCLOAK_NAMESPACE} ${KEYCLOAK_GRAPH_MODELING_SECRETS_SECRET_NAME}; then
      echo "Secret ${KEYCLOAK_NAMESPACE}/${KEYCLOAK_GRAPH_MODELING_SECRETS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${KEYCLOAK_NAMESPACE} create secret generic ${KEYCLOAK_GRAPH_MODELING_SECRETS_SECRET_NAME} \
            --from-literal=POOLPARTY_SUPER_ADMIN_PASSWORD="${GRAPH_MODELING_ADMIN_PASSWORD}" \
            --from-literal=PPT_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_TAXONOMY_KEYCLOAK_LOGIN_CLIENTSECRET}" \
            --from-literal=EXTRACTOR_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_EXTRACTOR_KEYCLOAK_LOGIN_CLIENTSECRET}" \
            --from-literal=PPGS_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_GRAPH_SEARCH_KEYCLOAK_LOGIN_CLIENTSECRET}" \
            --from-literal=RECOMMENDER_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_RECOMMENDER_KEYCLOAK_LOGIN_CLIENTSECRET}"
  fi

  #
  # GraphDB
  #

  GRAPHDB_ADMIN_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPHDB_ADMIN_PASSWORD_BCRYPT_HASH=$(htpasswd -bnBC 10 "" "${GRAPHDB_ADMIN_PASSWORD}" | tr -d ':\n')

  GRAPHDB_PROVISIONER_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
  GRAPHDB_PROVISIONER_PASSWORD_BCRYPT_HASH=$(htpasswd -bnBC 10 "" "${GRAPHDB_PROVISIONER_PASSWORD}" | tr -d ':\n')
  GRAPHDB_PROVISIONER_TOKEN=$(echo -n "provisioner:${GRAPHDB_PROVISIONER_PASSWORD}" | base64 -w 0)

  GRAPHDB_CLUSTER_TOKEN=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  GRAPHDB_USERS_JS=$(cat <<EOF
{
  "users": {
    "admin": {
      "username": "admin",
      "password": "{bcrypt}${GRAPHDB_ADMIN_PASSWORD_BCRYPT_HASH}",
      "grantedAuthorities": [ "ROLE_ADMIN" ],
      "appSettings": {
        "DEFAULT_INFERENCE": true,
        "DEFAULT_VIS_GRAPH_SCHEMA": true,
        "DEFAULT_SAMEAS": true,
        "IGNORE_SHARED_QUERIES": false,
        "EXECUTE_COUNT": true
      },
      "dateCreated": 1618403171751
    },
    "provisioner": {
      "username": "provisioner",
      "password": "{bcrypt}${GRAPHDB_PROVISIONER_PASSWORD_BCRYPT_HASH}",
      "grantedAuthorities": [ "ROLE_ADMIN" ],
      "appSettings": {
        "DEFAULT_INFERENCE": true,
        "DEFAULT_VIS_GRAPH_SCHEMA": true,
        "DEFAULT_SAMEAS": true,
        "IGNORE_SHARED_QUERIES": false,
        "EXECUTE_COUNT": true
      },
      "dateCreated": 1618403171751
    }
  }
}
EOF
  )

  #
  # GraphDB initial users
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_INITIAL_USERS_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHDB_INITIAL_USERS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHDB_INITIAL_USERS_SECRET_NAME} \
            --from-literal=users.js="$GRAPHDB_USERS_JS"
  fi

  #
  # GraphDB admin credentials
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_ADMIN_CREDENTIALS_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHDB_ADMIN_CREDENTIALS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHDB_ADMIN_CREDENTIALS_SECRET_NAME} \
            --from-literal=username="admin" \
            --from-literal=password="${GRAPHDB_ADMIN_PASSWORD}"
  fi

  #
  # GraphDB provisioner credentials
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_PROVISIONER_CREDENTIALS_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHDB_PROVISIONER_CREDENTIALS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHDB_PROVISIONER_CREDENTIALS_SECRET_NAME} \
            --from-literal=username="provisioner" \
            --from-literal=password="${GRAPHDB_PROVISIONER_PASSWORD}"
  fi

  #
  # GraphDB provisioner token
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_PROVISIONER_TOKEN_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHDB_PROVISIONER_TOKEN_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHDB_PROVISIONER_TOKEN_SECRET_NAME} \
            --from-literal=GRAPHDB_AUTH_TOKEN="${GRAPHDB_PROVISIONER_TOKEN}"
  fi

  #
  # GraphDB cluster token
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHDB_CLUSTER_TOKEN_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHDB_CLUSTER_TOKEN_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHDB_CLUSTER_TOKEN_SECRET_NAME} \
            --from-literal=GRAPHDB_CLUSTER_TOKEN="${GRAPHDB_CLUSTER_TOKEN}"
  fi

  #
  # Graph Modeling secret properties
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_MODELING_SECRET_PROPERTIES_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPH_MODELING_SECRET_PROPERTIES_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPH_MODELING_SECRET_PROPERTIES_SECRET_NAME} \
            --from-literal=_POOLPARTY_ENCRYPTION_PASSWORD="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)" \
            --from-literal=POOLPARTY_KEYCLOAK_ADMIN_USERNAME="admin" \
            --from-literal=POOLPARTY_KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}" \
            --from-literal=POOLPARTY_PPT_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_TAXONOMY_KEYCLOAK_LOGIN_CLIENTSECRET}" \
            --from-literal=POOLPARTY_PPX_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_EXTRACTOR_KEYCLOAK_LOGIN_CLIENTSECRET}" \
            --from-literal=POOLPARTY_PPGS_KEYCLOAK_LOGIN_CLIENTSECRET="${GRAPH_MODELING_GRAPH_SEARCH_KEYCLOAK_LOGIN_CLIENTSECRET}"
  fi

  #
  # Graph Modeling admin credentials
  #
  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_MODELING_ADMIN_CREDENTIALS_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPH_MODELING_ADMIN_CREDENTIALS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPH_MODELING_ADMIN_CREDENTIALS_SECRET_NAME} \
            --from-literal=username="superadmin" \
            --from-literal=password="${GRAPH_MODELING_ADMIN_PASSWORD}"
  fi

  #
  # Graph Automation Workflows encryption secret
  #
  GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET_NAME} \
            --from-literal=N8N_ENCRYPTION_KEY="${GRAPH_AUTOMATION_WORKFLOWS_ENCRYPTION_SECRET}"
  fi

  #
  # Graph Automation Workflows task runners auth token secret
  #
  GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN_SECRET_NAME} \
            --from-literal=N8N_RUNNERS_AUTH_TOKEN="${GRAPH_AUTOMATION_WORKFLOWS_TASK_RUNNERS_TOKEN}"
  fi

  #
  # GraphRAG Conversation database credentials
  #
  GRAPHRAG_CONVERSATION_DATABASE_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHRAG_CONVERSATION_DATABASE_CREDENTIALS_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHRAG_CONVERSATION_DATABASE_CREDENTIALS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHRAG_CONVERSATION_DATABASE_CREDENTIALS_SECRET_NAME} \
            --from-literal=username="graphrag" \
            --from-literal=password="${GRAPHRAG_CONVERSATION_DATABASE_PASSWORD}"
  fi

  #
  # GraphRAG Conversation keycloak secrets
  #
  GRAPHRAG_CONVERSATION_KEYCLOAK_CLIENT_SECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHRAG_CONVERSATION_KEYCLOAK_SECRETS_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHRAG_CONVERSATION_KEYCLOAK_SECRETS_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHRAG_CONVERSATION_KEYCLOAK_SECRETS_SECRET_NAME} \
            --from-literal=client-secret="${GRAPHRAG_CONVERSATION_KEYCLOAK_CLIENT_SECRET}"
  fi

  #
  # GraphRAG Workflows encryption secret
  #
  GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)

  if secret_exists ${PLATFORM_NAMESPACE} ${GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET_NAME}; then
    echo "Secret ${PLATFORM_NAMESPACE}/${GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET_NAME} already exists, skipping..."
  else
    kubectl --namespace ${PLATFORM_NAMESPACE} create secret generic ${GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET_NAME} \
            --from-literal=N8N_ENCRYPTION_KEY="${GRAPHRAG_WORKFLOWS_ENCRYPTION_SECRET}"
  fi
}

check_binary "kubectl"
check_binary "htpasswd"

main "$@"
