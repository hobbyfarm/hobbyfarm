# HobbyFarm

This repo contains a Helm chart for deploying hobbyfarm as well as [documentation](https://hobbyfarm.github.io/) on using the platform.

There is a GitHub Actions [Workflow](https://github.com/hobbyfarm/hobbyfarm/actions?query=workflow%3A%22publish+chart%22) that will publish a new version of the chart (to GitHub [Releases](https://github.com/hobbyfarm/hobbyfarm/releases)) if the `version` in `charts/hobbyfarm/Chart.yaml` is bumped.

## Releases & Versioning

HobbyFarm is released monthly, on or around the 1st of the month. 

Releases may be major, minor, or patch. Release types are determined at time of release depending on the content of the release. 

For upgrades between major versions see docs/upgrade

## Contributing

If you're interested in contributing to HobbyFarm, see [CONTRIBUTING.md](CONTRIBUTING.md) or go directly to [documentation/contributing](https://hobbyfarm.github.io/contributing/)

## Developing

### Skaffold

Skaffold is an open source tool that manages the artifact build and deploy lifecycle, to enhance the local development experience.
Using this method, local images will be produced, tagged with a unique hash, and deployed to the machine's configured kubernetes context.

1. Download and install Skaffold via instructions from [https://www.skaffold.dev](https://www.skaffold.dev)

2. Clone the project repositories into the same folder

    a) Hobbyfarm (this repository) [https://www.github.com/hobbyfarm/hobbyfarm](https://www.github.com/hobbyfarm/hobbyfarm)
    
    b) Gargantua [https://www.github.com/hobbyfarm/gargantua](https://www.github.com/hobbyfarm/gargantua)

    Your folder structure should appear as the following:

    ```
    folder/
        ../hobbyfarm
        ../gargantua
        ../{other hobbyfarm projects}
    ```

2. Navigate to the hobbyfarm folder

3. Run `skaffold dev`