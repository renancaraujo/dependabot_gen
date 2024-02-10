import 'dart:io';

import 'package:dependabot_gen/src/command_runner.dart';
import 'package:dependabot_gen/src/commands/commands.dart';
import 'package:dependabot_gen/src/dependabot_yaml/file.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../utils.dart';

class _MockLogger extends Mock implements Logger {}

const _usage = '''
Create or update the dependabot.yaml file in a repository. Will keep existing entries and add new ones for possibly uncovered packages.


Usage: depgen create [arguments]
-h, --help                 Print this usage information.
-e, --ecosystems           The package ecosystems to consider when searching for packages. Defaults to all available.
                           [githubActions (default), docker (default), gitModules (default), bundler (default), cargo (default), composer (default), gomod (default), hex (default), maven (default), npm (default), nuget (default), pip (default), pub (default), swift (default)]
    --ignore-ecosystems    The package ecosystems to ignore when searching for packages. Defaults to none.
                           [githubActions, docker, gitModules, bundler, cargo, composer, gomod, hex, maven, npm, nuget, pip, pub, swift]
-S, --silent               Silences all output.
-V, --verbose              Show verbose output.
-I, --schedule-interval    The interval to check for updates on new update entries (does not affect existing ones).
                           [daily, weekly (default), monthly]
    --target-branch        The target branch to create pull requests against.
    --labels               Labels to add to the pull requests.
    --milestone            The milestone to add to the pull requests. Must be a number.
-i, --ignore-paths         Paths to ignore when searching for packages. Example: "__brick__/**"
-r, --repo-root            Path to the repository root. If omitted, the command will search for the closest git repository root from the current working directory.

Run "depgen help" to see global options.''';

void main() {
  group('create', () {
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
      final command = CreateCommand(logger: logger);
      expect(command, isNotNull);
    });

    test('has all the mixins', () {
      final command = CreateCommand(logger: logger);
      expect(command, isA<EcosystemsOption>());
      expect(command, isA<LoggerLevelOption>());
      expect(command, isA<ScheduleOption>());
      expect(command, isA<TargetBranchOption>());
      expect(command, isA<LabelsOption>());
      expect(command, isA<MilestoneOption>());
      expect(command, isA<IgnorePathsOption>());
      expect(command, isA<RepositoryRootOption>());
    });

    test('usage message', () async {
      final result = await commandRunner.run(['create', '--help']);
      expect(result, equals(ExitCode.success.code));
      verify(() => logger.info(_usage)).called(1);
    });

    test(
      'discovers new entries maintaining existing ones '
      '(also maintains comments on throughout the doc) '
      'removing extraneous entries, '
      'validating messages along the way',
      () async {
        final repoRoot = prepareFixture(['setups', 'packages']);

        final result = await commandRunner.run([
          'create',
          '--repo-root',
          repoRoot.path,
          '-I',
          'daily',
          '--target-branch',
          'master',
          '--labels',
          'dependencies,deps,dependabot',
          '--milestone',
          '4',
        ]);

        final finalPath = p.join(repoRoot.path, '.github', 'dependabot.yaml');

        verify(() => logger.level = Level.info).called(1);

        verify(() => logger.info('Dependabot file config in $finalPath'))
            .called(1);

        final ecosystems = PackageEcosystem.values.map((e) => e.name).toList();

        verify(
          () => logger.detail(
            'This command will search for packages under '
            '${repoRoot.path} for the following package ecosystems: '
            '${ecosystems.join(', ')}',
          ),
        ).called(1);

        verify(
          () => logger.info('Entry for github-actions already exists for /'),
        ).called(1);

        verify(() => logger.success('Added docker entry for /')).called(1);
        verify(() => logger.success('Added git-submodule entry for /'))
            .called(1);
        verify(
          () => logger.success('Added bundler entry for /packages/bundler'),
        ).called(1);
        verify(() => logger.success('Added cargo entry for /packages/cargo'))
            .called(1);
        verify(
          () => logger.success('Added composer entry for /packages/composer'),
        ).called(1);
        verify(() => logger.success('Added gomod entry for /packages/gomod'))
            .called(1);
        verify(() => logger.success('Added mix entry for /packages/hex'))
            .called(1);
        verify(() => logger.success('Added maven entry for /packages/maven'))
            .called(1);
        verify(() => logger.success('Added npm entry for /packages/npm'))
            .called(1);
        verify(
          () => logger.success('Added nuget entry for /packages/nuget/p2'),
        ).called(1);
        verify(
          () => logger.success('Added nuget entry for /packages/nuget/p1'),
        ).called(1);
        verify(() => logger.success('Added pip entry for /packages/pip/p3'))
            .called(1);
        verify(() => logger.success('Added pip entry for /packages/pip/p2'))
            .called(1);
        verify(() => logger.success('Added pip entry for /packages/pip/p1'))
            .called(1);
        verify(() => logger.success('Added pub entry for /packages/pub'))
            .called(1);
        verify(() => logger.success('Added swift entry for /packages/swift'))
            .called(1);

        verify(() => logger.info('Preserved github-actions entry for /'))
            .called(1);

        verify(() => logger.info(yellow.wrap('Removed pub entry for /')))
            .called(1);

        verify(() => logger.info('Preserved oogabooga entry for /')).called(1);

        verify(
          () => logger.info(
            'Finished creating dependabot.yaml in $finalPath',
          ),
        ).called(1);

        verifyNoMoreInteractions(logger);

        final file = File(finalPath);

        expect(result, equals(ExitCode.success.code));

        expect(file.readAsStringSync(), '''
version: 2 #keep this comment
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: monthly #keep this comment
  - package-ecosystem: oogabooga # this entry belongs to an ecosystem we do not know, preserve it
    directory: /
    schedule:
      interval: monthly
  - package-ecosystem: docker
    directory: /
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: git-submodule
    directory: /
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: bundler
    directory: /packages/bundler
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: cargo
    directory: /packages/cargo
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: composer
    directory: /packages/composer
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: gomod
    directory: /packages/gomod
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: mix
    directory: /packages/hex
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: maven
    directory: /packages/maven
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: npm
    directory: /packages/npm
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: nuget
    directory: /packages/nuget/p1
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: nuget
    directory: /packages/nuget/p2
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: pip
    directory: /packages/pip/p1
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: pip
    directory: /packages/pip/p2
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: pip
    directory: /packages/pip/p3
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: pub
    directory: /packages/pub
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
  - package-ecosystem: swift
    directory: /packages/swift
    schedule:
      interval: daily
    labels:
      - dependencies
      - deps
      - dependabot
    milestone: 4
    target-branch: master
''');
      },
    );

    test(
      'discovers new entries from passed and '
      'ignored ecosystems, ignored paths, gitignored paths',
      () async {
        final repoRoot = prepareFixture(
          ['setups', 'packages'],
          withGit: true,
        );

        File(p.join(repoRoot.path, '.gitignore'))
            .writeAsStringSync('packages/pip/p1');
        final existingPath =
            p.join(repoRoot.path, '.github', 'dependabot.yaml');

        File(existingPath).deleteSync();

        runCommand('git add --all', workingDirectory: repoRoot.path);

        final result = await commandRunner.run([
          'create',
          '--repo-root',
          repoRoot.path,
          '--ecosystems',
          'githubActions,docker,cargo,npm,pip',
          '--ignore-ecosystems',
          'docker,npm',
          '--ignore-paths',
          p.join(repoRoot.path, 'packages', 'pip', 'p2'),
        ]);

        expect(result, equals(ExitCode.success.code));

        final file = File(p.join(repoRoot.path, '.github', 'dependabot.yml'));

        expect(file.readAsStringSync(), '''
version: 2
updates: 
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
  - package-ecosystem: cargo
    directory: /packages/cargo
    schedule:
      interval: weekly
  - package-ecosystem: pip
    directory: /packages/pip/p3
    schedule:
      interval: weekly
''');
      },
    );

    test('handles bad yaml', () async {
      final repoRoot = prepareFixture(['setups', 'bad_yaml']);

      final finalPath = p.join(repoRoot.path, '.github', 'dependabot.yml');

      final result = await commandRunner.run([
        'create',
        '--repo-root',
        repoRoot.path,
        '-I',
        'weekly',
        '--target-branch',
        'master',
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
  });
}
