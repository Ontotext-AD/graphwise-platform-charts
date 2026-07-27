# Graphwise Platform Helm Chart

Umbrella Helm chart for installing the Graphwise Platform in Kubernetes.

## Quickstart

```shell
helm upgrade --install --namespace graphwise-platform graphwise-platform graphwise-platform
```

> [!IMPORTANT]
> This chart is at an early stage of development, and it might contain future breaking changes until finalized with
> version 1.0.0.

## Prerequisites

- Kubernetes v1.34+
- Helm v3.8+

For development and testing purposes, you can use [kind](https://kind.sigs.k8s.io/) to create a local Kubernetes
cluster. Check the example [kind.config.yaml](examples/kind/kind.config.yaml).

### Dependencies

The following dependencies are required to install the platform:

1. **Elasticsearch ECK Operator** - https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s
2. **Keycloak Operator** v25 - https://www.keycloak.org/operator/installation
3. **Cert Manager** - https://cert-manager.io/docs/installation/
4. **CNPG Operator** - https://cloudnative-pg.io/docs/1.29/installation_upgrade/
5. **CNPG Barman Cloud Plugin** - https://cloudnative-pg.io/plugin-barman-cloud/docs/installation/

You can use or refer to the helper script [controllers.sh](../../scripts/controllers.sh) to install them.

```shell
../../scripts/controllers.sh
```

### Licenses

Graphwise software requires commercial licenses to run, so you have to create the following secrets:

```shell
kubectl create namespace graphwise-platform || true
kubectl -n graphwise-platform create secret generic graphdb-license --from-file=graphdb.license=graphdb.license || true
kubectl -n graphwise-platform create secret generic graph-modeling-license --from-file=poolparty.key=poolparty.key || true
```

If you are deploying the Graph Automation or GraphRAG services, you will also need a Sercret with the license for the
Graphwise Workflows (powered by n8n):

```shell
kubectl -n graphwise-platform create secret generic graphwise-workflows-license --from-file=N8N_LICENSE_ACTIVATION_KEY=n8n.key || true
```

### Image Pull Secrets

If you use the GraphRAG services, you need to create a Secret for the container registry that Graphwise use to host the
images:

```shell
kubectl -n graphwise-platform create secret docker-registry graphwise-private \
        --docker-server=maven.ontotext.com \
        --docker-username=<username> \
        --docker-password=<password>
```

You can then use it with the global `imagePullSecrets` field in [values.yaml](values.yaml):

```yaml
global:
  imagePullSecrets:
    - name: graphwise-private
```

### Secrets

You can use or refer to the helper script [secrets.sh](../../scripts/secrets.sh). It will generate and provision all
necessary
secrets.

```shell
../../scripts/secrets.sh create_secrets
```

Or alternatively, enable `secrets.autogenrate` in `values.yaml` which will create the Secret automatically during the
installation but this is more suited for test environments. For production, prefer to create the secrets outside of
Helm's lifecycle.

## Configurations

The chart and sub-charts are designed to be platform-agnostic and make use of the available default controllers in a
Kubernetes cluster.

The single most important configuration you need to override is `global.platform.url`: This is the base URL for all
Graphwise Platform services.

The next is to scale your resources according to your needs. This includes resource limits and storage sizes. If you
have a multi-node Kubernetes cluster or make use of Karpenter, you should also set node selectors or topology spread
constraints.

It's best if you start with checking out the main [values.yaml](values.yaml) file and then check the respective
`values.yaml` for each sub-chart.

### Examples

The chart provides a few examples of how to configure the chart for different use cases under the [examples/](examples)
directory.

## Installation

Once all dependencies are installed and all secrets and configurations are created, you can install the platform with:

```shell
helm upgrade --install --namespace graphwise-platform graphwise-platform graphwise-platform
```

Note: If you are using Helm v4, you need to add the `--server-side=false` flag due
to https://github.com/elastic/cloud-on-k8s/issues/8975

## Uninstall

To remove the Graphwise Platform from your cluster, use the following command:

```shell
helm uninstall --namespace graphwise-platform graphwise-platform
```

Note that there are PVCs and PVs associated with the removed StatefulSets that should be deleted manually for a complete
uninstallation.

## License

This code is released under the Apache 2.0 License. See [LICENSE](LICENSE) for more details.
