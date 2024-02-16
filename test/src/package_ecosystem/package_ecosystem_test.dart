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
            entryWith(directory: '/packages/bundler', ecosystem: 'bundler'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.cargo,
        findsEntries(
          [
            entryWith(directory: '/packages/cargo', ecosystem: 'cargo'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.composer,
        findsEntries(
          [
            entryWith(directory: '/packages/composer', ecosystem: 'composer'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.docker,
        findsEntries(
          [
            entryWith(directory: '/', ecosystem: 'docker'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.githubActions,
        findsEntries(
          [
            entryWith(directory: '/', ecosystem: 'github-actions'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.gitModules,
        findsEntries(
          [
            entryWith(directory: '/', ecosystem: 'git-submodule'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.gomod,
        findsEntries(
          [
            entryWith(directory: '/packages/gomod', ecosystem: 'gomod'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.gradle,
        findsEntries(
          [
            entryWith(directory: '/packages/gradle/p1', ecosystem: 'gradle'),
            entryWith(directory: '/packages/gradle/p2', ecosystem: 'gradle'),
            entryWith(directory: '/packages/gradle/p3', ecosystem: 'gradle'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.hex,
        findsEntries(
          [
            entryWith(directory: '/packages/hex', ecosystem: 'mix'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.maven,
        findsEntries(
          [
            entryWith(directory: '/packages/maven', ecosystem: 'maven'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.npm,
        findsEntries(
          [
            entryWith(directory: '/packages/npm', ecosystem: 'npm'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.nuget,
        findsEntries(
          [
            entryWith(directory: '/packages/nuget/p1', ecosystem: 'nuget'),
            entryWith(directory: '/packages/nuget/p2', ecosystem: 'nuget'),
            entryWith(directory: '/packages/nuget/p3', ecosystem: 'nuget'),
            entryWith(directory: '/packages/nuget/p4', ecosystem: 'nuget'),
            entryWith(directory: '/packages/nuget/p5', ecosystem: 'nuget'),
            entryWith(directory: '/packages/nuget/p6', ecosystem: 'nuget'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.pip,
        findsEntries(
          [
            entryWith(directory: '/packages/pip/p1', ecosystem: 'pip'),
            entryWith(directory: '/packages/pip/p2', ecosystem: 'pip'),
            entryWith(directory: '/packages/pip/p3', ecosystem: 'pip'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.pub,
        findsEntries(
          [
            entryWith(directory: '/packages/pub', ecosystem: 'pub'),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.swift,
        findsEntries(
          [
            entryWith(directory: '/packages/swift', ecosystem: 'swift'),
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
            entryWith(directory: '/packages/pip/p1', ecosystem: 'pip'),
            entryWith(directory: '/packages/pip/p3', ecosystem: 'pip'),
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
            entryWith(directory: '/packages/pip/p2', ecosystem: 'pip'),
            entryWith(directory: '/packages/pip/p3', ecosystem: 'pip'),
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
            (
              directory: '/',
              ecosystem: 'git-submodule',
            ),
          ],
          on: repoRoot,
        ),
      );

      expect(
        PackageEcosystem.npm,
        findsEntries(
          [
            const (
              directory: '/packages/npm',
              ecosystem: 'npm',
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
            entryWith(directory: '/', ecosystem: 'npm'),
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

Matcher entryWith({required String directory, required String ecosystem}) {
  return isA<UpdateEntryInfo>()
      .having((p0) => p0.directory, 'directory', directory)
      .having((p0) => p0.ecosystem, 'ecosystem', ecosystem);
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
      throw Exception('Expected PackageEcosystem, got ${actual.runtimeType}');
    }

    return actual.findUpdateEntries(
      repoRoot: repoRoot,
      ignoreFinding: ignoreFinding,
    );
  }
}
