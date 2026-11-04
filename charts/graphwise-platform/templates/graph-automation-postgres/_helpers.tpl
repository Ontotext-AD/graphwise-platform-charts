{{/*
Renders the container image for PostgreSQL
*/}}
{{- define "graphwise-platform.graph-automation.postgres.image" -}}
  {{- $repository := .Values.automation.postgres.image.repository -}}
  {{- $tag := .Values.automation.postgres.image.tag -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := coalesce .Values.global.imageRegistry .Values.automation.postgres.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.automation.postgres.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.automation.postgres.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
