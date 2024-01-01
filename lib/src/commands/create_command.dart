import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_finder/package_finder.dart';
import 'package:git/git.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

/// {@template create_command}
///
/// `depgen create` command which creates a new dependabot.yaml file.
/// {@endtemplate}
class CreateCommand extends Command<int> {
  /// {@macro create_command}
  CreateCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addMultiOption(
        'ecosystems',
        allowed: PackageEcosystem.values.map((e) => e.name),
        defaultsTo: PackageEcosystem.values.map((e) => e.name),
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: '''
Path to the repository root.If ommited, the command will search for the closest git repository root from the current working directory.''',
      );
  }

  @override
  String get description => '''
A command which creates a new dependabot.yaml file in the repository root.''';

  @override
  String get name => 'create';

  final Logger _logger;

  Future<Directory> _getRepositoryRoot() async {
    final path = argResults?['path'] as String?;

    if (path == null) {
      return _fetchRepositoryRoot();
    }

    return Directory(path);
  }

  List<PackageEcosystem> _getEcosystems() {
    final ecosystems = argResults?['ecosystems'] as List<String>;

    return ecosystems.map((e) {
      final found = PackageEcosystem.values.firstWhere(
        (element) => element.name == e,
        orElse: () => throw UsageException(
          'Could not find an ecosystem named "$e".',
          usage,
        ),
      );

      return found;
    }).toList();
  }

  @override
  Future<int> run() async {
    final repoRoot = await _getRepositoryRoot();

    final dependabotFile = getDependabotFile(repositoryRoot: repoRoot);

    _logger.info(
      'Creating dependabot.yaml in $repoRoot',
    );

    final ecosystems = _getEcosystems();

    final newEntries = ecosystems.fold(
      <UpdateEntry>[],
      (previousValue, element) {
        element.finder
            .findUpdateEntries(
              repoRoot: repoRoot,
              schedule: Schedule(
                interval: ScheduleInterval.daily,
              ),
            )
            .forEach(previousValue.add);

        return previousValue;
      },
    );

    final currentUpdates = [...dependabotFile.content.updates];
    final entriesToAdd = <UpdateEntry>[];
    for (final newEntry in newEntries) {
      final existingEntry = currentUpdates.where((element) {
        return element.directory == newEntry.directory &&
            element.ecosystem == newEntry.ecosystem;
      }).firstOrNull;

      if (existingEntry == null) {
        entriesToAdd.add(newEntry);
        _logger.success(
          'Added ${newEntry.ecosystem} entry for ${newEntry.directory}',
        );
      } else {
        _logger.info(
          '''
Entry for ${newEntry.ecosystem} already exists for ${newEntry.directory}''',
        );
        currentUpdates.remove(existingEntry);
        entriesToAdd.add(existingEntry);
      }
    }

    for (final entry in currentUpdates) {
      _logger.warn(
        'Removed ${entry.ecosystem} entry for ${entry.directory}',
        tag: '-',
      );
    }

    dependabotFile
        .copyWith(
          content: dependabotFile.content.copyWith(updates: entriesToAdd),
        )
        .writeToFile();

    _logger.info(
      'Finished creating dependabot.yaml in $repoRoot',
    );

    return ExitCode.success.code;
  }
}

Future<Directory> _fetchRepositoryRoot([
  String? path,
]) async {
  final current = p.absolute(path ?? Directory.current.path);

  final pr = await runGit(
    ['rev-parse', '--git-dir'],
    processWorkingDir: current,
  );

  final gitDirPath = (pr.stdout as String).trim();

  if (p.basename(gitDirPath) != '.git') {
    throw UsageException(
      'Could not find a git repository in the current directory.',
      'Run this command from a path within a git repository.',
    );
  }

  final pp = p.dirname(p.absolute(gitDirPath));

  return Directory(pp);
}
