# Elasticsearch Snapshots Helm Chart

> [!NOTE]
> This is an independent, community-maintained Helm chart. It is not affiliated with, endorsed by, or maintained by
> Elastic.

This chart configures Elasticsearch snapshot repositories and Snapshot Lifecycle Management (SLM) policies using the
supported Elasticsearch REST APIs. It was developed to provide snapshot configurations that are required when
Elasticsearch is deployed as part of the Graphwise Platform.

Elasticsearch is typically deployed on Kubernetes using the official Elastic Cloud on Kubernetes (ECK) operator. The ECK
operator provides the StackConfigPolicy custom resource, which can declaratively configure snapshot repositories and SLM
policies. However, using StackConfigPolicy requires an Elastic Enterprise license.

This chart provides an alternative configuration mechanism that simply uses the Elasticsearch REST APIs directly instead
of the ECK StackConfigPolicy resource. It does not modify ECK, disable or circumvent license checks, or enable
Enterprise-only ECK functionality.

The chart applies the snapshot configurations via a Helm hook during the `post-install` by default. It does not provide
the continuous reconciliation capabilities.

See [Snapshot and restore](https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore) in the official
Elasticsearch documentation for more information about snapshot repositories and SLM policies.

## Supported Object Stores

| Cloud Provider | Storage type       |
|----------------|--------------------|
| AWS            | S3                 |
| Azure          | Azure Blob Storage |

## License

This code is released under the Apache 2.0 License. See [LICENSE](LICENSE) for more details.

Elasticsearch, Elastic Cloud on Kubernetes, and any referenced Elastic container images are separately licensed by
Elastic. The Apache License 2.0 for this chart does not alter or replace those licenses.
