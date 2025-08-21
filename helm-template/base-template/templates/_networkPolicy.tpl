{{/*
Render a NetworkPolicy for the selected pods.

Values contract (minimal):
networkPolicy:
  enabled: false
  annotations: {}
  podSelector: {}            # optional; default = matchLabels selectorLabels
  ingress:
    enabled: true|false
    rules: []                # if omitted or empty => default-deny ingress
    # OR build from primitives:
    from: []                 # list of {podSelector|namespaceSelector|ipBlock}
    ports: []                # list of {port, protocol}
  egress:
    enabled: true|false
    allowDNS: true|false     # convenience: adds TCP/UDP 53 to kube-system
    rules: []                # if omitted or empty => default-deny egress
    # OR build from primitives:
    to: []                   # list of {podSelector|namespaceSelector|ipBlock}
    ports: []                # list of {port, protocol}
*/}}
{{- define "base.networkPolicy" -}}
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "base.fullname" . }}
  labels:
    {{- include "base.labels" . | nindent 4 }}
  {{- with .Values.networkPolicy.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  podSelector:
    {{- if .Values.networkPolicy.podSelector }}
    {{- toYaml .Values.networkPolicy.podSelector | nindent 4 }}
    {{- else }}
    matchLabels:
      {{- include "base.selectorLabels" . | nindent 6 }}
    {{- end }}
  policyTypes:
    {{- if (or (and (hasKey .Values "networkPolicy") (hasKey .Values.networkPolicy "ingress") (hasKey .Values.networkPolicy.ingress "enabled") (eq .Values.networkPolicy.ingress.enabled true)) (and (not (hasKey .Values.networkPolicy "ingress")) (not (hasKey .Values.networkPolicy "egress"))) ) }}
    - Ingress
    {{- end }}
    {{- if and (hasKey .Values "networkPolicy") (hasKey .Values.networkPolicy "egress") (hasKey .Values.networkPolicy.egress "enabled") (eq .Values.networkPolicy.egress.enabled true) }}
    - Egress
    {{- end }}

  {{- /* ---------------- Ingress ---------------- */ -}}
  {{- if and (hasKey .Values "networkPolicy") (hasKey .Values.networkPolicy "ingress") (eq .Values.networkPolicy.ingress.enabled true) }}
  {{- if .Values.networkPolicy.ingress.rules }}
  ingress:
    {{- toYaml .Values.networkPolicy.ingress.rules | nindent 4 }}
  {{- else }}
  {{/* No rules provided → default-deny ingress */}}
  ingress: []
  {{- end }}
  {{- end }}

  {{- /* ---------------- Egress ----------------- */ -}}
  {{- if and (hasKey .Values "networkPolicy") (hasKey .Values.networkPolicy "egress") (eq .Values.networkPolicy.egress.enabled true) }}
  {{- $hasRules := (and (hasKey .Values.networkPolicy.egress "rules") .Values.networkPolicy.egress.rules) }}
  egress:
    {{- if $hasRules }}
    {{- toYaml .Values.networkPolicy.egress.rules | nindent 4 }}
    {{- else }}
    {{/* Start with default-deny egress (empty rule list) and optionally add DNS */}}
    {{- if .Values.networkPolicy.egress.allowDNS }}
    - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: kube-system
      ports:
      - protocol: UDP
        port: 53
      - protocol: TCP
        port: 53
    {{- else }}
    []
    {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
