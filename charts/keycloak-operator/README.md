# Keycloak Operator Helm Chart

> [!NOTE]
> This is an independent, community-maintained Helm chart. It is not affiliated with, endorsed by, or maintained by
> the Keycloak project, Red Hat, or their contributors.

## Overview

This Helm chart simply installs the already existing Keycloak Operator manifests
from https://github.com/keycloak/keycloak-k8s-resources.

The main reason for packaging the manifests as a Helm chart is because Terraform's `yamldecode` does not support YAML
files with multiple Kubernetes resources (separated by `---`), making it impossible to do it with Terraform's
`kubernetes_manifest` resource.

Additionally, this chart allows configuring the Keycloak Operator's Kubernetes resources as any other Helm chart via
values and templates.

## License

This code is released under the Apache 2.0 License. See [LICENSE](LICENSE) for more details.

Keycloak, the Keycloak Operator, and any referenced Keycloak container images or upstream Kubernetes resources are
separately licensed by their respective copyright holders. The Apache License 2.0 applied to this chart does not replace
or alter the licenses applicable to those upstream components.
