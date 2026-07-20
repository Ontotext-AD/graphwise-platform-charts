{{/*
Renders the container image for PostgreSQL
*/}}
{{- define "graphwise-platform.keycloak_postgres.image" -}}
  {{- $repository := .Values.keycloak_postgres.image.repository -}}
  {{- $tag := .Values.keycloak_postgres.image.tag -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := coalesce .Values.global.imageRegistry .Values.keycloak_postgres.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.keycloak_postgres.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.keycloak_postgres.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
