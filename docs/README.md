# Hobbyfarm
Hobbyfarm is an interactive coding platform that runs in the browser.


## install
Install the [chart](chart.md) with Helm.
More advanced setup infos can be found [here](https://hobbyfarm.github.io/docs/setup/)

## syntax

Scenarios are written in Markdown with a few extra bits of syntax.

Available features include:
* Code Syntax Highlighting
* Click-to-run
* Click-to-file
* Get VM / Session info
* Summary / Solution Element
* Notes with various colours
* Nested Code Blocks

Check the [hobbyfarm docs](https://hobbyfarm.github.io/docs/appendix/markdown_syntax/) for more infos on how to use the special syntax.

## development

See the [CONTRIBUTING.md](https://github.com/hobbyfarm/hobbyfarm/blob/master/CONTRIBUTING.md) file in the repo.

## Terraform Modules
Note: It is not recommended to use Terraform. If you need to use it however you will need to enable it within the values.yml and apply a module after deploying the chart.

<details>
<summary>Apply module</summary>
You will need to apply a module for your provider. See Examples below

```yaml
apiVersion: terraformcontroller.cattle.io/v1
kind: Module
metadata:
  name: tf-module
  namespace: {{ .Release.Namespace }}
spec:
  git:
    url: {{ module_repo }}
```
  ### google:
    module: tf-module
    module_repo: https://github.com/boxboat/tf-module-google
    # credentials: |

  ### aws:
    module: tf-module
    module_repo: https://github.com/hobbyfarm/tf-module-aws
    image: ami-04763b3055de4860b
    region: us-east-1
    # access_key:
    # secret_key:
    # subnet:
    # vpc_security_group_id:

  ### vsphere:
    module: tf-module
    module_repo: https://github.com/hobbyfarm/tf-module-vsphere

  ### do:
    module: tf-module
    module_repo: https://github.com/dramich/domodule
</details>

