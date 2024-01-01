import 'dart:io';

import 'package:args/command_runner.dart';
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
  }) : _logger = logger;

  @override
  String get description => '''
A command which creates a new dependabot.yaml file in the repository root.''';

  @override
  String get name => 'create';

  final Logger _logger;

  @override
  Future<int> run() async {
    final repoRoot = await getRepositoryRoot();
    

    final dependabotFile = getDependabotFile(repositoryRoot: repoRoot);

    _logger.info('Creating dependabot.yaml in ${dependabotFile.path}');




    
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

