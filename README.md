# HobbyFarm Helm Chart

Install with Helm!

    helm install --name hf .


## Local Development

Using a tool such as [kubefwd](https://kubefwd.com/), we can access services by their internal DNS name.
This allows us to set the backend hostname to the service name.

```
backend:
  hostname: gargantua
```

Then we can open `ui` in our browser and register a new user.
The admin interface will be available at `admin-ui`.