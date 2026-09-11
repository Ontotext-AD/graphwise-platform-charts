# Graphwise Platform Helm Chart Changelog

Changelog for the Graphwise Platform Helm chart.

## 0.3.0

### Breaking

- Updated to GraphRAG chart 2.0.0 which replaces the GraphRAG Workflows Helm chart with a new generic Graphwise
  Workflows Helm chart. See
  the [Upgrade guide](https://github.com/poolparty-semantic-suite/graphrag-charts/blob/graphrag-2.0.0/charts/graphrag/UPGRADE.md#200)
  for more details.
- Configured `graphrag.workflows.name` so you need to re-create the Deplyoment resource if GraphRAG has been enabled.

### New

- Included [Graph Automation Helm chart](https://github.com/poolparty-semantic-suite/graph-automation-charts) as part of
  the Graphwise Platform deployment. It is disabled by default, so you have to enable it. You can configure it with the
  `automation` configuration section.
- Added PostgreSQL cluster deployment for Graph Automation Workflows under `automation.workflows_postgres`.
- Added secrets generation in `secrets.yaml` for the Graph Automation services

### Updated

- Updated to GraphRAG 1.3.0 with GraphRAG Helm chart 2.0.0
- Simplified the secret generation to refer to `existingSecret` properties instead of duplicating them under `secrets`.
- Simplified the NOTES.txt output when GraphRAG is disabled

### Fixed

- Fixed the installation example in the README.md to use the correct `helm` CLI syntax.
- Fixed the secret generation for GraphRAG to refer to the correct namespace and template variables.

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
