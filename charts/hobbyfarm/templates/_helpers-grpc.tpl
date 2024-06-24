{{- define "grpc-ca" -}}
{{- $services := list
    "accesscode"
    "authn"
    "authr"
    "course"
    "dbconfig"
    "environment"
    "progress"
    "rbac"
    "scenario"
    "scheduledevent"
    "session"
    "setting"
    "terraform"
    "user"
    "vm"
    "vmclaim"
    "vmset"
    "vmtemplate"
-}}
{{- $altNames := list -}}
{{- range $service := $services -}}
    {{- $altNames = append $altNames (printf "%s.%s.%s.%s.%s" (printf "%s-service-grpc" $service) $.Release.Namespace "svc" "cluster" "local") -}}
    {{- $altNames = append $altNames (printf "%s.%s.%s" (printf "%s-service-grpc" $service) $.Release.Namespace "svc") -}}
    {{- $altNames = append $altNames (printf "%s.%s" (printf "%s-service-grpc" $service) $.Release.Namespace) -}}
{{- end -}}
{{- $ca := genCA "hf-ca" 3650 -}}
{{- $cert := genSignedCert "hobbyfarm.svc.cluster.local" nil $altNames 3650 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
ca.crt: {{ $ca.Cert | b64enc }}
{{- end -}}