## dependabot_gen

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: BSD-3][license_badge]][license_link]



Keep your dependabot.yaml up to date.

---

## Getting Started 🚀

Activate globally via:

```sh
dart pub global activate dependabot_gen
```

Or locally via:

```sh
dart pub global activate --source=path <path to this package>
```

## Usage


```sh
$ depgen create


```

## Running Tests with coverage 🧪

To run all unit tests use the following command:

```sh
$ dart pub global activate coverage 1.2.0
$ dart test --coverage=coverage
$ dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov)
.

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

---

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-BSD-blue.svg
[license_link]: https://opensource.org/license/bsd-3-clause/
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli