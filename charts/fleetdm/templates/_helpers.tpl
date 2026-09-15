{{/*
Expand the name of the chart.
*/}}
{{- define "fleetdm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fleetdm.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "fleetdm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fleetdm.labels" -}}
helm.sh/chart: {{ include "fleetdm.chart" . }}
app.kubernetes.io/name: {{ include "fleetdm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "fleetdm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fleetdm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Hostname of the bundled MySQL primary service, or the user-supplied override.
*/}}
{{- define "fleetdm.mysql.host" -}}
{{- if .Values.fleet.database.mysql.hostOverride -}}
{{- .Values.fleet.database.mysql.hostOverride -}}
{{- else -}}
{{- printf "%s-mysql" .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret created by the bundled MySQL subchart.
*/}}
{{- define "fleetdm.mysql.secretName" -}}
{{- printf "%s-mysql" .Release.Name -}}
{{- end -}}

{{/*
Hostname of the bundled Redis master service, or the user-supplied override.
*/}}
{{- define "fleetdm.redis.host" -}}
{{- if .Values.fleet.database.redis.hostOverride -}}
{{- .Values.fleet.database.redis.hostOverride -}}
{{- else -}}
{{- printf "%s-redis-master" .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "fleetdm.redis.secretName" -}}
{{- printf "%s-redis" .Release.Name -}}
{{- end -}}

{{- define "fleetdm.serverPrivateKeySecretName" -}}
{{- printf "%s-server-private-key" (include "fleetdm.fullname" .) -}}
{{- end -}}

{{/*
Shared Fleet server environment variables (mysql/redis wiring, TLS, logging).
*/}}
{{- define "fleetdm.env" -}}
- name: FLEET_MYSQL_ADDRESS
  value: "{{ include "fleetdm.mysql.host" . }}:{{ .Values.fleet.database.mysql.port }}"
- name: FLEET_MYSQL_DATABASE
  value: {{ .Values.mysql.auth.database | quote }}
- name: FLEET_MYSQL_USERNAME
  value: {{ .Values.mysql.auth.username | quote }}
- name: FLEET_MYSQL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "fleetdm.mysql.secretName" . }}
      key: mysql-password
- name: FLEET_REDIS_ADDRESS
  value: "{{ include "fleetdm.redis.host" . }}:{{ .Values.fleet.database.redis.port }}"
- name: FLEET_SERVER_ADDRESS
  value: "0.0.0.0:8080"
- name: FLEET_SERVER_TLS
  value: {{ .Values.fleet.tls | quote }}
- name: FLEET_LOGGING_JSON
  value: {{ .Values.fleet.logging.json | quote }}
- name: FLEET_LOGGING_DEBUG
  value: {{ .Values.fleet.logging.debug | quote }}
- name: FLEET_SERVER_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "fleetdm.serverPrivateKeySecretName" . }}
      key: private-key
{{- with .Values.fleet.extraEnv }}
{{ toYaml . }}
{{- end }}
{{- end -}}
