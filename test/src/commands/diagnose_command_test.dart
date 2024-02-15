import 'dart:io';

import 'package:dependabot_gen/src/command_runner.dart';
import 'package:dependabot_gen/src/commands/commands.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../utils.dart';

class _MockLogger extends Mock implements Logger {}

const _usage = '''
Verify the current dependabot setup for potential issues, does not make and modifications

Usage: depgen diagnose [arguments]
-h, --help                 Print this usage information.
-e, --ecosystems           The package ecosystems to consider when searching for packages. Defaults to all available.
                           [githubActions (default), docker (default), gitModules (default), bundler (default), cargo (default), composer (default), elm (default), gomod (default), gradle (default), hex (default), maven (default), npm (default), nuget (default), pip (default), pub (default), swift (default), terraform (default)]
    --ignore-ecosystems    The package ecosystems to ignore when searching for packages. Defaults to none.
                           [githubActions, docker, gitModules, bundler, cargo, composer, elm, gomod, gradle, hex, maven, npm, nuget, pip, pub, swift, terraform]
-S, --silent               Silences all output.
-V, --verbose              Show verbose output.
-i, --ignore-paths         Paths to ignore when searching for packages. Example: "__brick__/**"
-r, --repo-root            Path to the repository root. If omitted, the command will search for the closest git repository root from the current working directory.

Run "depgen help" to see global options.''';

void main() {
  group('diagnose', () {
    late Logger logger;
    late DependabotGenCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = DependabotGenCommandRunner(
        executableName: 'depgen',
        logger: logger,
      );
    });

    test('can be instantiated', () {
      final command = DiagnoseCommand(logger: logger);
      expect(command, isNotNull);
    });

    test('has all the mixins', () {
      final command = CreateCommand(logger: logger);
      expect(command, isA<EcosystemsOption>());
      expect(command, isA<LoggerLevelOption>());
      expect(command, isA<IgnorePathsOption>());
      expect(command, isA<RepositoryRootOption>());
    });

    test('usage message', () async {
      final result = await commandRunner.run(['diagnose', '--help']);
      expect(result, equals(ExitCode.success.code));
      verify(() => logger.info(_usage)).called(1);
    });

    test('reports new entries, reports extraneous entries', () async {
      final repoRoot = prepareFixture(['setups', 'packages']);

      final result =
          await commandRunner.run(['diagnose', '--repo-root', repoRoot.path]);

      expect(result, equals(ExitCode.data.code));

      final finalPath = p.join(repoRoot.path, '.github', 'dependabot.yaml');

      verify(() => logger.detail('Dependabot file config in $finalPath'))
          .called(1);

      final ecosystems = PackageEcosystem.values.map((e) => e.name).toList();

      verify(() => logger.level = Level.info).called(1);

      verify(
        () => logger.detail(
          'This command will search for packages under '
          '${repoRoot.path} for the following package ecosystems: '
          '${ecosystems.join(', ')}',
        ),
      ).called(1);

      verify(
        () => logger.detail(
          'Even though "oogabooga" is an ecosystem unknown '
          'to depgen, we do not claim this as a fail.',
        ),
      ).called(1);

      verify(
        () {
          logger.warn(
            tag: 'FAIL',
            '''
Some issues were found in your dependabot setup:
  Missing entries for packages on (ecosystem:path):
    - docker:/
    - git-submodule:/
    - bundler:/packages/bundler
    - cargo:/packages/cargo
    - composer:/packages/composer
    - elm:/packages/elm
    - gomod:/packages/gomod
    - gradle:/packages/gradle/p1
    - gradle:/packages/gradle/p2
    - gradle:/packages/gradle/p3
    - mix:/packages/hex
    - maven:/packages/maven
    - npm:/packages/npm
    - nuget:/packages/nuget/p1
    - nuget:/packages/nuget/p2
    - pip:/packages/pip/p1
    - pip:/packages/pip/p2
    - pip:/packages/pip/p3
    - pub:/packages/pub
    - swift:/packages/swift
    - terraform:/packages/terraform
  Some existing update entries on dependabot seems to point to wrong locations (ecosystem:path):
    - pub:/
''',
          );
        },
      ).called(1);

      verifyNoMoreInteractions(logger);
    });

    test('reports issues when there is a bunch of things ignored', () async {
      final repoRoot = prepareFixture(
        ['setups', 'packages'],
        withGit: true,
      );

      File(p.join(repoRoot.path, '.gitignore'))
          .writeAsStringSync('packages/pip/p1');
      final existingPath = p.join(repoRoot.path, '.github', 'dependabot.yaml');

      File(existingPath).deleteSync();

      runCommand('git add --all', workingDirectory: repoRoot.path);

      final result = await commandRunner.run([
        'diagnose',
        '--repo-root',
        repoRoot.path,
        '--ecosystems',
        'githubActions,docker,cargo,npm,pip',
        '--ignore-ecosystems',
        'docker,npm',
        '--ignore-paths',
        p.join(repoRoot.path, 'packages', 'pip', 'p2'),
      ]);

      expect(result, equals(ExitCode.data.code));

      verify(
        () {
          logger.warn(
            tag: 'FAIL',
            '''
Some issues were found in your dependabot setup:
  Missing entries for packages on (ecosystem:path):
    - github-actions:/
    - cargo:/packages/cargo
    - pip:/packages/pip/p3
''',
          );
        },
      ).called(1);
    });

    test('handles bad yaml', () async {
      final repoRoot = prepareFixture(['setups', 'bad_yaml']);

      final finalPath = p.join(repoRoot.path, '.github', 'dependabot.yml');

      final result = await commandRunner.run([
        'diagnose',
        '--repo-root',
        repoRoot.path,
      ]);

      expect(result, equals(ExitCode.unavailable.code));

      verify(
        () => logger.err('Error on parsing dependabot file on $finalPath'),
      ).called(1);

      verify(
        () => logger.err(
          'Details: Error parsing the contents of the dependabot config file, '
          'verify if it is compliant with the dependabot specification at '
          '${link(uri: dependabotSpecUri)}',
        ),
      ).called(1);
    });

    test('reports nothing on empty spaces', () async {
      final repoRoot = prepareFixture(['setups', 'empty']);

      final result = await commandRunner.run([
        'diagnose',
        '--repo-root',
        repoRoot.path,
      ]);

      expect(result, equals(ExitCode.success.code));

      verify(
        () => logger.success('No issues found!'),
      ).called(1);
    });
  });
}
