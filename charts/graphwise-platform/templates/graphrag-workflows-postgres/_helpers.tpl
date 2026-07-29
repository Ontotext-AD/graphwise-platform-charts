{{/*
Renders the container image for PostgreSQL
*/}}
{{- define "graphwise-platform.graphrag.workflows_postgres.image" -}}
  {{- $repository := .Values.graphrag.workflows_postgres.image.repository -}}
  {{- $tag := .Values.graphrag.workflows_postgres.image.tag -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := coalesce .Values.global.imageRegistry .Values.graphrag.workflows_postgres.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.graphrag.workflows_postgres.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.graphrag.workflows_postgres.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
