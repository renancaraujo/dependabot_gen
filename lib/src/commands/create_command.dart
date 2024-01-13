import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
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
        abbr: 'e',
        allowed: PackageEcosystem.values.map((e) => e.name),
        defaultsTo: PackageEcosystem.values.map((e) => e.name),
        help: 'The package ecosystems to update in the dependabot.yaml file.',
      )
      ..addMultiOption(
        'ignore-paths',
        abbr: 'i',
        help:
            'Paths to ignore when searching for packages. Example: "__brick__/**"',
      )
      ..addOption(
        'repo-root',
        abbr: 'r',
        help: '''
Path to the repository root. If ommited, the command will search for the closest git repository root from the current working directory.''',
      )
      ..addOption(
        'schedule-interval',
        abbr: 'I',
        allowed: ScheduleInterval.values.map((e) => e.name),
        defaultsTo: ScheduleInterval.weekly.name,
        help: 'The interval to check for updates on new update entries '
            '(does not affect existing ones).',
      )
      ..addOption(
        'target-branch',
        help: 'The target branch to create pull requests against.',
      )
      ..addMultiOption(
        'labels',
        help: 'Labels to add to the pull requests.',
      )
      ..addOption(
        'milestone',
        help: 'The milestone to add to the pull requests. Must be a number.',
      )
      ..addFlag(
        'silent',
        abbr: 'S',
        help: 'Silences all output.',
      )
      ..addFlag(
        'verbose',
        abbr: 'V',
        help: 'Verbose output.',
      );
  }

  @override
  String get description => '''
Create or updates the dependabot.yaml file in the current repository. 
Will keep existing entries and add new ones if needed.
''';

  @override
  String get name => 'create';

  final Logger _logger;

  Future<Directory> _getRepositoryRoot() async {
    final path = argResults!['repo-root'] as String?;

    if (path == null) {
      return _fetchRepositoryRoot();
    }

    return Directory(path);
  }

  List<PackageEcosystem> _getEcosystems() {
    final ecosystems = argResults!['ecosystems'] as List<String>;

    return ecosystems
        .map(
          (e) => PackageEcosystem.values.firstWhere(
            (element) => element.name == e,
          ),
        )
        .toList();
  }

  Level _getLogLevel() {
    final silent = argResults!['silent'] as bool;
    final verbose = argResults!['verbose'] as bool;

    if (verbose && silent) {
      throw UsageException(
        'Both --verbose and --silent were provided. '
        "Its like asking for a hot ice cube. Just doesn't work, does it?",
        usage,
      );
    }

    if (verbose) {
      return Level.verbose;
    }
    if (silent) {
      return Level.quiet;
    }

    return Level.info;
  }

  Schedule _getSchedule() {
    final interval = argResults!['schedule-interval'] as String;

    final intervalSchedule = ScheduleInterval.values
        .firstWhere((element) => element.name == interval);

    return Schedule(
      interval: intervalSchedule,
    );
  }

  Set<String>? _getIgnorePaths() {
    final ignorePaths = argResults!['ignore-paths'] as List<String>;

    if (ignorePaths.isEmpty) {
      return null;
    }

    return ignorePaths.toSet();
  }

  String? _getTargetBranch() {
    final targetBranch = argResults!['target-branch'] as String?;

    return targetBranch;
  }

  Set<String>? _getLabels() {
    final labels = argResults!['labels'] as List<String>;

    if (labels.isEmpty) {
      return null;
    }

    return labels.toSet();
  }

  int? _getMilestone() {
    final milestoneRaw = argResults!['milestone'] as String?;

    final milestone = int.tryParse(milestoneRaw ?? '');

    return milestone;
  }

  @override
  Future<int> run() async {
    _logger.level = _getLogLevel();

    final repoRoot = await _getRepositoryRoot();

    final dependabotFile = getDependabotFile(repositoryRoot: repoRoot);

    _logger.info(
      'Creating dependabot.yaml in ${dependabotFile.path}}',
    );

    final ecosystems = _getEcosystems();

    final newEntries = ecosystems.fold(
      <UpdateEntry>[],
      (previousValue, element) {
        element.finder
            .findUpdateEntries(
              repoRoot: repoRoot,
              schedule: _getSchedule(),
              targetBranch: _getTargetBranch(),
              labels: _getLabels(),
              milestone: _getMilestone(),
              ignoreFinding: _getIgnorePaths(),
            )
            .forEach(previousValue.add);

        return previousValue;
      },
    );

    final currentUpdates = dependabotFile.updates;

    for (final newEntry in newEntries) {
      final entryExists = currentUpdates.firstWhereOrNull((element) {
            return element.directory == newEntry.directory &&
                element.ecosystem == newEntry.ecosystem;
          }) !=
          null;

      if (entryExists) {
        _logger.info(
          '''
Entry for ${newEntry.ecosystem} already exists for ${newEntry.directory}''',
        );
      } else {
        _logger.success(
          'Added ${newEntry.ecosystem} entry for ${newEntry.directory}',
        );
        dependabotFile.addUpdateEntry(newEntry);
      }
    }

    for (final entry in currentUpdates) {
      var dir = entry.directory;
      if (dir.startsWith('/')) {
        dir = dir.substring(1);
      }
      final exists = Directory(p.join(repoRoot.path, dir)).existsSync();

      if (exists) {
        _logger.info(
          'Preserved ${entry.ecosystem} entry for ${entry.directory}',
        );
        continue;
      }

      dependabotFile.removeUpdateEntry(entry);
      _logger.warn(
        'Removed ${entry.ecosystem} entry for ${entry.directory}',
        tag: '-',
      );
    }

    dependabotFile.commitChanges();

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
