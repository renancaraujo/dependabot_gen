import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/commands/command_base.dart';
import 'package:dependabot_gen/src/dependabot_yaml/spec.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../utils.dart';

class MockLogger extends Mock implements Logger {}

class TestCommand extends CommandBase {
  TestCommand({required super.logger, super.runProcess});

  @override
  String get name => 'test';

  @override
  String get description => 'Test command';

  @override
  String get usage => '';

  @override
  late ArgResults argResults;
}

class LoggerLevelOptionCommand extends TestCommand with LoggerLevelOption {
  LoggerLevelOptionCommand({required super.logger, super.runProcess});
}

class ScheduleOptionCommand extends TestCommand with ScheduleOption {
  ScheduleOptionCommand({required super.logger, super.runProcess});
}

class TargetBranchOptionCommand extends TestCommand with TargetBranchOption {
  TargetBranchOptionCommand({required super.logger, super.runProcess});
}

class IgnorePathsOptionCommand extends TestCommand with IgnorePathsOption {
  IgnorePathsOptionCommand({required super.logger, super.runProcess});
}

class LabelsOptionCommand extends TestCommand with LabelsOption {
  LabelsOptionCommand({required super.logger, super.runProcess});
}

class MilestoneOptionCommand extends TestCommand with MilestoneOption {
  MilestoneOptionCommand({required super.logger, super.runProcess});
}

class EcosystemsOptionCommand extends TestCommand with EcosystemsOption {
  EcosystemsOptionCommand({required super.logger, super.runProcess});
}

class RepositoryRootOptionCommand extends TestCommand
    with RepositoryRootOption {
  RepositoryRootOptionCommand({required super.logger, super.runProcess});
}

void main() {
  late Logger logger;

  setUp(() {
    logger = MockLogger();
  });

  group('$CommandBase', () {
    test('can be instantiated', () {
      expect(
        () => TestCommand(logger: logger),
        returnsNormally,
      );
    });

    test('has a logger', () {
      final command = TestCommand(logger: logger);
      expect(command.logger, same(logger));
    });

    test('checks for git installed', () async {
      late String executableCache;
      late List<String> argumentsCache;
      ProcessResult runProcess(String executable, List<String> arguments) {
        executableCache = executable;
        argumentsCache = arguments;
        return ProcessResult(1, 0, '', '');
      }

      final command = TestCommand(logger: logger, runProcess: runProcess);
      await expectLater(await command.run(), isNull);
      expect(executableCache, 'git');
      expect(argumentsCache, ['--version']);
    });

    test('handles git unstalled', () async {
      ProcessResult runProcess(String executable, List<String> arguments) {
        return ProcessResult(1, 1, '', '');
      }

      final command = TestCommand(logger: logger, runProcess: runProcess);

      final res = await command.run();

      expect(res, ExitCode.unavailable.code);

      verify(
        () => logger.err(
          'Git is not installed or not in the PATH, make sure git available in '
          'your PATH.',
        ),
      ).called(1);
    });
  });

  group('LoggerLevelOption', () {
    test('adds options', () {
      final command = LoggerLevelOptionCommand(logger: logger);

      expect(
        command.argParser.options['verbose'],
        isA<Option>()
            .having((e) => e.abbr, 'abbr', 'V')
            .having((e) => e.help, 'help', 'Show verbose output.')
            .having((e) => e.negatable, 'negatable', false),
      );

      expect(
        command.argParser.options['silent'],
        isA<Option>()
            .having((e) => e.abbr, 'abbr', 'S')
            .having((e) => e.help, 'help', 'Silences all output.')
            .having((e) => e.negatable, 'negatable', false),
      );
    });

    test('sets log level to verbose', () async {
      final command = LoggerLevelOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(['--verbose']);

      final result = await command.run();

      expect(result, isNull);

      verify(() => logger.level = Level.verbose).called(1);
    });

    test('sets log level to silent', () async {
      final command = LoggerLevelOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(['--silent']);

      final result = await command.run();

      expect(result, isNull);

      verify(() => logger.level = Level.quiet).called(1);
    });

    test('sets log level to normal', () async {
      final command = LoggerLevelOptionCommand(logger: logger);
      command.argResults = command.argParser.parse([]);

      final result = await command.run();

      expect(result, isNull);

      verify(() => logger.level = Level.info).called(1);
    });

    test('throws when both silent and verbose are set', () async {
      final command = LoggerLevelOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(['--silent', '--verbose']);

      await expectLater(
        command.run(),
        throwsA(isA<UsageException>()),
      );
    });
  });

  group('ScheduleOption', () {
    test('adds options', () {
      final command = ScheduleOptionCommand(logger: logger);

      expect(
        command.argParser.options['schedule-interval'],
        isA<Option>()
            .having((e) => e.abbr, 'abbr', 'I')
            .having((e) => e.help, 'help', '''
The interval to check for updates on new update entries (does not affect existing ones).''')
            .having((e) => e.defaultsTo, 'defaultsTo', 'weekly')
            .having(
              (e) => e.allowed,
              'allowed',
              ['daily', 'weekly', 'monthly'],
            ),
      );
    });

    test('sets schedule to daily', () async {
      final command = ScheduleOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--schedule-interval', 'daily'],
      );
      expect(
        command.schedule,
        const Schedule(interval: ScheduleInterval.daily),
      );
    });

    test('sets schedule to weekly', () async {
      final command = ScheduleOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--schedule-interval', 'weekly'],
      );
      expect(
        command.schedule,
        const Schedule(interval: ScheduleInterval.weekly),
      );
    });

    test('sets schedule to monthly', () async {
      final command = ScheduleOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--schedule-interval', 'monthly'],
      );
      expect(
        command.schedule,
        const Schedule(interval: ScheduleInterval.monthly),
      );
    });

    test('sets schedule to weekly by default', () async {
      final command = ScheduleOptionCommand(logger: logger);
      command.argResults = command.argParser.parse([]);
      expect(
        command.schedule,
        const Schedule(interval: ScheduleInterval.weekly),
      );
    });
  });

  group('TargetBranchOption', () {
    test('adds options', () {
      final command = TargetBranchOptionCommand(logger: logger);

      expect(
        command.argParser.options['target-branch'],
        isA<Option>().having((e) => e.help, 'help', '''
The target branch to create pull requests against.'''),
      );
    });

    test('sets target branch', () async {
      final command = TargetBranchOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--target-branch', 'main'],
      );
      expect(command.targetBranch, 'main');
    });

    test('sets target branch as null by default', () async {
      final command = TargetBranchOptionCommand(logger: logger);
      command.argResults = command.argParser.parse([]);
      expect(command.targetBranch, isNull);
    });
  });

  group('IgnorePathsOption', () {
    test('adds options', () {
      final command = IgnorePathsOptionCommand(logger: logger);

      expect(
        command.argParser.options['ignore-paths'],
        isA<Option>().having((e) => e.help, 'help', '''
Paths to ignore when searching for packages. Example: "__brick__/**"'''),
      );
    });

    test('sets ignore paths', () async {
      final command = IgnorePathsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--ignore-paths', 'test,example'],
      );
      expect(command.ignorePaths, ['test', 'example']);
    });

    test('sets ignore paths as null by default', () async {
      final command = IgnorePathsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse([]);
      expect(command.ignorePaths, isNull);
    });
  });

  group('LabelsOption', () {
    test('adds options', () {
      final command = LabelsOptionCommand(logger: logger);

      expect(
        command.argParser.options['labels'],
        isA<Option>().having((e) => e.help, 'help', '''
Labels to add to the pull requests.'''),
      );
    });

    test('sets labels', () async {
      final command = LabelsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--labels', 'test,example'],
      );
      expect(command.labels, ['test', 'example']);
    });

    test('sets labels as null by default', () async {
      final command = LabelsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse([]);
      expect(command.labels, isNull);
    });
  });

  group('MilestoneOption', () {
    test('adds options', () {
      final command = MilestoneOptionCommand(logger: logger);

      expect(
        command.argParser.options['milestone'],
        isA<Option>().having((e) => e.help, 'help', '''
The milestone to add to the pull requests. Must be a number.'''),
      );
    });

    test('sets milestone', () async {
      final command = MilestoneOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--milestone', '1'],
      );
      expect(command.milestone, 1);
    });

    test('sets milestone as null by default', () async {
      final command = MilestoneOptionCommand(logger: logger);
      command.argResults = command.argParser.parse([]);
      expect(command.milestone, isNull);
    });
  });

  group('EcosystemsOption', () {
    test('adds options', () {
      final command = EcosystemsOptionCommand(logger: logger);

      expect(
        command.argParser.options['ecosystems'],
        isA<Option>()
            .having((e) => e.help, 'help', '''
The package ecosystems to consider when searching for packages. Defaults to all available.''')
            .having(
              (e) => e.defaultsTo,
              'defaultsTo',
              PackageEcosystem.values.map((e) => e.name),
            )
            .having(
              (e) => e.allowed,
              'allowed',
              PackageEcosystem.values.map((e) => e.name),
            )
            .having((e) => e.abbr, 'abbr', 'e'),
      );

      expect(
        command.argParser.options['ignore-ecosystems'],
        isA<Option>()
            .having((e) => e.help, 'help', '''
The package ecosystems to ignore when searching for packages. Defaults to none.''')
            .having((e) => e.defaultsTo, 'defaultsTo', <String>[])
            .having(
              (e) => e.allowed,
              'allowed',
              PackageEcosystem.values.map((e) => e.name),
            )
            .having((e) => e.abbr, 'abbr', null),
      );
    });

    test('defaults to all envs', () {
      final command = EcosystemsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        [],
      );
      expect(command.ecosystems, [
        PackageEcosystem.githubActions,
        PackageEcosystem.docker,
        PackageEcosystem.gitModules,
        PackageEcosystem.bundler,
        PackageEcosystem.cargo,
        PackageEcosystem.composer,
        PackageEcosystem.gomod,
        PackageEcosystem.hex,
        PackageEcosystem.maven,
        PackageEcosystem.npm,
        PackageEcosystem.nuget,
        PackageEcosystem.pip,
        PackageEcosystem.pub,
        PackageEcosystem.swift,
      ]);
    });

    test('ignore without included', () {
      final command = EcosystemsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--ignore-ecosystems', 'githubActions,npm'],
      );
      expect(command.ecosystems, [
        PackageEcosystem.docker,
        PackageEcosystem.gitModules,
        PackageEcosystem.bundler,
        PackageEcosystem.cargo,
        PackageEcosystem.composer,
        PackageEcosystem.gomod,
        PackageEcosystem.hex,
        PackageEcosystem.maven,
        PackageEcosystem.nuget,
        PackageEcosystem.pip,
        PackageEcosystem.pub,
        PackageEcosystem.swift,
      ]);
    });

    test('include without ignore', () {
      final command = EcosystemsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--ecosystems', 'githubActions,npm'],
      );
      expect(command.ecosystems, [
        PackageEcosystem.githubActions,
        PackageEcosystem.npm,
      ]);
    });

    test('include and ignore', () {
      final command = EcosystemsOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--ecosystems', 'githubActions,npm', '--ignore-ecosystems', 'npm'],
      );
      expect(command.ecosystems, [
        PackageEcosystem.githubActions,
      ]);
    });
  });

  group('RepositoryRootOption', () {
    test('adds options', () {
      final command = RepositoryRootOptionCommand(logger: logger);

      expect(
        command.argParser.options['repo-root'],
        isA<Option>().having((e) => e.help, 'help', '''
Path to the repository root. If ommited, the command will search for the closest git repository root from the current working directory.''').having((e) => e.abbr, 'abbr', 'r'),
      );
    });

    test('when reporoot is specified', () async {
      final command = RepositoryRootOptionCommand(logger: logger);
      command.argResults = command.argParser.parse(
        ['--repo-root', 'my/path'],
      );

      final repoRoot = await command.getRepositoryRoot();

      expect(repoRoot.path, 'my/path');

      expect(command.workingDir, Directory.current.path);
    });

    test(
        'if reporoot is not specified, '
        'fetch the a git root containing cwd', () async {
      final empty = prepareFixture(['empty']);
      final internal = p.join(empty.path, 'internal');

      runCommand('git init', workingDirectory: empty.path);

      final command = RepositoryRootOptionCommand(logger: logger);
      command
        ..argResults = command.argParser.parse([])
        ..testWorkingDir = internal;

      final repoRoot = await command.getRepositoryRoot();

      expect(repoRoot.absolute.existsSync(), true);
    });

    test(
        'if reporoot is not specified, '
        'throw if not ina  git repo', () async {
      final empty = prepareFixture(['empty']);
      final internal = p.join(empty.path, 'internal');


      final command = RepositoryRootOptionCommand(logger: logger);
      command
        ..argResults = command.argParser.parse([])
        ..testWorkingDir = internal;

      await expectLater(
        command.getRepositoryRoot(),
        throwsA(isA<UsageException>()),
      );
    });
  });
}