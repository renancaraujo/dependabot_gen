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