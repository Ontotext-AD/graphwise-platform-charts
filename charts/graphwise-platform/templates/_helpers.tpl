{{/*
Renders the base URL for the Graphwise Platform deployment.
*/}}
{{- define "graphwise-platform.url" -}}
  {{- tpl .Values.global.platform.url . -}}
{{- end -}}

{{/*
Renders the URL for the GraphDB deployment.
*/}}
{{- define "graphwise-platform.graphdb.url" -}}
  {{- tpl .Values.graphdb.configuration.externalUrl . -}}
{{- end -}}

{{/*
Renders the URL for the Graph Modeling deployment.
*/}}
{{- define "graphwise-platform.graph-modeling.url" -}}
  {{- tpl (index .Values "graph-modeling").configuration.externalUrl . -}}
{{- end -}}
