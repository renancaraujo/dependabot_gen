import 'dart:io';

import 'package:dependabot_gen/src/command_runner.dart';
import 'package:dependabot_gen/src/commands/command_base.dart';
import 'package:dependabot_gen/src/version.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}
class UpdateCommand extends CommandBase with LoggerLevelOption {
  /// {@macro update_command}
  UpdateCommand({
    required super.logger,
    PubUpdater? pubUpdater,
  }) : _pubUpdater = pubUpdater ?? PubUpdater();

  final PubUpdater _pubUpdater;

  @override
  String get description => 'Updates this CLI.';

  /// The name of this command.
  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    final ret = await super.run();
    if (ret != null) {
      return ret;
    }

    final updateCheckProgress = logger.progress('Checking for updates');
    late final String latestVersion;
    try {
      latestVersion = await _pubUpdater.getLatestVersion(packageName);
    } catch (error) {
      updateCheckProgress.fail();
      logger.err('$error');
      return ExitCode.software.code;
    }
    updateCheckProgress.complete('Checked for updates');

    final isUpToDate = packageVersion == latestVersion;
    if (isUpToDate) {
      logger.info('CLI is already at the latest version.');
      return ExitCode.success.code;
    }

    final updateProgress = logger.progress('Updating to $latestVersion');

    late final ProcessResult result;
    try {
      result = await _pubUpdater.update(
        packageName: packageName,
        versionConstraint: latestVersion,
      );
    } catch (error) {
      updateProgress.fail();
      logger.err('$error');
      return ExitCode.software.code;
    }

    if (result.exitCode != ExitCode.success.code) {
      updateProgress.fail();
      logger.err('Error updating CLI: ${result.stderr}');
      return ExitCode.software.code;
    }

    updateProgress.complete('Updated to $latestVersion');

    return ExitCode.success.code;
  }
}
