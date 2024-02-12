
## dependabot_gen


![coverage][coverage_badge]
[![License: BSD-3][license_badge]][license_link]
[![pub package][pub_badge]][pub_link]


Keep your dependabot.yaml up to date.

![thumbnail](https://raw.githubusercontent.com/renancaraujo/dependabot_gen/main/doc/thumbnail.jpg)

---

Dependabot_gen is a [Dart CLI](https://dart.dev/tutorials/server/cmdline) tool to assist in the creation and maintenance of `dependabot.yaml` files in a project.

It aims to create, validate, and maintain such files.


### Why? 🤨

The life of an OSS maintainer is often plagued with repetitive and boring tasks. That is why some of us are obsessed with automation. One of such task is to keep a project's dependencies up to date, entering [dependabot](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file). 

Depedabot does a heck of a job automating the process of monitoring and updating dependencies. But (there's always a but) it introduces a new task: keep the `dependabot.yaml` up to date, with the correct configurations, pointing to the correct paths within the project. 

- What if you move a project within the repo and forget to update that `dependabot.yaml` file?
- What if I have a mono repo and there are a ton of projects inside and I want to create a brand new `dependabot.yaml`?
- What if I wanna make sure the packages in the `dependabot.yaml` covers all the different package ecosystems I use?


Well, in all of those cases, you are dead. Or the equivalent of that: you have to do manual work.


We need automation to automate that automation. That's why this exists.


## Getting Started 🚀

Since this is a Dart CLI, you will need some of the sweet sweet Dart SDK installed. See here how, and a GitHub action for that.

To make it available globally, activate it:

```sh
dart pub global activate dependabot_gen
```

> Or locally via:
```sh
dart pub global activate --source=path <path to this package>
```

## Usage 🤖

After activation, make sure the dart cache is on your path. 
if so you can run:

```sh
$ depgen --help

# or if you don't have the dart cache in your path

$ dart pub global run dependabot_gen --help
```

### `create` command

This command will search for packages to be covered by the repos `dependabot.yaml`. If a `dependabot.yaml` already exists, it will keep the existing valid entries and remove the invalid ones (outdated).

Examples:
```shell
$ depgen create 

# Only consider some package ecosystems, and also ignore some paths for package verification.
$ depgen create --ecosystems cargo,pub,npm --ignore-paths test/fixtures

# Sets "some/path" as repository root and creates update entries with "monthly" schedules.
# Also sets the output to verbose.
$ depgen create --repo-root some/path --schedule-interval monthly --verbose

# See what else is available
$ depgen create --help
```


### `diagnose` command

This is mostly just like `create`, except it is a "dry-run", which means it will not create nor modify any files and will return a non-success code if it encounters anything that should be changed. It's ideal to run on CI.

Examples:
```shell
$ depgen diagnose


# Only consider some package ecosystems, and also ignore some paths for package verification.
$ depgen diagnose --ecosystems cargo,pub,npm --ignore-paths test/fixtures


# See what else is available
$ depgen diagnose --help
```

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-BSD-blue.svg
[license_link]: https://opensource.org/license/bsd-3-clause/
[pub_link]: https://dependabot_gen.pckg.pub
[pub_badge]: https://img.shields.io/pub/v/dependabot_gen.svg



