{{/*
Expand chart name
*/}}
{{- define "microservice.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name
*/}}
{{- define "microservice.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Chart version labels
*/}}
{{- define "microservice.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
Used in selectors only.
Never change frequently.
*/}}
{{- define "microservice.selectorLabels" -}}
  app.kubernetes.io/name: {{ include "microservice.name" . }}
{{- end }}

{{/*
Common resource labels
Applied to Deployment, Service,
ConfigMap, Secret, etc.
*/}}
{{- define "microservice.labels" -}}
  helm.sh/chart: {{ include "microservice.chart" . }}
  app.kubernetes.io/name: {{ include "microservice.name" . }}
  app.kubernetes.io/instance: {{ .Release.Name }}
  app.kubernetes.io/version: {{ .Chart.AppVersion }}
  app.kubernetes.io/managed-by: {{ .Release.Service }}
  app.kubernetes.io/component: {{ .Values.global.component | default "backend" }}
  app.kubernetes.io/part-of: {{ .Values.global.partOf | default "microbank" }}
  tier: {{ .Values.global.tier | default "workloads" }}
  {{- with .Values.global.labels }}
    {{ toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Pod labels
Contains network-specific
and workload labels
*/}}
{{- define "microservice.podLabels" -}}
  {{ include "microservice.labels" . }}
  network-role: {{ .Values.network.role | default "backend" }}
  {{- with .Values.podLabels }}
    {{ toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Service Account
*/}}
{{- define "microservice.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "microservice.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{/*
ConfigMap checksum for rollout
Auto rollout when configmap data and file changes
*/}}
{{- define "microservice.configRolloutChecksum" -}}
{{ dict
      "data" .Values.configMap.data
      "files" .Values.configMap.files
| toYaml | sha256sum }}
{{- end }}

{{/*
ConfigMap checksum for configmap resource
Includes all fields that can trigger configmap update
*/}}
{{- define "microservice.configResourceChecksum" -}}
{{ dict
      "data" .Values.configMap.data
      "files" .Values.configMap.files
      "labels" .Values.configMap.labels
      "annotations" .Values.configMap.annotations
      "immutable" .Values.configMap.immutable
| toYaml | sha256sum }}
{{- end }}

{{/*
Secret checksum
Auto rollout when secret changes
*/}}
{{- define "microservice.secretChecksum" -}}
  {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
{{- end }}