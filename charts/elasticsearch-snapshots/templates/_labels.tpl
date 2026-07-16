{{- define "elasticsearch-snapshots.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "elasticsearch-snapshots.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "elasticsearch-snapshots.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "elasticsearch-snapshots.labels" -}}
helm.sh/chart: {{ include "elasticsearch-snapshots.chart" . }}
{{ include "elasticsearch-snapshots.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: elasticsearch-snapshots
{{- end }}

{{- define "elasticsearch-snapshots.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elasticsearch-snapshots.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "elasticsearch-snapshots.configmap.utils" -}}
  {{- printf "%s-%s" (include "elasticsearch-snapshots.fullname" .) "utils" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "elasticsearch-snapshots.hook.backups" -}}
  {{- printf "%s-%s" (include "elasticsearch-snapshots.fullname" .) "config" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
