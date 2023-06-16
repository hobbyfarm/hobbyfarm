{{- define "grpc-ca" -}}
{{- $altNames := list ( printf "%s" "localhost") ( printf "%s.%s.%s.%s.%s" "authn-service" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "authn-service" .Release.Namespace "svc") ( printf "%s.%s" "authn-service" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "authr-service" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "authr-service" .Release.Namespace "svc") ( printf "%s.%s" "authr-service" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "user-service" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "user-service" .Release.Namespace "svc") ( printf "%s.%s" "user-service" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "rbac-service" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "rbac-service" .Release.Namespace "svc") ( printf "%s.%s" "rbac-service" .Release.Namespace) -}}
{{- $ca := genCA "hf-ca" 3650 -}}
{{- $cert := genSignedCert "hobbyfarm.svc.cluster.local" nil $altNames 3650 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
ca.crt: {{ $ca.Cert | b64enc }}
{{- end -}}