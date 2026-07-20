{{/*
Helper functions for labels related to Elasticsearch resources
*/}}

{{- define "graphwise-platform.elasticsearch.entitlement-policy.configmap.name" -}}
  {{- printf "%s-%s" .Values.elasticsearch.name "entitlement-policy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
