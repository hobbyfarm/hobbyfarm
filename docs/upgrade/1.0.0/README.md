# How to update Hobbyfarm from 0.x.x to 1.0.0?
In 1.0.0 we introduced the ability to run multiple instances of hobbyfarm inside one kubernetes cluster.
Therefore we needed to change all CRDs from cluster scope to namespaced. Due to the fact that helm upgrade can not change CRDs from cluster scope to namespaced, there are some manual steps required.

## Semi-Automatic Update
We provide a `helper.sh` that tries to do the required steps for you.

The helper script will also try to backup your hobbyfarm data first. However this is not 100% safe and a manual backup should be done before upgrading.

Running the helper without arguments should work right fine, however different Arguments can be provided to the helper.

 Argument   |      Alternative      |  Description | Default | 
|----------|:-------------:|------:|----:|
| -h | --help | Display help text | - |
| -n | --namespace   | Helm release namespace | hobbyfarm |
| -r | --release     |  Helm release name     | hf |
| -b | --backup-folder  |  Backup Folder    | ./backup |
| -v | --values     |  Path to values.yml     | values.yml |
| -c | --repo     |  Chart repository     | https://hobbyfarm.github.io/hobbyfarm |
| -u | --uninstall     |  Only uninstall hf |   - |

## Manual Update

### 1. Backup resources
Backup all important resources:
- scenarios
- courses
- users
- environments
- scheduledevents
- virtualmachinetemplates
- modules

For example: `kubectl get scenarios -o yaml > scenarios.yml`

### 2. Uninstall the current release
```
helm uninstall hf -n hobbyfarm
```

### 3. Remove Finalizers from CRDs
Some resources tend to have finalizers that block kubernetes from deleting them right away.

- modules
- executions
- virtualmachines
- states

```
kubectl get executions -n hobbyfarm -o name | sed -e 's/.*\///g' | xargs -I {} kubectl patch executions -n hobbyfarm {} --type=json -p='[{"op": "replace", "path": "/metadata/finalizers", "value": []}]'
```

### 4. Delete CRDs
Delete CRDs previously created by hobbyfarm
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

### 5. Reinstall hobbyfarm
First, make sure that your values.yml holds the current latest images from hobbyfarm, otherwise there could be problems during the upgrade.

Example to reinstall hobbyfarm into the hobbyfarm namespace. 

```
helm upgrade --install hf hobbyfarm --repo https://hobbyfarm.github.io/hobbyfarm --namespace hobbyfarm -f values.yml
```

### 6. Restore Resources
The resources that where backed up in #1 can be restored

For example:
``` 
kubectl apply -n hobbyfarm -f scenarios.yml
```

## Happy farming!
You can install another instance into the same cluster using the same command provied in the manual steps under #5. You would just have to change the namespace.