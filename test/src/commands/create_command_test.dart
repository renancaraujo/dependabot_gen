import 'dart:io';

import 'package:dependabot_gen/src/command_runner.dart';
import 'package:dependabot_gen/src/commands/commands.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

const _usage = '''
Create or update the dependabot.yaml file in a repository. 
Will keep existing entries and add new ones for possibly uncovered packages.


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
-r, --repo-root            Path to the repository root. If ommited, the command will search for the closest git repository root from the current working directory.

Run "depgen help" to see global options.''';

void main() {
  group('create', () {
    late Logger logger;
    late DependabotGenCommandRunner commandRunner;

    setUp(() {
      logger = _MockLogger();
      commandRunner = DependabotGenCommandRunner(
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
      'discovers new entries maintaning existing ones '
      '(also maintains commens on troughout the doc) '
      'removing extraneous entries, validating messages along the way',
      () async {},
    );

    test(
      'discovers new entries from passed and '
      'ingore ecossytems, ignored paths',
      () async {},
    );
  });
}
