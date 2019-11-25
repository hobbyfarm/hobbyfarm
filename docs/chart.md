# Hobbyfarm Helm Chart

Install with Helm (v3, of course)!

    helm install hf hobbyfarm --repo https://hobbyfarm.github.io/hobbyfarm --namespace hobbyfarm

**NOTE**: currently, the namespace _must_ be `hobbyfarm`.

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

## Local Development

hobbyfarm is known to work with [k3d](https://github.com/rancher/k3d);
execute the `dev.sh` script to run a local cluster (assumes you have [kubefwd](https://kubefwd.com) installed).

Then we can open `ui.hobbyfarm` in our browser and register a new user.
The admin interface will be available at `admin-ui.hobbyfarm`.

Find your user (`kubectl get users`) and edit the manifest to set `admin: true`.


### Seed Resources

Set `seed.enabled: true` to generate example resources.
The access code for the example scenario is `example`.


### Teardown

Make sure there aren't any running VMs that would be orphaned in a cloud provider.

    kubectl delete virtualmachines.hobbyfarm.io --all

Then delete the cluster.

    k3d delete
