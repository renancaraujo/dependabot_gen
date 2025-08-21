import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_completion/cli_completion.dart';
import 'package:dependabot_gen/src/commands/commands.dart';
import 'package:dependabot_gen/src/version.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:pub_updater/pub_updater.dart';

/// The name of the package.
const packageName = 'dependabot_gen';

/// The description of the package.
const description = 'Keep your dependabot.yaml up to date';

/// {@template dependabot_gen_command_runner}
/// A [CommandRunner] for the depgen CLI.
///
/// ```sh
/// $ depgen --version
/// ```
/// {@endtemplate}
class DependabotGenCommandRunner extends CompletionCommandRunner<int?> {
  /// {@macro dependabot_gen_command_runner}
  DependabotGenCommandRunner({
    required String executableName,
    Logger? logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger ?? Logger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super(executableName, description) {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version.',
    );

    // Add sub commands
    addCommand(CreateCommand(logger: _logger));
    addCommand(DiagnoseCommand(logger: _logger));
    addCommand(UpdateCommand(logger: _logger, pubUpdater: _pubUpdater));
  }

  @override
  void printUsage() => _logger.info(usage);

  final Logger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      return await runCommand(topLevelResults) ?? ExitCode.success.code;
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
    } on Exception catch (e, stackTrace) {
      _logger
        ..err('Unknown Error. This is likely a bug on $executableName.')
        ..info(
          'Please, file an issue on ${link(uri: issuesUri)} with the '
          'information below:',
        )
        ..info('Error message: $e')
        ..info('')
        ..info('$stackTrace');
      return ExitCode.software.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    // Fast track completion command
    if (topLevelResults.command?.name == 'completion') {
      await super.runCommand(topLevelResults);
      return ExitCode.success.code;
    }

    // Run the command or show version
    final int? exitCode;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    // Check for updates
    if (topLevelResults.command?.name != UpdateCommand.commandName) {
      await _checkForUpdates();
    }

    return exitCode;
  }

  /// Checks if the current version (set by the build runner on the
  /// version.dart file) is the most recent one. If not, show a prompt to the
  /// user.
  Future<void> _checkForUpdates() async {
    try {
      final latestVersion = await _pubUpdater.getLatestVersion(packageName);
      final isUpToDate = packageVersion == latestVersion;
      if (!isUpToDate) {
        _logger
          ..info('')
          ..info(
            '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(packageVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('$executableName update')} to update''',
          );
      }
    } on Exception catch (_) {}
  }
}

/// URI where people can report when things go south.
final Uri issuesUri = Uri.parse(
  'https://github.com/renancaraujo/dependabot_gen/issues/new/choose',
);
