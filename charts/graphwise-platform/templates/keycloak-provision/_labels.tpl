{{/*
Helper functions for labels related to the Keycloak provisioning
*/}}

{{- define "graphwise-platform.keycloak-provision.scripts.configmap.name" -}}
  {{- printf "%s-%s" .Values.keycloak_provision.name "scripts" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
