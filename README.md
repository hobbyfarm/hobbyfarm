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

Then we can open `ui` or `admin-ui` in our browser.

If `seed.enabled` is `true`, a default user account will be created with the email `admin@example.com` and the password is `password`.