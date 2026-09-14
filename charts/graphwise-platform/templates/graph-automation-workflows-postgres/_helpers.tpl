{{/*
Renders the container image for PostgreSQL
*/}}
{{- define "graphwise-platform.graph-automation.workflows_postgres.image" -}}
  {{- $repository := .Values.automation.workflows_postgres.image.repository -}}
  {{- $tag := .Values.automation.workflows_postgres.image.tag -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := coalesce .Values.global.imageRegistry .Values.automation.workflows_postgres.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.automation.workflows_postgres.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.automation.workflows_postgres.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
