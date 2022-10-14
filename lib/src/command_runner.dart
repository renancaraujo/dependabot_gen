// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/version.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:path/path.dart' as path;

const executableName = 'depgen';
const packageName = 'dependabot_gen';
const description = 'A Very Good Project created by Very Good CLI.';

class DependabotGenCommandRunner extends CommandRunner<int> {
  /// {@macro dependabot_gen_command_runner}
  DependabotGenCommandRunner({
    Logger? logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super(executableName, description) {
    // Add root options and flags
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );
  }

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    final output = StringBuffer('''
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
''');

    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }

      final evalPath = topLevelResults.rest.first;

      final result = await Process.run(
          'find',
          [
            '.',
            '-name',
            'pubspec.yaml',
          ],
          runInShell: true);
      if (result.exitCode != 0) {
        _logger.err('things went south');
        _logger.err(result.stderr as String);
        return ExitCode.ioError.code;
      }
      final stdout = result.stdout as String;
      final paths = stdout
          .split('\n')
          .where((element) => element.isNotEmpty)
          .map(path.dirname);

      for (final pubPath in paths) {
        final convertedPath =
            pubPath.replaceAll('./', '/').replaceAll(RegExp(r'^\.$'), '/');

        output.writeln('''
  - package-ecosystem: "pub"
    directory: "$convertedPath"
    schedule:
      interval: "daily"''');
      }




      _logger.write(output.toString());
      return ExitCode.success.code;
    } on FormatException catch (e, stackTrace) {
      // On format errors, show the commands error message, root usage and
      // exit with an error code
      _logger
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      // On usage errors, show the commands usage message and
      // exit with an error code
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }
}
