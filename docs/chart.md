# Hobbyfarm Helm Chart

Install with Helm (v3, of course)!

    helm install hf hobbyfarm --repo https://hobbyfarm.github.io/hobbyfarm --namespace <namespace>

## VM Provider Auth

If using a cloud provider for managing scenario VMs, credentials must be provided.

### AWS

```yaml
terraform:
  aws:
    access_key:
    secret_key:
    subnet:
    vpc_security_group_id:
```

### GCP

Create a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) (in json format) from the [Cloud Console](https://console.cloud.google.com/apis/credentials/serviceaccountkey).

```yaml
terraform:
  google:
    credentials: | 
      {
        "type": "service_account",
        . . .
      }
```

