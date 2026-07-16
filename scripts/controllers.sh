#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

########################################################################################################################
# Configuration
########################################################################################################################

export ECK_NAMESPACE="elastic-system"
export CERT_MANAGER_NAMESPACE="cert-manager"
export CNPG_NAMESPACE="cnpg-system"
export KEYCLOAK_NAMESPACE="keycloak"
export KEYCLOAK_OPERATOR_VERSION="25.0.6"

########################################################################################################################
# Install / Upgrade
########################################################################################################################

#
# Ensure namespaces are created
#
kubectl create namespace "${CNPG_NAMESPACE}" || true
kubectl create namespace "${CERT_MANAGER_NAMESPACE}" || true
kubectl create namespace "${ECK_NAMESPACE}" || true
kubectl create namespace "${KEYCLOAK_NAMESPACE}" || true

#
# Elastic Cloud on Kubernetes (ECK) Operator
#
helm repo add elastic https://helm.elastic.co || true
helm repo update elastic
helm upgrade \
  --install \
  --namespace "${ECK_NAMESPACE}" \
  --create-namespace \
  eck-operator \
  elastic/eck-operator

#
# Keycloak Operator
#
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${KEYCLOAK_OPERATOR_VERSION}/kubernetes/keycloaks.k8s.keycloak.org-v1.yml
kubectl apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${KEYCLOAK_OPERATOR_VERSION}/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml
kubectl --namespace ${KEYCLOAK_NAMESPACE} apply -f https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${KEYCLOAK_OPERATOR_VERSION}/kubernetes/kubernetes.yml

#
# Cert Manager controller
#
helm upgrade \
  --install \
  --namespace "${CERT_MANAGER_NAMESPACE}" \
  --create-namespace \
  --set crds.enabled=true \
  cert-manager \
  oci://quay.io/jetstack/charts/cert-manager

#
# Cloud Native PostgreSQL (CNPG) Operator & Barman Cloud Plugin
#
helm repo add cnpg https://cloudnative-pg.github.io/charts || true
helm repo update cnpg
helm upgrade \
  --install \
  --namespace "${CNPG_NAMESPACE}" \
  --create-namespace \
  cnpg \
  cnpg/cloudnative-pg
helm upgrade \
  --install \
  --namespace "${CNPG_NAMESPACE}" \
  --create-namespace \
  cnpg-barman \
  cnpg/plugin-barman-cloud
