{{/*
Renders the container image for Keycloak
*/}}
{{- define "graphwise-platform.keycloak.image" -}}
  {{- $repository := .Values.keycloak.image.repository -}}
  {{- $tag := .Values.keycloak.image.tag -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := coalesce .Values.global.imageRegistry .Values.keycloak.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.keycloak.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.keycloak.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}

{{/*
Renders the URL for the Keycloak deployment.
*/}}
{{- define "graphwise-platform.keycloak.url" -}}
  {{- tpl .Values.keycloak.configuration.hostname . -}}
{{- end -}}
