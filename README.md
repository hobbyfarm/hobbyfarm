# HobbyFarm Helm Chart

Install with Helm!

    helm install --name hf --namespace hobbyfarm .

**NOTE**: currently, the namespace _must_ be `hobbyfarm`.


## Local Development

Using a tool such as [kubefwd](https://kubefwd.com/), we can access services by their internal DNS name.
This allows us to set the backend hostname to the service name.

```
backend:
  hostname: gargantua
```

Then we can open `ui` in our browser and register a new user.
The admin interface will be available at `admin-ui`.

Find your user (`kubectl get users`) and edit the manifest to set `admin: true`.


### Seed Resources

Set `seed.enabled: true` to generate example resources.
The access code for the example scenario is `example`.
