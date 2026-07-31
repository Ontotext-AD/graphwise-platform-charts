# Graphwise Platform Helm Chart Changelog

Changelog for the Graphwise Platform Helm chart.

## 0.2.0

### New

- Included [Graphwise GraphRAG Helm chart](https://github.com/poolparty-semantic-suite/graphrag-charts) as part of the
  Graphwise Platform umbrella chart deployment. It is disabled by default, so you have to enable it. Check the README
  for more details.
- Added OpenID clients provisioning for Keycloak when GraphRAG is enabled, see `keycloak_provisioning` for details.
- Added `topologySpreadConstraints` for `elasticsearch`, `keycloak` and `keycloak_postgres` that overrides the default
  topology spread constraints.

### Updated

- Keycloak PostgreSQL cluster will be deployed when Keycloak is enabled as well

### Fixed

- Referred to the actual Keycloak PostgreSQL cluster name in the default topology spread constraints.

## 0.1.1

- Bumped the version of Elasticsearch to **9.3.8**.

## 0.1.0

Initial release of the Graphwise Platform Helm chart.
