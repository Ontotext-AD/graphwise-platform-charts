{{/*
Renders the key for the store setting.
*/}}
{{- define "elasticsearch-snapshots.snapshot.store.setting" -}}
  {{- if eq .Values.snapshots.type "s3" -}}
    bucket
  {{- else if eq .Values.snapshots.type "azure" -}}
    container
  {{- else }}
    {{- fail "The supported values for snapshot store type are 's3' or 'azure'!" -}}
  {{- end -}}
{{- end -}}

{{/*
Renders the value for the snapshot schedule.
*/}}
{{- define "elasticsearch-snapshots.snapshot.schedule" -}}
  {{- if .Values.snapshots.schedule -}}
    "{{ .Values.snapshots.schedule }}"
  {{- else }}
    {{- fail "You need to provide value for 'schedule'." -}}
  {{- end -}}
{{- end -}}
