{{/*
Renders the container image for Elasticsearch
*/}}
{{- define "graphwise-platform.elastic.image" -}}
  {{- $repository := .Values.elasticsearch.image.repository -}}
  {{- $tag := .Values.elasticsearch.image.tag -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := coalesce .Values.global.imageRegistry .Values.elasticsearch.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.elasticsearch.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.elasticsearch.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
