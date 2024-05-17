import 'package:collection/collection.dart';
import 'package:dependabot_gen/src/commands/commands.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template create_command}
///
/// `depgen create` command which creates a new dependabot.yml file.
/// {@endtemplate}
class CreateCommand extends CommandBase
    with
        EcosystemsOption,
        LoggerLevelOption,
        ScheduleOption,
        TargetBranchOption,
        LabelsOption,
        MilestoneOption,
        GroupsOption,
        IgnorePathsOption,
        RepositoryRootOption {
  /// {@macro create_command}
  CreateCommand({
    required super.logger,
  });

  @override
  String get description => '''
Create or update the dependabot.yaml file in a repository. Will keep existing entries and add new ones for possibly uncovered packages.
''';

  @override
  String get name => 'create';

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
        ..err('Error on parsing dependabot file on ${e.filePath}')
        ..err('Details: ${e.message}')
        ..detail('Error: ${e.internalError.formattedMessage}');
      return ExitCode.unavailable.code;
    }

    logger
      ..info(
        'Dependabot file config in ${dependabotFile.path}',
      )
      ..detail(
        'This command will search for packages under '
        '${repoRoot.path} for the following package ecosystems: '
        '${ecosystems.map((e) => e.name).toList().join(', ')}',
      );

    final useGroups = this.useGroups;

    final newEntries = ecosystems.fold(
      <UpdateEntry>[],
      (previousValue, ecosystem) {
        ecosystem
            .findUpdateEntries(
              repoRoot: repoRoot,
              ignoreFinding: ignorePaths,
            )
            .map(
              (e) => UpdateEntry(
                directory: e.directory,
                ecosystem: e.ecosystem,
                schedule: schedule,
                targetBranch: targetBranch,
                labels: labels,
                milestone: milestone,
                groups: useGroups
                    ? {
                        e.groupName: const {
                          'patterns': ['*'],
                        },
                      }
                    : null,
              ),
            )
            .forEach(previousValue.add);

        return previousValue;
      },
    );

    final currentUpdates = dependabotFile.updates
        .whereNot((element) => element == kDummyEntry)
        .toList();

    for (final newEntry in newEntries) {
      final entryExists = currentUpdates.firstWhereOrNull((element) {
            return element.directory == newEntry.directory &&
                element.ecosystem == newEntry.ecosystem;
          }) !=
          null;

      if (entryExists) {
        logger.info(
          '''
Entry for ${newEntry.ecosystem} already exists for ${newEntry.directory}''',
        );
      } else {
        logger.success(
          'Added ${newEntry.ecosystem} entry for ${newEntry.directory}',
        );
        dependabotFile.addUpdateEntry(newEntry);
      }
    }

    for (final currentEntry in currentUpdates) {
      final isUnknownEcosystem =
          !PackageEcosystem.isKnownEcosystem(currentEntry.ecosystem);

      final wasItFound = newEntries.firstWhereOrNull((element) {
            return element.directory == currentEntry.directory &&
                element.ecosystem == currentEntry.ecosystem;
          }) !=
          null;

      if (isUnknownEcosystem || wasItFound) {
        logger.info(
          'Preserved ${currentEntry.ecosystem} entry for '
          '${currentEntry.directory}',
        );
        continue;
      }

      dependabotFile.removeUpdateEntry(
        ecosystem: currentEntry.ecosystem,
        directory: currentEntry.directory,
      );
      logger.info(
        yellow.wrap(
          'Removed ${currentEntry.ecosystem} entry for '
          '${currentEntry.directory}',
        ),
      );
    }

    dependabotFile.saveToFile();

    logger.info('Finished creating dependabot.yaml in ${dependabotFile.path}');

    return ExitCode.success.code;
  }
}
