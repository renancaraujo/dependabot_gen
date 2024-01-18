import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spec.g.dart';

/// {@template dependabot_spec}
/// A representation of a dependabot.yaml file content.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class DependabotSpec extends Equatable {
  /// {@macro dependabot_spec}
  const DependabotSpec({
    required this.version,
    required this.updates,
    this.enableBetaEcosystems,
    this.ignore,
    this.registries,
  });

  /// Creates a new [DependabotSpec] from a JSON map.
  factory DependabotSpec.fromJson(Map<dynamic, dynamic> json) =>
      _$DependabotSpecFromJson(json);

  /// Converts this object to a JSON map.
  Map<dynamic, dynamic> toJson() => _$DependabotSpecToJson(this);

  /// The version of the dependabot spec.
  @JsonKey(defaultValue: DependabotVersion.v2)
  final DependabotVersion version;

  /// Enable ecosystems that have beta-level support.
  @JsonKey(disallowNullValue: true, name: 'enable-beta-ecosystems')
  final bool? enableBetaEcosystems;

  /// Ignore certain dependencies or versions
  @JsonKey(disallowNullValue: true, toJson: _ignoresToJson)
  final List<Ignore>? ignore;

  /// A map of registries to their configuration.
  @JsonKey(disallowNullValue: true)
  final Map<String, dynamic>? registries;

  /// Element for each one package manager that you want GitHub Dependabot to
  /// monitor for new versions.
  @JsonKey(toJson: _updatesToJson)
  final List<UpdateEntry> updates;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  DependabotSpec copyWith({
    required List<UpdateEntry> updates,
  }) {
    return DependabotSpec(
      version: version,
      updates: updates,
      enableBetaEcosystems: enableBetaEcosystems,
      ignore: ignore,
      registries: registries,
    );
  }

  @override
  List<Object?> get props => [
        version,
        updates,
        enableBetaEcosystems,
        ignore,
        registries,
      ];
}

/// The version of the dependabot spec.
enum DependabotVersion {
  /// Version 2 of the dependabot spec.
  @JsonValue(2)
  v2,
}

List<dynamic> _updatesToJson(List<UpdateEntry> updates) {
  return updates.map((e) => e.toJson()).toList();
}

/// {@template update_entry}
/// Element for each one package manager that GitHub Dependabot will
/// monitor for new versions.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class UpdateEntry extends Equatable {
  /// {@macro update_entry}
  const UpdateEntry({
    required this.directory,
    required this.ecosystem,
    required this.schedule,
    this.allow,
    this.assignees,
    this.commitMessage,
    this.groups,
    this.ignore,
    this.insecureExternalCodeExecution,
    this.labels,
    this.milestone,
    this.openPullRequestsLimit,
    this.pullRequestBranchName,
    this.rebaseStrategy,
    this.registries,
    this.reviewers,
    this.targetBranch,
    this.vendor,
    this.versioningStrategy,
  });

  /// Creates a new [UpdateEntry] from a JSON map.
  factory UpdateEntry.fromJson(Map<dynamic, dynamic> json) =>
      _$UpdateEntryFromJson(json);

  /// Converts this object to a JSON map.
  Map<dynamic, dynamic> toJson() => _$UpdateEntryToJson(this);

  /// The package manager to use.
  @JsonKey(required: true, name: 'package-ecosystem')
  final String ecosystem;

  /// The directory where the manifest file is located.
  final String directory;

  /// Schedule for Dependabot to update dependencies.
  final Schedule schedule;

  /// Customize which updates are allowed.
  @JsonKey(disallowNullValue: true)
  @_AllowedEntryConverter()
  final List<AllowEntry>? allow;

  /// Assignees to set on pull requests.
  @JsonKey(disallowNullValue: true)
  final Set<String>? assignees;

  /// Commit message preferences.
  @JsonKey(disallowNullValue: true, name: 'commit-message')
  final CommitMessage? commitMessage;

  /// Group updates for certain dependencies.
  @JsonKey(disallowNullValue: true)
  final Map<String, dynamic>? groups;

  /// Ignore certain dependencies or versions
  @JsonKey(disallowNullValue: true, toJson: _ignoresToJson)
  final List<Ignore>? ignore;

  /// Allow or deny code execution in manifest files
  @JsonKey(disallowNullValue: true, name: 'insecure-external-code-execution')
  final InsecureExternalCodeExecution? insecureExternalCodeExecution;

  /// Labels to set on pull requests.
  @JsonKey(disallowNullValue: true)
  final Set<String>? labels;

  /// Milestone to set on pull requests.
  @JsonKey(disallowNullValue: true)
  final int? milestone;

  /// Limit the number of open pull requests.
  @JsonKey(disallowNullValue: true, name: 'open-pull-requests-limit')
  final int? openPullRequestsLimit;

  /// Change separator for pull request branch names.
  @JsonKey(disallowNullValue: true, name: 'pull-request-branch-name')
  final PullRequestBranchName? pullRequestBranchName;

  /// Rebase strategy to use.
  @JsonKey(disallowNullValue: true, name: 'rebase-strategy')
  final RebaseStrategy? rebaseStrategy;

  /// Private registries that Dependabot can access
  @JsonKey(disallowNullValue: true)
  final List<String>? registries;

  /// Reviewers to request on pull requests.
  @JsonKey(disallowNullValue: true)
  final List<String>? reviewers;

  /// The branch to create pull requests against.
  @JsonKey(disallowNullValue: true, name: 'target-branch')
  final String? targetBranch;

  /// Raise pull requests to update vendored dependencies that are checked in
  /// to the repository
  @JsonKey(disallowNullValue: true)
  final bool? vendor;

  /// The strategy to use when updating versions.
  @JsonKey(disallowNullValue: true, name: 'versioning-strategy')
  final VersioningStrategy? versioningStrategy;

  @override
  List<Object?> get props => [
        ecosystem,
        directory,
        schedule,
        allow,
        assignees,
        commitMessage,
        groups,
        ignore,
        insecureExternalCodeExecution,
        labels,
        milestone,
        openPullRequestsLimit,
        pullRequestBranchName,
        rebaseStrategy,
        registries,
        reviewers,
        targetBranch,
        vendor,
        versioningStrategy,
      ];
}

/// {@template schedule}
/// Schedule for Dependabot to update dependencies.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class Schedule extends Equatable {
  /// {@macro schedule}
  const Schedule({
    required this.interval,
    this.day,
    this.time,
    this.timezone,
  });

  /// Creates a new [Schedule] from a JSON map.
  factory Schedule.fromJson(Map<dynamic, dynamic> json) =>
      _$ScheduleFromJson(json);

  /// Converts this object to a JSON map.
  Map<dynamic, dynamic> toJson() => _$ScheduleToJson(this);

  /// The interval to use.
  @JsonKey(required: true)
  final ScheduleInterval interval;

  /// Which day of the week to use.
  @JsonKey(disallowNullValue: true)
  final ScheduleDay? day;

  /// The time of day to use.
  @JsonKey(disallowNullValue: true)
  final String? time;

  /// The timezone to use.
  @JsonKey(disallowNullValue: true)
  final String? timezone;

  @override
  List<Object?> get props => [
        interval,
        day,
        time,
        timezone,
      ];
}

/// Defines the interval for a [Schedule].
enum ScheduleInterval {
  /// Check for updates daily.
  daily,

  /// Check for updates weekly.
  weekly,

  /// Check for updates monthly.
  monthly,
}

/// Defines the day of the week for a [Schedule].
enum ScheduleDay {
  /// Check for updates on Monday.
  monday,

  /// Check for updates on Tuesday.
  tuesday,

  /// Check for updates on Wednesday.
  wednesday,

  /// Check for updates on Thursday.
  thursday,

  /// Check for updates on Friday.
  friday,

  /// Check for updates on Saturday.
  saturday,

  /// Check for updates on Sunday.
  sunday,
}

/// Generic type for allowed entries to be used by [UpdateEntry.allow].
sealed class AllowEntry extends Equatable {
  const AllowEntry();
}

/// {@template allow_dependency}
/// Allow updates for a specific dependency.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class AllowDependency extends AllowEntry {
  /// {@macro allow_dependency}
  const AllowDependency({
    required this.name,
  });

  /// The name of the dependency to allow.
  @JsonKey(required: true, name: 'dependency-name')
  final String name;

  @override
  List<Object?> get props => [name];
}

/// {@template allow_dependency_type}
/// Allow updates for a specific dependency type.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class AllowDependencyType extends AllowEntry {
  /// {@macro allow_dependency_type}
  const AllowDependencyType({
    required this.dependencyType,
  });

  /// The type of the dependency to allow.
  @JsonKey(required: true, name: 'dependency-type')
  final String dependencyType;

  @override
  List<Object?> get props => [dependencyType];
}

class _AllowedEntryConverter
    implements JsonConverter<AllowEntry, Map<dynamic, dynamic>> {
  const _AllowedEntryConverter();

  @override
  AllowEntry fromJson(Map<dynamic, dynamic> json) {
    if (json['dependency-name'] is String) {
      return _$AllowDependencyFromJson(json);
    }
    if (json['dependency-type'] is String) {
      return _$AllowDependencyTypeFromJson(json);
    }

    throw Exception('Unknown type for "allow": $json');
  }

  @override
  Map<dynamic, dynamic> toJson(AllowEntry object) {
    return switch (object) {
      final AllowDependency dep => _$AllowDependencyToJson(dep),
      final AllowDependencyType depType => _$AllowDependencyTypeToJson(depType),
    };
  }
}

/// {@template commit_message}
/// Commit message preferences.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class CommitMessage extends Equatable {
  /// {@macro commit_message}
  const CommitMessage({
    required this.prefix,
    required this.prefixDevelopment,
    required this.include,
  });

  /// Creates a new [CommitMessage] from a JSON map.
  factory CommitMessage.fromJson(Map<dynamic, dynamic> json) =>
      _$CommitMessageFromJson(json);

  /// Converts this object to a JSON map.
  Map<dynamic, dynamic> toJson() => _$CommitMessageToJson(this);

  /// The prefix to use for commit messages.
  @JsonKey(disallowNullValue: true)
  final String? prefix;

  /// The prefix to use for commit messages for development dependencies.
  @JsonKey(disallowNullValue: true, name: 'prefix-development')
  final String? prefixDevelopment;

  /// The scope to use for commit messages.
  @JsonKey(defaultValue: 'scope', disallowNullValue: true)
  final String? include;

  @override
  List<Object?> get props => [
        prefix,
        prefixDevelopment,
        include,
      ];
}

List<dynamic>? _ignoresToJson(List<Ignore>? ignore) {
  return ignore?.map((e) => e.toJson()).toList();
}

/// {@template ignore}
/// Ignore certain dependencies or versions.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class Ignore extends Equatable {
  /// {@macro ignore}
  const Ignore({
    required this.dependencyName,
    required this.versions,
    required this.updateTypes,
  });

  /// Creates a new [Ignore] from a JSON map.
  factory Ignore.fromJson(Map<dynamic, dynamic> json) => _$IgnoreFromJson(json);

  /// Converts this object to a JSON map.`
  Map<dynamic, dynamic> toJson() => _$IgnoreToJson(this);

  /// The name of the dependency to ignore.
  @JsonKey(required: true, name: 'dependency-name')
  final String dependencyName;

  /// The versions of the dependency to ignore.
  @JsonKey(disallowNullValue: true)
  final List<String>? versions;

  /// The types of updates to ignore.
  @JsonKey(disallowNullValue: true, name: 'update-types')
  final List<UpdateType>? updateTypes;

  @override
  List<Object?> get props => [
        dependencyName,
        versions,
        updateTypes,
      ];
}

/// Types of updates to ignore.
enum UpdateType {
  /// Ignore major updates.
  @JsonValue('version-update:semver-major')
  major,

  /// Ignore minor updates.
  @JsonValue('version-update:semver-minor')
  minor,

  /// Ignore patch updates.
  @JsonValue('version-update:semver-patch')
  patch,
}

/// {@template pull_request_branch_name}
/// Change separator for pull request branch names.
/// {@endtemplate}
@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class PullRequestBranchName extends Equatable {
  /// {@macro pull_request_branch_name}
  const PullRequestBranchName({required this.separator});

  /// Creates a new [PullRequestBranchName] from a JSON map.
  factory PullRequestBranchName.fromJson(Map<dynamic, dynamic> json) =>
      _$PullRequestBranchNameFromJson(json);

  /// Converts this object to a JSON map.
  Map<dynamic, dynamic> toJson() => _$PullRequestBranchNameToJson(this);

  /// The separator to use.
  final String separator;

  @override
  List<Object?> get props => [
        separator,
      ];
}

/// Rebase strategy to use.
enum RebaseStrategy {
  /// Auto-rebase pull requests.
  auto,

  /// Do not rebase pull requests automatically.
  disabled,
}

/// The strategy to use when updating versions.
enum VersioningStrategy {
  /// Auto-detect the versioning strategy.
  auto,

  /// Use the lockfile only.
  increase,

  /// Increase the version if necessary.
  @JsonValue('increase-if-necessary')
  increaseIfNecessary,

  /// Use the lockfile only.
  @JsonValue('lockfile-only')
  lockfileOnly,

  /// Increase the version if necessary.
  widen,
}

/// Allow or deny code execution in manifest files.
enum InsecureExternalCodeExecution {
  /// Allow code execution in manifest files.
  @JsonValue('allow')
  allow,

  /// Deny code execution in manifest files.
  @JsonValue('deny')
  deny,
}
