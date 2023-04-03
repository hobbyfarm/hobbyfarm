# HobbyFarm

This repo contains a Helm chart for deploying hobbyfarm as well as [documentation](https://hobbyfarm.github.io/) on using the platform.

There is a GitHub Actions [Workflow](https://github.com/hobbyfarm/hobbyfarm/actions?query=workflow%3A%22publish+chart%22) that will publish a new version of the chart (to GitHub [Releases](https://github.com/hobbyfarm/hobbyfarm/releases)) if the `version` in `charts/hobbyfarm/Chart.yaml` is bumped.

## Upcoming Release Schedule

| Date | Version |
|------|---------|
| 31 MAY 2023 | v3.0.0 |

## Releases & Versioning

HobbyFarm follows [semantic versioning](https://semver.org/), e.g major.minor.patch. 

| Type | Cadence |
|------|---------|
| Major | Twice-yearly |
| Minor | As needed, between majors |
| Patch | As needed, between minors | 

It is the goal of this project to release **major** versions in the months of March and September of each year. This plan was adopted 03 APR 2023, with a major release scheduled for 31 MAY 2023. Thus the first "on schedule" major release of HobbyFarm will be in SEPT 2023. 

## Contributing

Contributions of all kinds are welcome and encouraged. HobbyFarm is actively seeking contributors in the following areas:

* Go development
* Frontend (Angular) development
* Testing
* **Documentation**
* Project Organization

Contribution docs are in-progress. In the meantime, please reach us via Slack in the `#hobbyfarm` channel on [Rancher Users](https://slack.rancher.io) or via issue in this repository.