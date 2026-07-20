{{/*
Expand the name of the chart.
*/}}
{{- define "graphwise-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "graphwise-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "graphwise-platform.labels" -}}
helm.sh/chart: {{ include "graphwise-platform.chart" . }}
{{ include "graphwise-platform.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels }}
{{ tpl (toYaml .Values.labels) . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "graphwise-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "graphwise-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
