# Graphwise Platform on AWS

This directory contains guidelines and examples of how to deploy the Graphwise Platform on AWS.

## Examples

* [AWS Recommended Values](./aws-recommended/values.yaml) - Recommended values for deploying the Graphwise Platform on
  AWS in High-Availability mode.

## IAM Roles

Some of the Graphwise Platform components support native integration with AWS S3 for storing snapshots and backups, but
they require additional IAM roles to be created.

The next example roles can get you started with the necessary low-privilege permissions. They assume the following:

* You have an S3 bucket named `graphwise-platform-backups-1111-2222-3333`. You should replace this with your actual
  bucket name.
* You are using EKS Pod Identity for grating pods access to AWS services.
  See https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html for more details.

**IAM role for Elasticsearch snapshots in S3**

Trust policy for Pod Identity:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEKSToAssumeRoleForPodIdentity",
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:TagSession",
        "sts:AssumeRole"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes-namespace": "graphwise-platform",
          "aws:RequestTag/kubernetes-service-account": "elasticsearch"
        }
      }
    }
  ]
}
```

Permission policy for uploading and managing Elasticsearch snapshots:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListingAndReadingBucketConfiguration",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetAccelerateConfiguration",
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:ListBucketMultipartUploads"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::graphwise-platform-backups-1111-2222-3333"
    },
    {
      "Sid": "AllowUploadingElasticsearchBackupsInBucketPrefix",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::graphwise-platform-backups-1111-2222-3333/elasticsearch/*"
    }
  ]
}
```

**IAM role for PostgreSQL backups in S3**

Trust policy for Pod Identity:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEKSToAssumeRoleForPodIdentity",
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:TagSession",
        "sts:AssumeRole"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes-namespace": "graphwise-platform",
          "aws:RequestTag/kubernetes-service-account": "keycloak-postgres"
        }
      }
    }
  ]
}
```

Permission policy for uploading and managing PostgreSQL backups:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowListingAndReadingBucketConfiguration",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetAccelerateConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::graphwise-platform-backups-1111-2222-3333"
    },
    {
      "Sid": "AllowUploadingPostgresBackupsInBucketPrefix",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectTagging",
        "s3:GetObjectAttributes",
        "s3:PutObject",
        "s3:PutObjectTagging",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::graphwise-platform-backups-1111-2222-3333/keycloak/*"
    }
  ]
}
```

**IAM role for GraphDB backups in S3**

Trust policy for Pod Identity:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEKSToAssumeRoleForPodIdentity",
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:TagSession",
        "sts:AssumeRole"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes-namespace": "graphwise-platform",
          "aws:RequestTag/kubernetes-service-account": "graphdb"
        }
      }
    }
  ]
}
```

Permission policy for uploading and reading GraphDB backups:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadingBucketAccelerateConfiguration",
      "Action": [
        "s3:ListBucket",
        "s3:GetAccelerateConfiguration"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::graphwise-platform-backups-1111-2222-3333"
    },
    {
      "Sid": "AllowUploadingGraphDBBackupsInBucketPrefix",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::graphwise-platform-backups-1111-2222-3333/graphdb/*"
    }
  ]
}
```

## EKS Storage Classes

We recommend using gp3 EBS volumes as persistent storage across for the Graphwise Platform services.
You could make use of two classes:

- gp3 with default IOPS and throughput
- gp3-high with high IOPS for disk heavy workloads

**default gp3 storage class with default IOPS**

The following storage class is using the default IOPS and throughput values for gp3 and it is marked as the default
class in the Kubernetes cluster.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: 3000
  throughput: 125
  csi.storage.k8s.io/fstype: ext4
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

**gp3 with high IOPS**

The following storage class is using high IOPS for gp3 volumes for services that require high IOPS like GraphDB.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3-high
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: 8000
  throughput: 250
  csi.storage.k8s.io/fstype: ext4
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```
