import 'dart:io';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../utils.dart';

const _kValidDependabotYaml = '''
version: 2
registries:
  maven-github:
    type: maven-repository
    url: https://maven.pkg.github.com/octocat
    username: octocat
    password: '1234'
  npm-npmjs:
    type: npm-registry
    url: https://registry.npmjs.org
    username: octocat
    password: '1234'
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly #keep this comment
  - package-ecosystem: "npm"
    directory: "/npm-package"
    registries:
      - npm-npmjs
    schedule:
      interval: "daily"
  - package-ecosystem: pub
    directory: /
    schedule:
      interval: monthly
      day: monday
      time: '10:00'
      timezone: 'Europe/Amsterdam'
    allow:
      - dependency-name: 'flame_*'
      - dependency-type: 'direct'
    assignees:
      - renancaraujo
    commit-message:
      prefix: 'chore(deps):'
      prefix-development: 'chore(deps-dev):'
      include: scope
    labels:
      - deps
    milestone: 8
    open-pull-requests-limit: 3
    rebase-strategy: auto
    pull-request-branch-name:
      separator: '__'
    reviewers:
      - renancaraujo
    target-branch: main
    vendor: true
    versioning-strategy: increase
    ignore:
      - dependency-name: 'flutter'
        versions:
          - '1.2.3'
        update-types:
          - 'version-update:semver-major'
          - 'version-update:semver-minor'
          - 'version-update:semver-patch'
    insecure-external-code-execution: allow
    # Create a group of dependencies to be updated together in one pull request
    groups:
       # Specify a name for the group, which will be used in pull request titles
       # and branch names
       dev-dependencies:
          # Define patterns to include dependencies in the group (based on
          # dependency name)
          patterns:
            - "rubocop" # A single dependency name
            - "rspec*"  # A wildcard string that matches multiple dependency names
            - "*"       # A wildcard that matches all dependencies in the package
                        # ecosystem. Note: using "*" may open a large pull request
          # Define patterns to exclude dependencies from the group (based on
          # dependency name)
          exclude-patterns:
            - "gc_ruboconfig"
            - "gocardless-*"
''';

const _kInvalidDependabotYaml = '''
version: 1
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly
''';

void main() {
  group('$DependabotFile', () {
    group('fromFile', () {
      test('from a valid dependabot file', () {
        final file = createDepedabotFile(_kValidDependabotYaml);
        final dependabotFile = DependabotFile.fromFile(file);

        expect(dependabotFile.path, file.path);
        expect(dependabotFile.updates, hasLength(3));
      });

      test('from an empty dependabot file', () {
        final file = createDepedabotFile('', create: false);
        final dependabotFile = DependabotFile.fromFile(file);

        expect(dependabotFile.path, file.path);
        expect(dependabotFile.updates, [kDummyEntry]);
        expect(File(dependabotFile.path).existsSync(), isFalse);
      });

      test('from an invalid dependabot file', () {
        final file = createDepedabotFile(_kInvalidDependabotYaml);

        expect(
          () => DependabotFile.fromFile(file),
          throwsA(
            isA<DependabotFileParsingException>()
                .having(
                  (e) => e.filePath,
                  'file path',
                  file.path,
                )
                .having(
                  (e) => e.message,
                  'message',
                  startsWith(
                    'Error parsing the contents of the dependabot config file, '
                    'verify if it is compliant with the dependabot '
                    'specification at',
                  ),
                ),
          ),
        );
      });
    });

    group('fromRepositoryRoot', () {
      test('creates a new file when there is none', () {
        final repoRoot = prepareFixture(['file', 'repo_no_dependabot']);
        final dependabotFile = DependabotFile.fromRepositoryRoot(repoRoot);

        expect(
          dependabotFile.path,
          p.join(
            repoRoot.path,
            '.github',
            'dependabot.yml',
          ),
        );

        expect(File(dependabotFile.path).existsSync(), false);

        expect(dependabotFile.updates, [kDummyEntry]);

        dependabotFile.saveToFile();

        expect(File(dependabotFile.path).existsSync(), true);
        expect(File(dependabotFile.path).readAsStringSync(), '''
version: 2
updates: 
  []
''');
      });

      test('keeps when a yml exists', () {
        final repoRoot = prepareFixture(['file', 'repo_dependabot_yml']);

        final dependabotFile = DependabotFile.fromRepositoryRoot(repoRoot);

        expect(
          dependabotFile.path,
          p.join(
            repoRoot.path,
            '.github',
            'dependabot.yml',
          ),
        );

        expect(File(dependabotFile.path).existsSync(), true);

        expect(dependabotFile.updates, [kDummyEntry]);

        dependabotFile.saveToFile();

        expect(File(dependabotFile.path).existsSync(), true);
        expect(File(dependabotFile.path).readAsStringSync(), '''
version: 2
updates: 
  []
''');
      });

      test('keeps when a yaml exists', () {
        final repoRoot = prepareFixture(['file', 'repo_dependabot_yaml']);

        final dependabotFile = DependabotFile.fromRepositoryRoot(repoRoot);

        expect(
          dependabotFile.path,
          p.join(
            repoRoot.path,
            '.github',
            'dependabot.yaml',
          ),
        );

        expect(File(dependabotFile.path).existsSync(), true);

        expect(dependabotFile.updates, hasLength(3));
      });

      test('throws when there is an invalid file there', () {
        final repoRoot = prepareFixture(['file', 'repo_dependabot_invalid']);

        expect(
          () => DependabotFile.fromRepositoryRoot(repoRoot),
          throwsA(isA<DependabotFileParsingException>()),
        );
      });
    });

    group('editing', () {
      test('adding and removing update entries', () {
        final file = createDepedabotFile(_kValidDependabotYaml);
        final dependabotFile = DependabotFile.fromFile(file);
        expect(dependabotFile.updates, hasLength(3));

        dependabotFile.removeUpdateEntry(
          ecosystem: 'npm',
          directory: '/npm-package',
        );

        expect(
          dependabotFile.updates,
          [
            const UpdateEntry(
              directory: '/',
              ecosystem: 'github-actions',
              schedule: Schedule(
                interval: ScheduleInterval.monthly,
              ),
            ),
            isA<UpdateEntry>()
                .having((p) => p.ecosystem, '', 'pub')
                .having((p) => p.directory, '', '/'),
          ],
        );

        dependabotFile.addUpdateEntry(
          const UpdateEntry(
            directory: '/rust_stuff',
            ecosystem: 'cargo',
            schedule: Schedule(
              interval: ScheduleInterval.weekly,
            ),
            allow: [
              AllowDependencyType(
                dependencyType: 'direct',
              ),
            ],
          ),
        );

        expect(
          dependabotFile.updates,
          [
            const UpdateEntry(
              directory: '/',
              ecosystem: 'github-actions',
              schedule: Schedule(
                interval: ScheduleInterval.monthly,
              ),
            ),
            isA<UpdateEntry>()
                .having((p) => p.ecosystem, '', 'pub')
                .having((p) => p.directory, '', '/'),
            const UpdateEntry(
              directory: '/rust_stuff',
              ecosystem: 'cargo',
              schedule: Schedule(
                interval: ScheduleInterval.weekly,
              ),
              allow: [
                AllowDependencyType(
                  dependencyType: 'direct',
                ),
              ],
            ),
          ],
        );

        dependabotFile
          ..removeUpdateEntry(directory: '/', ecosystem: 'pub')
          ..saveToFile();

        expect(
          File(dependabotFile.path).readAsStringSync(),
          '''
version: 2
registries:
  maven-github:
    type: maven-repository
    url: https://maven.pkg.github.com/octocat
    username: octocat
    password: '1234'
  npm-npmjs:
    type: npm-registry
    url: https://registry.npmjs.org
    username: octocat
    password: '1234'
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly #keep this comment
  - package-ecosystem: cargo
    directory: /rust_stuff
    schedule:
      interval: weekly
    allow:
      - dependency-type: direct
''',
        );
      });
    });
  });
}
