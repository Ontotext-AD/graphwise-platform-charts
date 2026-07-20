# Recommended Configurations for Graphwise Platform on AWS

The [values.yaml](values.yaml) in this directory contains recommended configurations for deploying the Graphwise
Platform on AWS EKS.

## What is Covered?

It prepares recommended configurations for the Data Management suite of services.

- Elasticsearch
- Keycloak
- PostgreSQL for Keycloak
- GraphDB
- Graph Modeling

## Features

**High Availability**

For high availability, in production, the following features have been enabled:

* Multiple replicas for stateless services
* Multiple replicas for stateful services that support cluster replication
* Spreading pods over failure domains: availability zones and kubernetes nodes

**Backups**

For resiliency and durability, the following services have been configured to upload their data to S3:

* Elasticsearch native snapshots
* PostgreSQL backups via CNPG barman
* GraphDB native backups

Note, however, that you will need to configure IAM roles for the services to access S3.
You can refer to the example IAM roles section in [the main AWS readme file](../README.md#iam-roles)

**Resources**

For production loads, the following resources have been increased:

- Using gp3 as a storage class for persistent volumes
- Increased storage size for all services
- Increased resource limits for all services
