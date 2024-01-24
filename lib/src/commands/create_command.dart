import 'package:collection/collection.dart';
import 'package:dependabot_gen/src/commands/command_base.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:dependabot_gen/src/package_ecosystem/package_ecosystem.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template create_command}
///
/// `depgen create` command which creates a new dependabot.yaml file.
/// {@endtemplate}
class CreateCommand extends CommandBase
    with
        EcosystemsOption,
        LoggerLevelOption,
        ScheduleOption,
        TargetBranchOption,
        LabelsOption,
        MilestoneOption,
        IgnorePathsOption,
        RepositoryRootOption {
  /// {@macro create_command}
  CreateCommand({
    required super.logger,
  });

  @override
  String get description => '''
Create or update the dependabot.yaml file in a repository. 
Will keep existing entries and add new ones for possibly uncovered packages.
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

    final dependabotFile = DependabotFile.fromRepositoryRoot(repoRoot);

    logger.info(
      'Creating dependabot.yaml in ${dependabotFile.path}',
    );

    final newEntries = ecosystems.fold(
      <UpdateEntry>[],
      (previousValue, ecosystem) {
        ecosystem
            .findUpdateEntries(
              repoRoot: repoRoot,
              schedule: schedule,
              targetBranch: targetBranch,
              labels: labels,
              milestone: milestone,
              ignoreFinding: ignorePaths,
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

    for (final entry in currentUpdates) {
      final isUnknownEcoststem =
          !PackageEcosystem.values.map((e) => e.name).contains(entry.ecosystem);

      final wasItFound = newEntries.firstWhereOrNull((element) {
            return element.directory == entry.directory &&
                element.ecosystem == entry.ecosystem;
          }) !=
          null;

      if (isUnknownEcoststem || wasItFound) {
        logger.info(
          'Preserved ${entry.ecosystem} entry for ${entry.directory}',
        );
        continue;
      }

      dependabotFile.removeUpdateEntry(
        ecosystem: entry.ecosystem,
        directory: entry.directory,
      );
      logger.info(
        yellow.wrap('Removed ${entry.ecosystem} entry for ${entry.directory}'),
      );
    }

    dependabotFile.saveToFile();

    logger.info('Finished creating dependabot.yaml in ${dependabotFile.path}');

    return ExitCode.success.code;
  }
}
