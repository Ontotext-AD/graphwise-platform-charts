# Graphwise Platform Helm Charts

Official Helm charts repository for installing the [Graphwise Platform](https://graphwise.ai/) and associated services
in Kubernetes.

The repository can be added with the following command:

```shell
helm repo add graphwise-platform https://Ontotext-AD.github.io/graphwise-platform-charts
```

## About Graphwise

<p align="center">
  <a href="https://graphwise.ai/">
      <img src="https://graphwise.ai/wp-content/uploads/2024/10/graphwise-logo-horizontal-slogan.svg" alt="Graphwise logo" title="Graphwise" height="75">
  </a>
</p>

Graphwise brings confidence to search, analytics, and AI. Our platform is built for enterprises where precision is a
must or complexity is high. We transform disparate data silos into a trusted enterprise knowledge graph, providing a
governed layer of context for consistent, reliable AI applications. At Graphwise, we turn enterprise data from a
liability into an asset. We build the “trusted semantic backbone” that connects disconnected data silos and integrates
your proprietary domain knowledge into your AI. This allows you to govern your AI, boost model accuracy, and drive a
positive ROI.

## Charts

Graphwise Platform charts:

* [graphwise-platform](charts/graphwise-platform) - The main umbrella Helm chart for deploying the Graphwise Platform

Helper charts used by the Graphwise Platform:

* [elasticsearch-snapshots](charts/elasticsearch-snapshots) - Helper chart for managing Elasticsearch snapshot
  configurations
* [keycloak-operator](charts/keycloak-operator) - Helm chart for installing the Keycloak Operator

## License

This code is released under the Apache 2.0 License. See [LICENSE](LICENSE) for more details.
