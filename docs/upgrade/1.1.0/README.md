# Upgrade from to v1.1.0

Starting with v1.1.0, role-based access control (RBAC) abilities were added to HobbyFarm. This also included the removal of the user `admin` flag which previously gated access to administrative functions in HobbyFarm. 

This guide will show you how to upgrade to v1.1.0, maintaining admin access for your previously-`admin`-tagged users. 

## Update

### Prerequisites

* `kubectl`
* An installation of HobbyFarm of at least v1.0.0

### Steps

1. Create the `hobbyfarm-admin` role by applying [role.yaml](role.yaml) in the namespace in which you installed HobbyFarm. For example, if you installed HobbyFarm into the `hobbyfarm` namespace:

        kubectl apply -f role.yaml -n hobbyfarm

2. Get a list of all users who have the `admin` flag set to `true`:

        kubectl get users -o=jsonpath='{range .items[?(@.spec.admin==true)]}{.metadata.name}{"\r\n"}{end}'

3. For each one of these users, create a rolebinding that maps them to the `hobbyfarm-admin` user. 

        kubectl create rolebinding --namespace [hobbyfarm-install-namespace] --role=hobbyfarm-admin --user=[user]