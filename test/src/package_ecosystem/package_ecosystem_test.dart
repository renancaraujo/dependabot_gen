import 'dart:io';

import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../utils.dart';

void main() {
  group('$PackageEcosystem.findUpdateEntries', () {
    late Directory repoRoot;

    setUp(() {
      repoRoot = prepareFixture(
        ['package_ecosystem', 'packages'],
        withGit: true,
      );
    });

    test('finds entries', () {
      expect(
        PackageEcosystem.bundler,
        findsEntries(
          [
            entryWith(
              directory: '/packages/bundler',
              ecosystem: 'bundler',
              groupName: 'packages-bundler-bundler',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.cargo,
        findsEntries(
          [
            entryWith(
              directory: '/packages/cargo',
              ecosystem: 'cargo',
              groupName: 'packages-cargo-cargo',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.composer,
        findsEntries(
          [
            entryWith(
              directory: '/packages/composer',
              ecosystem: 'composer',
              groupName: 'packages-composer-composer',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.docker,
        findsEntries(
          [
            entryWith(
              directory: '/',
              ecosystem: 'docker',
              groupName: 'docker',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.githubActions,
        findsEntries(
          [
            entryWith(
              directory: '/',
              ecosystem: 'github-actions',
              groupName: 'github-actions',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.gitModules,
        findsEntries(
          [
            entryWith(
              directory: '/',
              ecosystem: 'git-submodule',
              groupName: 'git-submodule',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.gomod,
        findsEntries(
          [
            entryWith(
              directory: '/packages/gomod',
              ecosystem: 'gomod',
              groupName: 'packages-gomod-gomod',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.gradle,
        findsEntries(
          [
            entryWith(
              directory: '/packages/gradle/p1',
              ecosystem: 'gradle',
              groupName: 'packages-gradle-p1-gradle',
            ),
            entryWith(
              directory: '/packages/gradle/p2',
              ecosystem: 'gradle',
              groupName: 'packages-gradle-p2-gradle',
            ),
            entryWith(
              directory: '/packages/gradle/p3',
              ecosystem: 'gradle',
              groupName: 'packages-gradle-p3-gradle',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.hex,
        findsEntries(
          [
            entryWith(
              directory: '/packages/hex',
              ecosystem: 'mix',
              groupName: 'packages-hex-mix',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.maven,
        findsEntries(
          [
            entryWith(
              directory: '/packages/maven',
              ecosystem: 'maven',
              groupName: 'packages-maven-maven',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.npm,
        findsEntries(
          [
            entryWith(
              directory: '/packages/npm',
              ecosystem: 'npm',
              groupName: 'packages-npm-npm',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.nuget,
        findsEntries(
          [
            entryWith(
              directory: '/packages/nuget/p1',
              ecosystem: 'nuget',
              groupName: 'packages-nuget-p1-nuget',
            ),
            entryWith(
              directory: '/packages/nuget/p2',
              ecosystem: 'nuget',
              groupName: 'packages-nuget-p2-nuget',
            ),
            entryWith(
              directory: '/packages/nuget/p3',
              ecosystem: 'nuget',
              groupName: 'packages-nuget-p3-nuget',
            ),
            entryWith(
              directory: '/packages/nuget/p4',
              ecosystem: 'nuget',
              groupName: 'packages-nuget-p4-nuget',
            ),
            entryWith(
              directory: '/packages/nuget/p5',
              ecosystem: 'nuget',
              groupName: 'packages-nuget-p5-nuget',
            ),
            entryWith(
              directory: '/packages/nuget/p6',
              ecosystem: 'nuget',
              groupName: 'packages-nuget-p6-nuget',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.pip,
        findsEntries(
          [
            entryWith(
              directory: '/packages/pip/p1',
              ecosystem: 'pip',
              groupName: 'packages-pip-p1-pip',
            ),
            entryWith(
              directory: '/packages/pip/p2',
              ecosystem: 'pip',
              groupName: 'packages-pip-p2-pip',
            ),
            entryWith(
              directory: '/packages/pip/p3',
              ecosystem: 'pip',
              groupName: 'packages-pip-p3-pip',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.pub,
        findsEntries(
          [
            entryWith(
              directory: '/packages/pub',
              ecosystem: 'pub',
              groupName: 'packages-pub-pub',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.swift,
        findsEntries(
          [
            entryWith(
              directory: '/packages/swift',
              ecosystem: 'swift',
              groupName: 'packages-swift-swift',
            ),
          ],
          on: repoRoot,
        ),
      );
    });

    test('skip ignored entries', () {
      expect(
        PackageEcosystem.pip,
        findsEntries(
          [
            entryWith(
              directory: '/packages/pip/p1',
              ecosystem: 'pip',
              groupName: 'packages-pip-p1-pip',
            ),
            entryWith(
              directory: '/packages/pip/p3',
              ecosystem: 'pip',
              groupName: 'packages-pip-p3-pip',
            ),
          ],
          on: repoRoot,
          ignoreFinding: {
            p.join(repoRoot.path, 'packages', 'pip', 'p2'),
          },
        ),
      );

      expect(
        PackageEcosystem.pip,
        findsEntries(
          [],
          on: repoRoot,
          ignoreFinding: {
            p.join(repoRoot.path, 'packages', 'pip'),
          },
        ),
      );
    });

    test('skip git ignored entries', () async {
      File(p.join(repoRoot.path, '.gitignore'))
          .writeAsStringSync('packages/pip/p1');

      runCommand('git add --all', workingDirectory: repoRoot.path);

      expect(
        PackageEcosystem.pip,
        findsEntries(
          [
            entryWith(
              directory: '/packages/pip/p2',
              ecosystem: 'pip',
              groupName: 'packages-pip-p2-pip',
            ),
            entryWith(
              directory: '/packages/pip/p3',
              ecosystem: 'pip',
              groupName: 'packages-pip-p3-pip',
            ),
          ],
          on: repoRoot,
        ),
      );
    });

    test('sets correct parameters', () {
      expect(
        PackageEcosystem.gitModules,
        findsEntries(
          [
            entryWith(
              directory: '/',
              ecosystem: 'git-submodule',
              groupName: 'git-submodule',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.npm,
        findsEntries(
          [
            entryWith(
              directory: '/packages/npm',
              ecosystem: 'npm',
              groupName: 'packages-npm-npm',
            ),
          ],
          on: repoRoot,
        ),
      );
    });

    test('finds packages on the repo root', () {
      expect(
        PackageEcosystem.npm,
        findsEntries(
          [
            entryWith(
              directory: '/',
              ecosystem: 'npm',
              groupName: 'root-npm',
            ),
          ],
          on: Directory(p.join(repoRoot.path, 'packages', 'npm')),
        ),
      );
    });
  });
}

Matcher findsEntries(
  Iterable<Object> entries, {
  required Directory on,
  Set<String>? ignoreFinding,
}) {
  return PackageEcosystemMatcher(
    entries,
    repoRoot: on,
    ignoreFinding: ignoreFinding,
  );
}

Matcher entryWith({
  required String directory,
  required String ecosystem,
  required String groupName,
}) {
  return isA<UpdateEntryInfo>()
      .having((p0) => p0.directory, 'directory', directory)
      .having((p0) => p0.ecosystem, 'ecosystem', ecosystem)
      .having((p0) => p0.groupName, 'group', groupName);
}

class PackageEcosystemMatcher extends CustomMatcher {
  PackageEcosystemMatcher(
    Iterable<Object> entries, {
    required this.repoRoot,
    this.ignoreFinding,
  }) : super(
          'PackageEcosystem that finds packages',
          'found packages ',
          equals(entries),
        );

  final Directory repoRoot;
  final Set<String>? ignoreFinding;

  @override
  Object? featureValueOf(dynamic actual) {
    if (actual is! PackageEcosystem) {
      throw Exception('Expected $PackageEcosystem, got ${actual.runtimeType}');
    }

    return actual.findUpdateEntries(
      repoRoot: repoRoot,
      ignoreFinding: ignoreFinding,
    );
  }
}
