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

### hidden elements

To create hidden text elements:

    ```hidden:Hidden Text Summary
    This is the hidden Text that opens and closes after a click on the summary
    ```

### nested elements

Nested elements can be applied inside blocks (```) or hidden elements. To define a nested block, use tildes instead of backticks, e.g.:  

    ```
    Some text
    ~~~python
    # This program prints Hello, world!

    print('Hello, world!')
    ~~~
    Some more text
    ```


## development

See the [CONTRIBUTING.md](https://github.com/hobbyfarm/hobbyfarm/blob/master/CONTRIBUTING.md) file in the repo.

