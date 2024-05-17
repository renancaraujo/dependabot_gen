import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:git/git.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Typedef for [Process.runSync].
typedef ProcessRunSync = ProcessResult Function(
  String executable,
  List<String> arguments,
);

/// Default [ProcessRunSync]
ProcessResult defaultRunProcess(
  String executable,
  List<String> arguments,
) =>
    Process.runSync(executable, arguments);

/// {@template mixins_command}
/// A subclass of [Command] that allows usages of mixins to add options.
/// {@endtemplate}
abstract class CommandBase extends Command<int?> {
  /// {@macro mixins_command}
  CommandBase({
    required Logger logger,
    @visibleForTesting ProcessRunSync runProcess = defaultRunProcess,
  })  : _logger = logger,
        _runProcess = runProcess {
    addOptions();
  }

  /// Adds options to the command.
  @mustCallSuper
  @protected
  void addOptions() {}

  final Logger _logger;

  final ProcessRunSync _runProcess;

  /// The [Logger] for this command.
  Logger get logger => _logger;

  @override
  void printUsage() => _logger.info(usage);

  @mustCallSuper
  @override
  Future<int?> run() async {
    final result = _runProcess('git', ['--version']);

    if (result.exitCode != 0) {
      _logger.err(
        'Git is not installed or not in the PATH, make sure git available in '
        'your PATH.',
      );
      return ExitCode.unavailable.code;
    }

    return null;
  }
}

/// Adds the `--silent` and `--verbose` options to the command.
///
/// Get the log level with [_logLevel].
mixin LoggerLevelOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser
      ..addFlag(
        'silent',
        abbr: 'S',
        help: 'Silences all output.',
        negatable: false,
      )
      ..addFlag(
        'verbose',
        abbr: 'V',
        help: 'Show verbose output.',
        negatable: false,
      );
  }

  /// Gets the [Level] for the logger.
  Level get _logLevel {
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

  @override
  Future<int?> run() async {
    final ret = await super.run();
    if (ret != null) {
      return ret;
    }
    logger.level = _logLevel;
    return null;
  }
}

/// Adds the `--schedule-interval` option to the command.
///
/// Get the [Schedule] with [schedule].
mixin ScheduleOption on CommandBase {
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

  /// Gets the [Schedule] for the command.
  Schedule get schedule {
    final interval = argResults!['schedule-interval'] as String;

    final intervalSchedule = ScheduleInterval.values
        .firstWhere((element) => element.name == interval);

    return Schedule(
      interval: intervalSchedule,
    );
  }
}

/// Adds the `--target-branch` option to the command.
mixin TargetBranchOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'target-branch',
      help: 'The target branch to create pull requests against.',
    );
  }

  /// Gets the target branch for the command.
  String? get targetBranch => argResults!['target-branch'] as String?;
}

/// Adds the `--ignore-paths` option to the command.
mixin IgnorePathsOption on CommandBase {
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

  /// Gets the paths to ignore for the command.
  Set<String>? get ignorePaths {
    final ignorePaths = argResults!['ignore-paths'] as List<String>;

    if (ignorePaths.isEmpty) {
      return null;
    }

    return ignorePaths.toSet();
  }
}

/// Adds the `--labels` option to the command.
mixin LabelsOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addMultiOption(
      'labels',
      help: 'Labels to add to the pull requests.',
    );
  }

  /// Gets the labels.
  Set<String>? get labels {
    final labels = argResults!['labels'] as List<String>;

    if (labels.isEmpty) {
      return null;
    }

    return labels.toSet();
  }
}

/// Adds the `--milestone` option to the command.
mixin MilestoneOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'milestone',
      help: 'The milestone to add to the pull requests. Must be a number.',
    );
  }

  /// Gets the milestone.
  int? get milestone {
    final milestoneRaw = argResults!['milestone'] as String?;

    final milestone = int.tryParse(milestoneRaw ?? '');

    return milestone;
  }
}

/// Adds the `--use-groups` flag to the command.
mixin GroupsOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addFlag(
      'use-groups',
      help: 'Use groups on update entries.',
      defaultsTo: true,
    );
  }

  /// Whether to use groups.
  bool get useGroups => argResults!['use-groups'] as bool;
}

/// Adds the `--ecosystems` option to the command.
mixin EcosystemsOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser
      ..addMultiOption(
        'ecosystems',
        abbr: 'e',
        allowed: PackageEcosystem.values.map((e) => e.name),
        defaultsTo: PackageEcosystem.values.map((e) => e.name),
        help: 'The package ecosystems to consider when searching for packages. '
            'Defaults to all available.',
      )
      ..addMultiOption(
        'ignore-ecosystems',
        allowed: PackageEcosystem.values.map((e) => e.name),
        defaultsTo: [],
        help: 'The package ecosystems to ignore when searching for packages. '
            'Defaults to none.',
      );
  }

  /// Gets the ecosystems.
  Set<PackageEcosystem> get ecosystems {
    final ecosystems = argResults!['ecosystems'] as List<String>;
    final ignoreEcosystems =
        (argResults!['ignore-ecosystems'] as List<String>).toSet();

    return ecosystems
        .map(
          (e) => PackageEcosystem.values.firstWhere(
            (element) => element.name == e,
          ),
        )
        .where((e) => !ignoreEcosystems.contains(e.name))
        .toSet();
  }
}

/// Adds the `--repo-root` option to the command.
mixin RepositoryRootOption on CommandBase {
  @override
  void addOptions() {
    super.addOptions();
    argParser.addOption(
      'repo-root',
      abbr: 'r',
      help: '''
Path to the repository root. If omitted, the command will search for the closest git repository root from the current working directory.''',
    );
  }

  /// Gets the repository root.
  Future<Directory> getRepositoryRoot() async {
    final path = argResults!['repo-root'] as String?;

    if (path == null) {
      return _fetchRepositoryRoot();
    }

    final dir = Directory(path);

    if (!dir.existsSync()) {
      throw UsageException(
        'The provided repository root does not exist.',
        'Make sure the path is correct and the directory exists.',
      );
    }

    return dir;
  }

  /// For testing purposes only, overrides the current working directory.
  @visibleForTesting
  String? testWorkingDir;

  /// For testing purposes only, gets the current working directory.
  @visibleForTesting
  String get workingDir => testWorkingDir ?? Directory.current.path;

  Future<Directory> _fetchRepositoryRoot() async {
    final current = p.absolute(workingDir);

    ProcessResult pr;

    try {
      pr = await runGit(
        ['rev-parse', '--git-dir'],
        processWorkingDir: current,
      );
    } on ProcessException catch (e) {
      if (e.message.contains('not a git repository')) {
        throw UsageException(
          'Could not find a git repository in the current directory.',
          'Run this command from a path within a git repository or specify the '
              '--repo-root option.',
        );
      }
      rethrow;
    }

    final gitDirPath = (pr.stdout as String).trim();
    if (p.basename(gitDirPath) != '.git') {}
    final pp = p.dirname(p.absolute(gitDirPath));

    return Directory(pp);
  }
}
