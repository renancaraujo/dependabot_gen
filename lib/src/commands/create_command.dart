import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

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
    
    return ExitCode.success.code;
  }
}
