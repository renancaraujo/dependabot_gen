import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
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
    argParser.addOption('path', abbr: 'p', help: '''
Path to the repository root.If ommited, the command will search for the closest git repository root from the current working directory.''');
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
      return getRepositoryRoot();
    }

    return Directory(path);
  }

  @override
  Future<int> run() async {
    final repoRoot = await _getRepositoryRoot();

    final dependabotFile = getDependabotFile(repositoryRoot: repoRoot);

    _logger.info(
      'Creating dependabot.yaml in ${jsonEncode(dependabotFile.toJson())}',
    );

    return ExitCode.success.code;
  }
}

Future<Directory> getRepositoryRoot([
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
