#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# TODO add arguments to deploy only what is needed

########################################################################################################################
# Configuration
########################################################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PLATFORM_NAMESPACE="graphwise-platform"
export ECK_NAMESPACE="elastic-system"
export CERT_MANAGER_NAMESPACE="cert-manager"
export CNPG_NAMESPACE="cnpg-system"
export KEYCLOAK_NAMESPACE="keycloak"
export KEYCLOAK_OPERATOR_VERSION="25.0.6"
export STRIMZI_NAMESPACE="strimzi-system"
export NFS_GANESHA_NAMESPACE="storage"

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
  --wait \
  --timeout 5m \
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
  --wait \
  --timeout 5m \
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
  --wait \
  --timeout 5m \
  cnpg-barman \
  cnpg/plugin-barman-cloud

#
# Strimzi operator for Kafka clusters & Strimzi drain cleaner for HA deployments
#
helm upgrade \
  --install \
  --namespace "${STRIMZI_NAMESPACE}" \
  --create-namespace \
  --set "watchNamespaces={default,${PLATFORM_NAMESPACE}}" \
  --wait \
  --timeout 5m \
  strimzi-operator \
  oci://quay.io/strimzi-helm/strimzi-kafka-operator
helm upgrade \
  --install \
  --namespace "${STRIMZI_NAMESPACE}" \
  --set namespace.create=false \
  --wait \
  --timeout 5m \
  strimzi-drain-cleaner \
  oci://quay.io/strimzi-helm/strimzi-drain-cleaner

#
# NFS Ganesha for ReadOnlyMany/ReadWriteMany PVs
#
helm repo add nfs-ganesha https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/ || true
helm repo update nfs-ganesha
helm upgrade \
  --install \
  --namespace "${NFS_GANESHA_NAMESPACE}" \
  --create-namespace \
  --values ${SCRIPT_DIR}/nfs-ganesha.values.yaml \
  --wait \
  --timeout 5m \
  nfs-ganesha \
  nfs-ganesha/nfs-server-provisioner
