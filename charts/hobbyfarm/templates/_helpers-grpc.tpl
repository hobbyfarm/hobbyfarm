{{- define "grpc-ca" -}}
{{- $altNames := list ( printf "%s.%s.%s.%s.%s" "authn-service-grpc" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "authn-service-grpc" .Release.Namespace "svc") ( printf "%s.%s" "authn-service-grpc" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "authr-service-grpc" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "authr-service-grpc" .Release.Namespace "svc") ( printf "%s.%s" "authr-service-grpc" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "user-service-grpc" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "user-service-grpc" .Release.Namespace "svc") ( printf "%s.%s" "user-service-grpc" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "rbac-service-grpc" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "rbac-service-grpc" .Release.Namespace "svc") ( printf "%s.%s" "rbac-service-grpc" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "accesscode-service-grpc" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "accesscode-service-grpc" .Release.Namespace "svc") ( printf "%s.%s" "accesscode-service-grpc" .Release.Namespace) ( printf "%s.%s.%s.%s.%s" "setting-service-grpc" .Release.Namespace "svc" "cluster" "local") ( printf "%s.%s.%s" "setting-service-grpc" .Release.Namespace "svc") ( printf "%s.%s" "setting-service-grpc" .Release.Namespace) -}}
{{- $ca := genCA "hf-ca" 3650 -}}
{{- $cert := genSignedCert "hobbyfarm.svc.cluster.local" nil $altNames 3650 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
ca.crt: {{ $ca.Cert | b64enc }}
{{- end -}}