// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_finder/package_finder.dart';
import 'package:git/git.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

abstract class MixinsCommand<T> extends Command<T> {
  MixinsCommand({
    required Logger logger,
  }) : _logger = logger {
    addOptions();
  }

  @mustCallSuper
  void addOptions() {}

  final Logger _logger;

  Logger get logger => _logger;
}

mixin LoggerLevelOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser
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

  Level getLogLevel() {
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
}

mixin ScheduleOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'schedule-interval',
      abbr: 'I',
      allowed: ScheduleInterval.values.map((e) => e.name),
      defaultsTo: ScheduleInterval.weekly.name,
      help: 'The interval to check for updates on new update entries '
          '(does not affect existing ones).',
    );
  }

  Schedule getSchedule() {
    final interval = argResults!['schedule-interval'] as String;

    final intervalSchedule = ScheduleInterval.values
        .firstWhere((element) => element.name == interval);

    return Schedule(
      interval: intervalSchedule,
    );
  }
}

mixin TargetBranchOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'target-branch',
      help: 'The target branch to create pull requests against.',
    );
  }

  String? getTargetBranch() {
    return argResults!['target-branch'] as String?;
  }
}

mixin IgnorePathsOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addMultiOption(
      'ignore-paths',
      abbr: 'i',
      help:
          'Paths to ignore when searching for packages. Example: "__brick__/**"',
    );
  }

  Set<String>? getIgnorePaths() {
    final ignorePaths = argResults!['ignore-paths'] as List<String>;

    if (ignorePaths.isEmpty) {
      return null;
    }

    return ignorePaths.toSet();
  }
}

mixin LabelsOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addMultiOption(
      'labels',
      help: 'Labels to add to the pull requests.',
    );
  }

  Set<String>? getLabels() {
    final labels = argResults!['labels'] as List<String>;

    if (labels.isEmpty) {
      return null;
    }

    return labels.toSet();
  }
}

mixin MilestoneOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'milestone',
      help: 'The milestone to add to the pull requests. Must be a number.',
    );
  }

  int? getMilestone() {
    final milestoneRaw = argResults!['milestone'] as String?;

    final milestone = int.tryParse(milestoneRaw ?? '');

    return milestone;
  }
}

mixin EcosystemsOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addMultiOption(
      'ecosystems',
      abbr: 'e',
      allowed: PackageEcosystem.values.map((e) => e.name),
      defaultsTo: PackageEcosystem.values.map((e) => e.name),
      help: 'The package ecosystems to update in the dependabot.yaml file.',
    );
  }

  Set<PackageEcosystem> getEcosystems() {
    final ecosystems = argResults!['ecosystems'] as List<String>;

    return ecosystems
        .map(
          (e) => PackageEcosystem.values.firstWhere(
            (element) => element.name == e,
          ),
        )
        .toSet();
  }
}

mixin RepositoryRootOption<T> on MixinsCommand<T> {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'repo-root',
      abbr: 'r',
      help: '''
Path to the repository root. If ommited, the command will search for the closest git repository root from the current working directory.''',
    );
  }

  Future<Directory> getRepositoryRoot() async {
    final path = argResults!['repo-root'] as String?;

    if (path == null) {
      return _fetchRepositoryRoot();
    }

    return Directory(path);
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
}
