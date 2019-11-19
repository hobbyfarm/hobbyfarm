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
