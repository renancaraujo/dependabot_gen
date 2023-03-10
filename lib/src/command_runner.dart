// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

const executableName = 'depgen';
const packageName = 'dependabot_gen';
const description = 'A Very Good Project created by Very Good CLI.';

class DependabotGenCommandRunner extends CommandRunner<int> {
  /// {@macro dependabot_gen_command_runner}
  DependabotGenCommandRunner({
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super(executableName, description) {
    // Add root options and flags
    argParser
      ..addMultiOption('ignore')
      ..addMultiOption(
        'ecosystems',
        allowed: PackageEcosystem.values.map((e) => e.name),
      )
      ..addFlag(
        'include-gh-actions',
        abbr: 'g',
      )
      ..addFlag(
        'verbose',
        help: 'Noisy logging, including all shell commands executed.',
      );
  }

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    final output = StringBuffer('''
version: 2
updates:
''');

    try {
      final topLevelResults = parse(args);
      if (topLevelResults['verbose'] == true) {
        _logger.level = Level.verbose;
      }
      final includeGhActions = topLevelResults['include-gh-actions'] as bool;

      if (includeGhActions) {
        output.write(ConfigEntry.ghActions);
      }

      final ignore = topLevelResults['ignore'] as List<String>;

      final ecosystems = topLevelResults['ecosystems'] as Iterable<String>;
      for (final ecosystem in PackageEcosystem.values) {
        if (ecosystems.isEmpty || (ecosystems.contains(ecosystem.name))) {
          final pubItems = ecosystem.getEntries(_logger, ignore);
          output.writeAll(pubItems.map((e) => e.toString()));
        }
      }

      _logger.write(output.toString());
      return ExitCode.success.code;
    } on ProcessException catch (e, stackTrace) {
      _logger
        ..err('Things went south')
        ..err(e.message)
        ..err('$stackTrace')
        ..info('')
        ..info(usage);
      return ExitCode.ioError.code;
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

enum PackageEcosystem {
  cargo('Cargo.toml'),
  npm('package.json'),
  pub(
    'pubspec.yaml',
    ['./.tmp', './brick/__brick__', './.dart_tool'],
  ),
  composer('composer.json');

  const PackageEcosystem(
    this.indexFile, [
    this.defaultIgnore = const [],
  ]);

  final String indexFile;
  final Iterable<String> defaultIgnore;

  Iterable<ConfigEntry> getEntries(
    Logger logger, [
    List<String> ignore = const [],
  ]) sync* {
    final effectiveIgnore = [...ignore, ...defaultIgnore];
    final result = Process.runSync(
      'find',
      [
        '.',
        '-name',
        indexFile,
      ],
      runInShell: true,
    );
    if (result.exitCode != 0) {
      throw ProcessException(
        'find',
        [
          '.',
          '-name',
          indexFile,
        ],
        'Things went south',
        result.exitCode,
      );
    }
    final stdout = result.stdout as String;
    final paths = stdout
        .split('\n')
        .where((element) => element.isNotEmpty)
        .map(path.dirname);

    pans:
    for (final pubPath in paths) {
      for (final parent in effectiveIgnore) {
        if (path.isWithin(parent, pubPath) || path.equals(parent, pubPath)) {
          continue pans;
        }
      }

      final convertedPath =
          pubPath.replaceAll('./', '/').replaceAll(RegExp(r'^\.$'), '/');

      yield ConfigEntry(
        ecosystemName: name,
        directory: convertedPath,
        schedule: const ConfigSchedule(interval: 'daily'),
      );
    }
  }
}

class ConfigEntry {
  const ConfigEntry({
    required this.ecosystemName,
    required this.directory,
    required this.schedule,
  });

  static const ghActions = ConfigEntry(
    ecosystemName: 'gh-actions',
    directory: '/',
    schedule: ConfigSchedule(interval: 'daily'),
  );

  final String ecosystemName;
  final String directory;
  final ConfigSchedule schedule;

  @override
  String toString() {
    return '''
  - package-ecosystem: "${ecosystemName}"
    directory: "$directory"
$schedule
''';
  }
}

class ConfigSchedule {
  const ConfigSchedule({
    required this.interval,
  });

  final String interval;

  @override
  String toString() {
    return '''
    schedule:
      interval: "daily"
''';
  }
}
