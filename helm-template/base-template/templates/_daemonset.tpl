{{- define "base.daemonset" -}}
{{- $daemonsetValues := . -}}
---
{{- if and $daemonsetValues.Values.argo.rollouts.enabled ( eq $daemonsetValues.Values.argo.rollouts.type "DaemonSet" ) }}
apiVersion: {{ $daemonsetValues.Values.argo.rollouts.apiVersion }}
kind: {{ $daemonsetValues.Values.argo.rollouts.kind }}
{{- else }}
apiVersion: {{ $daemonsetValues.Values.apiVersion | default "apps/v1" }}
kind: {{ $daemonsetValues.Values.kind | default "DaemonSet" }}
{{- end }}
metadata:
  name: {{ include "base.fullname" $daemonsetValues }}
  labels:
    {{- include "base.labels" $daemonsetValues | trim | nindent 4 }}
    {{- with $daemonsetValues.Values.labelsDeployment }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if $daemonsetValues.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $daemonsetValues.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $daemonsetValues | trim | nindent 6 }}
  template:
    metadata:
      {{- if or $daemonsetValues.Values.prometheusScrape $daemonsetValues.Values.podAnnotations }}
      annotations:
        {{- if $daemonsetValues.Values.prometheusScrape }}
        prometheus.io/path: {{ $daemonsetValues.Values.prometheusScrapePath | quote }}
        prometheus.io/port: {{ $daemonsetValues.Values.prometheusScrapePort | quote }}
        prometheus.io/scrape: "true"
        {{- end }}
        {{- if $daemonsetValues.Values.podAnnotations }}
        {{- include "base.valuesPairs" $daemonsetValues.Values.podAnnotations | trim | nindent 8 }}
        {{- end }}
      {{- end }}
      labels:
        {{- with $daemonsetValues.Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- include "base.selectorLabels" $daemonsetValues | trim | nindent 8 }}
    spec:
      {{- with include "base.podDefaultProperties" $daemonsetValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $daemonsetValues.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $daemonsetValues.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $daemonsetValues.Values.image) | nindent 10 }}
          {{- with $containerValues.ports }}
          ports:
            {{- toYaml . | trim | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- if $daemonsetValues.Values.runtimeClassName }}
      runtimeClassName: {{ $daemonsetValues.Values.runtimeClassName }}
      {{- end }}
      {{- if $daemonsetValues.Values.shareProcessNamespace }}
      shareProcessNamespace: {{ $daemonsetValues.Values.shareProcessNamespace }}
      {{- end }}
      containers:
        - name: {{ include "base.name" $daemonsetValues }}
          {{- include "base.image" $daemonsetValues.Values.image | nindent 10 }}
          {{- with $daemonsetValues.Values.ports }}
          ports:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $daemonsetValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- range $containerName, $containerValues := $daemonsetValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $daemonsetValues.Values.image) | nindent 10 }}
          {{- with $containerValues.ports }}
          ports:
            {{- toYaml . | trim | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- with include "base.volumes" $daemonsetValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
{{- end }}