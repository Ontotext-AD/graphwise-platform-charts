# Graphwise Platform Helm Chart Changelog

Changelog for the Graphwise Platform Helm chart.

## 0.3.0

### Breaking

This version contains breaking changes, mostly coming from the upstream Helm charts so make sure to follow their
migration and upgrade guidelines.

- Updated to GraphRAG chart 2.0.0 which replaces the GraphRAG Workflows Helm chart with a new generic Graphwise
  Workflows Helm chart. See
  the [Upgrade guide](https://github.com/poolparty-semantic-suite/graphrag-charts/blob/graphrag-2.0.0/charts/graphrag/UPGRADE.md#200)
  for more details.
- Configured `graphrag.workflows.name` so you need to re-create the Deplyoment resource if GraphRAG has been enabled.
- Upgraded Graph Modeling to version 10.3.2 (chart 1.0.0), check the following upgrade guides:
  - Graph Modeling Helm chart
    1.0.0 [UPGRADE.md](https://github.com/poolparty-semantic-suite/charts/blob/poolparty-1.0.0/poolparty/UPGRADE.md)
  - ADF Helm chart
    1.0.0 [UPGRADE.md](https://github.com/poolparty-semantic-suite/charts/blob/adf-1.0.0/adf/CHANGELOG.md)
  - Semantic Workbench Helm chart
    1.0.0 [UPGRADE.md](https://github.com/poolparty-semantic-suite/charts/blob/semantic-workbench-1.0.0/workbench/UPGRADE.md)
- Updated `keycloak.configuration.graphModelingSecret` to include new key references, you have to recreate the secret
- Updated `graph-modeling.configuration.properties` to set default values, check your overrides for any conflicting
  values
- Updated `adf.configuration.properties` to set new default values, check your overrides for any conflicts
- Updated `adf.extraEnv` to refer to a different secret key, check your overrides for any conflicts
- Updated `semantic-workbench.configuration.properties` to set new default values, check your overrides for any
  conflicts
- Updated `semantic-workbench.extraEnv` to refer to a different secret key, check your overrides for any conflicts

### New

- Included [Graph Automation Helm chart](https://github.com/poolparty-semantic-suite/graph-automation-charts) as part of
  the Graphwise Platform deployment. It is disabled by default, so you have to enable it. You can configure it with the
  `automation` configuration section.
- Added PostgreSQL cluster deployment for Graph Automation Workflows under `automation.workflows_postgres`.
- Added secrets generation in `secrets.yaml` for the Graph Automation services
- Added `keycloak.configuration.properties` that can inject key values as environment variables in the Keycloak
  container.

### Updated

- Updated GraphRAG to version 1.3.0 with GraphRAG Helm chart 2.0.0
- Updated Elasticsearch to version 9.4.5 (`ontotext/poolparty-elasticsearch:9.4.5`)
- Updated Keycloak to version 2.6.1 (`ontotext/poolparty-keycloak:2.6.1`)
- Updated GraphDB to version 11.5.0 with chart 12.5.0
- Updated Graph Modeling to version 10.3.2 with chart 1.0.0
- Updated ADF to version 1.9.0 with chart 1.0.0
- Updated Graph Views to version 1.0.1 with chart 0.2.0
- Updated Semantic Workbench to version 2.5.0 with chart 1.0.0
- Updated the secret generation to support Graph Modeling 10.3
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
