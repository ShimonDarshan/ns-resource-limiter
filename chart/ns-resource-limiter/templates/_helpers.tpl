{{- /* Common helper templates for ns-resource-limiter chart */ -}}
{{- define "ns-resource-limiter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ns-resource-limiter.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "ns-resource-limiter.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "ns-resource-limiter.labels" -}}
helm.sh/chart: {{ include "ns-resource-limiter.chart" . }}
app.kubernetes.io/name: {{ include "ns-resource-limiter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "ns-resource-limiter.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
