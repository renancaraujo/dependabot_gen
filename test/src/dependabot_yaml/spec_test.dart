import 'dart:convert';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:test/test.dart';

const _kCompleteJson = '''
{
  "version": 2,
  "enable-beta-ecosystems": true,
  "registries": {
    "npm-npmjs": {
      "type": "npm-registry",
      "url": "https://registry.npmjs.org",
      "username": "octocat",
      "password": "1234"
    }
  },
  "updates": [
    {
      "package-ecosystem": "pub",
      "directory": "/",
      "schedule": {
        "interval": "weekly",
        "day": "monday",
        "time": "06:00",
        "timezone": "America/New_York"
      },
      "allow": [
        {
          "dependency-type": "direct"
        },
        {
          "dependency-name": "flame_*"
        }
      ],
      "assignees": [
        "renancaraujo"
      ],
      "commit-message": {
        "prefix": "chore(deps):",
        "prefix-development": "chore(deps-dev):",
        "include": "scope"
      },
      "ignore": [
        {
          "dependency-name": "flutter",
          "versions": [
            "1.2.3"
          ],
          "update-types": [
            "version-update:semver-major",
            "version-update:semver-minor",
            "version-update:semver-patch"
          ]
        }
      ],
      "insecure-external-code-execution": "allow",
      "labels": [
        "dependencies"
      ],
      "milestone": 4,
      "open-pull-requests-limit": 6,
      "pull-request-branch-name": {
        "separator": "--"
      },
      "rebase-strategy": "auto",
      "reviewers": [
        "renancaraujo"
      ],
      "target-branch": "develop",
      "vendor": true,
      "versioning-strategy": "increase"
    }
  ]
}''';

const _kRequiredOnlyJson = '''
{
  "version": 2,
  "updates": [
    {
      "package-ecosystem": "pub",
      "directory": "/",
      "schedule": {
        "interval": "monthly"
      }
    }
  ]
}''';

const _kInvalidAllowedJson = '''
{
  "version": 2,
  "updates": [
    {
      "package-ecosystem": "pub",
      "directory": "/",
      "schedule": {
        "interval": "monthly"
      },
      "allow": [
        {
          "dependency-type": "direct"
        },
        {
          "bananas": "what?*"
        }
      ]
    }
  ]
}''';

void main() {
  group('$DependabotSpec', () {
    group('to json', () {
      test('all values', () {
        const spec = DependabotSpec(
          version: DependabotVersion.v2,
          registries: <String, dynamic>{
            'npm-npmjs': {
              'type': 'npm-registry',
              'url': 'https://registry.npmjs.org',
              'username': 'octocat',
              'password': '1234',
            },
          },
          updates: [
            UpdateEntry(
              directory: '/',
              ecosystem: 'pub',
              schedule: Schedule(
                interval: ScheduleInterval.weekly,
                day: ScheduleDay.monday,
                time: '06:00',
                timeZone: 'America/New_York',
              ),
              allow: [
                AllowDependencyType(dependencyType: 'direct'),
                AllowDependency(name: 'flame_*'),
              ],
              assignees: {'renancaraujo'},
              commitMessage: CommitMessage(
                prefix: 'chore(deps):',
                prefixDevelopment: 'chore(deps-dev):',
                include: 'scope',
              ),
              ignore: [
                Ignore(
                  dependencyName: 'flutter',
                  versions: ['1.2.3'],
                  updateTypes: [
                    UpdateType.major,
                    UpdateType.minor,
                    UpdateType.patch,
                  ],
                ),
              ],
              insecureExternalCodeExecution:
                  InsecureExternalCodeExecution.allow,
              labels: {'dependencies'},
              milestone: 4,
              openPullRequestsLimit: 6,
              pullRequestBranchName: PullRequestBranchName(separator: '--'),
              rebaseStrategy: RebaseStrategy.auto,
              reviewers: ['renancaraujo'],
              targetBranch: 'develop',
              vendor: true,
              versioningStrategy: VersioningStrategy.increase,
            ),
          ],
          enableBetaEcosystems: true,
        );

        expect(spec, encodesTo(_kCompleteJson));
      });

      test('required only', () {
        const spec = DependabotSpec(
          version: DependabotVersion.v2,
          updates: [
            UpdateEntry(
              directory: '/',
              ecosystem: 'pub',
              schedule: Schedule(interval: ScheduleInterval.monthly),
            ),
          ],
        );

        expect(spec, encodesTo(_kRequiredOnlyJson));
      });
    });

    group('from json', () {
      test('all values', () {
        expect(
          _kCompleteJson,
          decodesTo(
            const DependabotSpec(
              version: DependabotVersion.v2,
              updates: [
                UpdateEntry(
                  directory: '/',
                  ecosystem: 'pub',
                  schedule: Schedule(
                    interval: ScheduleInterval.weekly,
                    day: ScheduleDay.monday,
                    time: '06:00',
                    timeZone: 'America/New_York',
                  ),
                  allow: [
                    AllowDependencyType(dependencyType: 'direct'),
                    AllowDependency(name: 'flame_*'),
                  ],
                  assignees: {'renancaraujo'},
                  commitMessage: CommitMessage(
                    prefix: 'chore(deps):',
                    prefixDevelopment: 'chore(deps-dev):',
                    include: 'scope',
                  ),
                  ignore: [
                    Ignore(
                      dependencyName: 'flutter',
                      versions: ['1.2.3'],
                      updateTypes: [
                        UpdateType.major,
                        UpdateType.minor,
                        UpdateType.patch,
                      ],
                    ),
                  ],
                  insecureExternalCodeExecution:
                      InsecureExternalCodeExecution.allow,
                  labels: {'dependencies'},
                  milestone: 4,
                  openPullRequestsLimit: 6,
                  pullRequestBranchName: PullRequestBranchName(separator: '--'),
                  rebaseStrategy: RebaseStrategy.auto,
                  reviewers: ['renancaraujo'],
                  targetBranch: 'develop',
                  vendor: true,
                  versioningStrategy: VersioningStrategy.increase,
                ),
              ],
              enableBetaEcosystems: true,
            ),
          ),
        );
      });

      test('required only', () {
        expect(
          _kRequiredOnlyJson,
          decodesTo(
            const DependabotSpec(
              version: DependabotVersion.v2,
              updates: [
                UpdateEntry(
                  directory: '/',
                  ecosystem: 'pub',
                  schedule: Schedule(interval: ScheduleInterval.monthly),
                ),
              ],
            ),
          ),
        );
      });

      test('invalid "allow" entry', () {
        expect(
          () => DependabotSpec.fromJson(
            jsonDecode(_kInvalidAllowedJson) as Map<String, dynamic>,
          ),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });
    });
  });
}

Matcher encodesTo(String json) => ToJsonMatcher(json);

class ToJsonMatcher extends CustomMatcher {
  ToJsonMatcher(String json) : super('JsonMatcher', 'json', equals(json));

  @override
  Object? featureValueOf(dynamic actual) {
    const encoder = JsonEncoder.withIndent('  ');
    if (actual is DependabotSpec) {
      return encoder.convert(actual.toJson());
    }
    throw ArgumentError.value(actual, 'actual', 'must be a DependabotSpec');
  }
}

Matcher decodesTo(DependabotSpec spec) => FromJsonMatcher(spec);

class FromJsonMatcher extends CustomMatcher {
  FromJsonMatcher(DependabotSpec spec)
      : super('JsonMatcher', 'json', equals(spec));

  @override
  Object? featureValueOf(dynamic actual) {
    if (actual is String) {
      return DependabotSpec.fromJson(
        jsonDecode(actual) as Map<String, dynamic>,
      );
    }
    throw ArgumentError.value(actual, 'actual', 'must be a string');
  }
}
