import 'package:collection/collection.dart';
import 'package:dependabot_gen/src/commands/commands.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:mason_logger/mason_logger.dart';

/// `depgen diagnose` command which verifies the current dependabot setup
/// for potential issues.
class DiagnoseCommand extends CommandBase
    with
        EcosystemsOption,
        LoggerLevelOption,
        IgnorePathsOption,
        RepositoryRootOption {
  /// Creates a [DiagnoseCommand]
  DiagnoseCommand({
    required super.logger,
  });

  @override
  String get description => 'Verify the current dependabot setup for potential '
      'issues, doesnt make and modifications';

  @override
  String get name => 'diagnose';

  @override
  Future<int> run() async {
    final ret = await super.run();
    if (ret != null) {
      return ret;
    }

    final repoRoot = await getRepositoryRoot();

    final DependabotFile dependabotFile;
    try {
      dependabotFile = DependabotFile.fromRepositoryRoot(repoRoot);
    } on DependabotFileParsingException catch (e) {
      logger
        ..err('Error on parsing dependendabot file on ${e.filePath}')
        ..err('Details: ${e.message}');
      return ExitCode.unavailable.code;
    }

    logger
      ..detail(
        'Dependadot file config in ${dependabotFile.path}',
      )
      ..detail(
        'This command will search for packages under '
        '${repoRoot.path} for the following package ecosystems: '
        '${ecosystems.join(', ')}',
      );

    var violationFound = false;

    void fail(String message) {
      violationFound = true;
      logger.warn(tag: 'FAIL', message);
    }

    final newEntriesInfo = ecosystems.fold(
      <UpdateEntryInfo>[],
      (previousValue, ecosystem) {
        ecosystem
            .findUpdateEntries(
              repoRoot: repoRoot,
              ignoreFinding: ignorePaths,
            )
            .forEach(previousValue.add);

        return previousValue;
      },
    );

    final currentUpdates = dependabotFile.updates
        .whereNot((element) => element == kDummyEntry)
        .toList();

    final unnatendedEntries = [...newEntriesInfo]..removeWhere((newEntry) {
        return currentUpdates.firstWhereOrNull(
              (element) =>
                  element.directory == newEntry.directory &&
                  element.ecosystem == newEntry.ecosystem,
            ) !=
            null;
      });

    if (unnatendedEntries.isNotEmpty) {
      fail('''
Missing entries for packages on (ecosystem:path):
${unnatendedEntries.map((e) => '  - ${e.ecosystem}:${e.directory}\n')}''');
    }

    final updatesThatShouldNotBeHere = [...currentUpdates]
      ..removeWhere((currentEntry) {
        final isUnknownEcoststem =
            !PackageEcosystem.isKnownEcosystem(currentEntry.ecosystem);

        if (isUnknownEcoststem) {
          logger.detail(
            'Even though ${currentEntry.ecosystem} is unkown '
            'by ${runner!.executableName}, do not claim it as a fail.',
          );
        }

        final wasItFound = newEntriesInfo.firstWhereOrNull((element) {
              return element.directory == currentEntry.directory &&
                  element.ecosystem == currentEntry.ecosystem;
            }) !=
            null;

        return isUnknownEcoststem || wasItFound;
      });

    if (updatesThatShouldNotBeHere.isNotEmpty) {
      fail('''
Some existing update entries on dependabot seem to point to wrong locations (ecosystem:path):
${updatesThatShouldNotBeHere.map((e) => '  - ${e.ecosystem}:${e.directory}\n')}''');
    }

    return violationFound ? ExitCode.data.code : ExitCode.success.code;
  }
}
