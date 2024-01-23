import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/commands/command_base.dart';
import 'package:dependabot_gen/src/dependabot_yaml/spec.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

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
                (e) => e.allowed, 'allowed', ['daily', 'weekly', 'monthly']),
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


  group('', () {});
}
