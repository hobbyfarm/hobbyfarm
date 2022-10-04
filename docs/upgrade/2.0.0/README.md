# Upgrade from v1.0.0 to v2.0.0

Starting with v2.0.0, role-based access control (RBAC) abilities were added to HobbyFarm. This also included the removal of the user `admin` flag which previously gated access to administrative functions in HobbyFarm. 
Kubernetes 1.22 deprecated the use of v1beta1 CRDs. CRDs are also now completely managed via Gargantua (the HobbyFarm API server), so no manual intervention is required for CRDs.

This guide will show you how to upgrade to v2.0.0, maintaining admin access for your previously-`admin`-tagged users. 

## Semi-Automatic Update

Execute [rbac_converter.sh](rbac_converter.sh) to automatically apply RBAC changes. 
> We recommend executing `rbac_converter.sh --help` to examine all options prior to execution.

## Manual Update

### Prerequisites

* `kubectl`
* An installation of HobbyFarm of at least v1.0.0

### Steps
1. Create the `hobbyfarm-admin` role by applying [role.yaml](role.yaml) in the namespace in which you installed HobbyFarm. For example, if you installed HobbyFarm into the `hobbyfarm` namespace:

        kubectl apply -f role.yaml -n hobbyfarm

2. Get a list of all users who have the `admin` flag set to `true`:

        kubectl get users -o=jsonpath='{.items[?(@.spec.admin == true)].metadata.name}'

3. For each one of these users, create a rolebinding that maps them to the `hobbyfarm-admin` user. 

        kubectl create rolebinding --namespace [hobbyfarm-install-namespace] --role=hobbyfarm-admin --user=[user]

4. Backup all important resources before upgrading
- scenarios
- courses
- users
- environments
- scheduledevents
- virtualmachinetemplates
- modules
- roles * 
- rolebindings * 

For example: `kubectl get scenarios -o yaml > scenarios.yml`

5. The admin field needs to be removed for all users, store users into a sepperate file

        kubectl get users -n <namespace> -o name | sed -e 's/.*\///g' | xargs -I {} kubectl patch users -n <namespace> {} --type=json -p='[{"op": "remove", "path": "/spec/admin"}]'

        kubectl get users -o yaml > users-import.yml

6. Uninstall the current release
```
helm uninstall hf -n hobbyfarm
```

7. Remove Finalizers from CRDs
Some resources tend to have finalizers that block kubernetes from deleting them right away.

- modules
- executions
- virtualmachines
- states

```
kubectl get executions -n hobbyfarm -o name | sed -e 's/.*\///g' | xargs -I {} kubectl patch executions -n hobbyfarm {} --type=json -p='[{"op": "replace", "path": "/metadata/finalizers", "value": []}]'
```

8. Delete CRDs previously created by hobbyfarm
Most of them are in the hobbyfarm.io scope, some of them are in vm.rancher.io scope, and some are in terraformcontroller.cattle.io scope.

hobbyfarm.io
- accesscodes 
- courses
- dynamicbindconfigurations
- dynamicbindrequests
- environments
- scenarios
- scheduledevents
- sessions
- users
- virtualmachineclaims
- virtualmachinesets
- virtualmachinetemplates
- virtualmachines

vm.rancher.io
- virtualmachines
- settings
- machineimages
- credentials
- arptables

terraformcontroller.cattle.io:
- executions
- modules
- states

Example to remove a CRD:

```
kubectl delete crd scenario.hobbyfarm.io
```

9. Reinstall hobbyfarm
First, make sure that your values.yml holds the current latest images from hobbyfarm, otherwise there could be problems during the upgrade.

Example to reinstall hobbyfarm into the hobbyfarm namespace. 

```
helm upgrade --install hf hobbyfarm --repo https://hobbyfarm.github.io/hobbyfarm --namespace hobbyfarm -f values.yml
```

10. Apply backup
The users from step 5, should be imported, all other resources can be imported from the backup from step 1.

### Let Gargantua create default Roles
Gargantua can also create default roles like "scheduled event creator" or "readonly users". To enable gargantua to create those roles the `installrbacroles` flag must be provided during the start of gargantua.