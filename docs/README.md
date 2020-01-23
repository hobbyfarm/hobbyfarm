# Hobbyfarm

Hobbyfarm is an interactive coding platform that runs in the browser.


## install

Install the [chart](chart.md) with Helm.


## syntax

Scenarios are written in Markdown with a few extra bits of syntax.

### click to run

To execute code on a particular node (e.g., `node01`):

    ```ctr:node01
    ls
    ```

### get vm info

To get info from a VM:

    ${vminfo:node01:public_ip}

For example,

    http://${vminfo:node01:public_ip}:8080

Here is a list of the available options: https://github.com/hobbyfarm/ui/blob/master/src/app/VM.ts


## development

To get a running cluster execute `./dev.sh`.

This will create a k3s cluster using k3d and proxy the services locally using `kubefwd` (so you can access them by their service name -- e.g., `http://ui`).


### gargantua

Execute `./build-image.sh` to create `hobbyfarm/gargantua:dev`.

Load this image into `k3d`:

    k3d i hobbyfarm/gargantua:dev

Delete the old pod:

    k delete pod -l component=gargantua

Then, after the old pod has terminated, restart `kubefwd` to proxy the new pod.

    sudo -E kubefwd services -n hobbyfarm
