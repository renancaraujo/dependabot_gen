import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spec.g.dart';

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class DependabotSpec {
  DependabotSpec({
    required this.version,
    required this.updates,
    this.enableBetaEcosystems,
    this.ignore,
    this.registries,
  });

  factory DependabotSpec.fromJson(Map<String, dynamic> json) =>
      _$DependabotSpecFromJson(json);

  factory DependabotSpec.parse(String yaml, {Uri? sourceUri}) {
    return checkedYamlDecode(
      yaml,
      (m) {
        if (m == null) {
          throw CheckedFromJsonException(
            m ?? {},
            'DependabotSpec',
            'yaml',
            'Expected a Map<String, dynamic>, but got ${m.runtimeType}',
          );
        }
        return _$DependabotSpecFromJson(m);
      },
      sourceUrl: sourceUri,
    );
  }

  Map<String, dynamic> toJson() => _$DependabotSpecToJson(this);

  @JsonKey(defaultValue: DependabotVersion.v2)
  final DependabotVersion version;

  @JsonKey(disallowNullValue: true, name: 'enable-beta-ecosystems')
  final bool? enableBetaEcosystems;

  @JsonKey(disallowNullValue: true, toJson: _ignoresToJson)
  final List<Ignore>? ignore;

  @JsonKey(disallowNullValue: true)
  // TODO(renancaraujo): Add support for registries
  final Map<String, dynamic>? registries;

  @JsonKey(toJson: _updatesToJson)
  final List<UpdateEntry> updates;

  DependabotSpec copyWith({
    DependabotVersion? version,
    List<UpdateEntry>? updates,
  }) {
    return DependabotSpec(
      version: version ?? this.version,
      updates: updates ?? this.updates,
      enableBetaEcosystems: enableBetaEcosystems,
      ignore: ignore,
      registries: registries,
    );
  }
}

enum DependabotVersion {
  @JsonValue(2)
  v2,
}

List<dynamic> _updatesToJson(List<UpdateEntry> updates) {
  return updates.map((e) => e.toJson()).toList();
}

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class UpdateEntry {
  UpdateEntry({
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

  factory UpdateEntry.fromJson(Map<String, dynamic> json) =>
      _$UpdateEntryFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEntryToJson(this);

  final String directory;

  @JsonKey(disallowNullValue: true)
  @AllowedEntryConverter()
  final List<AllowEntry>? allow;

  @JsonKey(disallowNullValue: true)
  final List<String>? assignees;

  @JsonKey(disallowNullValue: true, name: 'commit-message')
  final CommitMessage? commitMessage;

  // TODO(renancaraujo): Add support for groups
  @JsonKey(disallowNullValue: true)
  final Map<String, dynamic>? groups;

  @JsonKey(disallowNullValue: true, toJson: _ignoresToJson)
  final List<Ignore>? ignore;

  @JsonKey(disallowNullValue: true, name: 'insecure-external-code-execution')
  final String? insecureExternalCodeExecution;

  @JsonKey(disallowNullValue: true)
  final List<String>? labels;

  @JsonKey(disallowNullValue: true)
  final int? milestone;

  @JsonKey(disallowNullValue: true, name: 'open-pull-requests-limit')
  final int? openPullRequestsLimit;

  @JsonKey(required: true, name: 'package-ecosystem')
  final String ecosystem;

  @JsonKey(disallowNullValue: true, name: 'pull-request-branch-name')
  final PullRequestBranchName? pullRequestBranchName;

  @JsonKey(disallowNullValue: true, name: 'rebase-strategy')
  final RebaseStrategy? rebaseStrategy;

  @JsonKey(disallowNullValue: true)
  final List<String>? registries;

  @JsonKey(disallowNullValue: true)
  final String? reviewers;

  final Schedule schedule;

  @JsonKey(disallowNullValue: true, name: 'target-branch')
  final String? targetBranch;

  @JsonKey(disallowNullValue: true)
  final bool? vendor;

  @JsonKey(disallowNullValue: true, name: 'versioning-strategy')
  final VersioningStrategy? versioningStrategy;
}

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class Schedule {
  Schedule({
    required this.interval,
    this.day,
    this.time,
    this.timezone,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  @JsonKey(required: true)
  final ScheduleInterval interval;

  @JsonKey(disallowNullValue: true)
  final ScheduleDay? day;

  @JsonKey(disallowNullValue: true)
  final String? time;

  @JsonKey(disallowNullValue: true)
  final String? timezone;
}

enum ScheduleInterval {
  daily,
  weekly,
  monthly,
}

enum ScheduleDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

sealed class AllowEntry {}

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class AllowDependency extends AllowEntry {
  AllowDependency({
    required this.name,
  });

  @JsonKey(required: true, name: 'dependency-name')
  final String name;
}

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class AllowDependencyType extends AllowEntry {
  AllowDependencyType({
    required this.dependencyType,
  });

  @JsonKey(required: true, name: 'dependency-type')
  final String dependencyType;
}

class AllowedEntryConverter
    implements JsonConverter<AllowEntry, Map<String, dynamic>> {
  const AllowedEntryConverter();

  @override
  AllowEntry fromJson(Map<String, dynamic> json) {
    if (json['dependency-name'] is String) {
      return _$AllowDependencyFromJson(json);
    }
    if (json['dependency-type'] is String) {
      return _$AllowDependencyTypeFromJson(json);
    }

    throw Exception('Unknown type for "allow": $json');
  }

  @override
  Map<String, dynamic> toJson(AllowEntry object) {
    return switch (object) {
      final AllowDependency dep => _$AllowDependencyToJson(dep),
      final AllowDependencyType depType => _$AllowDependencyTypeToJson(depType),
    };
  }
}

@JsonSerializable(
    anyMap: true,
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true)
class CommitMessage {
  CommitMessage({
    required this.prefix,
    required this.prefixDevelopment,
    required this.include,
  });

  factory CommitMessage.fromJson(Map<String, dynamic> json) =>
      _$CommitMessageFromJson(json);

  Map<String, dynamic> toJson() => _$CommitMessageToJson(this);

  @JsonKey(disallowNullValue: true)
  final String? prefix;

  @JsonKey(disallowNullValue: true, name: 'prefix-development')
  final String? prefixDevelopment;

  @JsonKey(defaultValue: 'scope', disallowNullValue: true)
  final String? include;
}

List<dynamic>? _ignoresToJson(List<Ignore>? ignore) {
  return ignore?.map((e) => e.toJson()).toList();
}

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class Ignore {
  Ignore({
    required this.dependencyName,
    required this.versions,
    required this.updateTypes,
  });

  factory Ignore.fromJson(Map<String, dynamic> json) => _$IgnoreFromJson(json);

  Map<String, dynamic> toJson() => _$IgnoreToJson(this);

  @JsonKey(required: true, name: 'dependency-name')
  final String dependencyName;

  @JsonKey(disallowNullValue: true)
  final List<String>? versions;

  @JsonKey(disallowNullValue: true, name: 'update-types')
  final List<UpdateType>? updateTypes;
}

enum UpdateType {
  @JsonValue('version-update:semver-major')
  major,
  @JsonValue('version-update:semver-minor')
  minor,
  @JsonValue('version-update:semver-patch')
  patch,
}

@JsonSerializable(
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
class PullRequestBranchName {
  PullRequestBranchName({required this.separator});

  factory PullRequestBranchName.fromJson(Map<String, dynamic> json) =>
      _$PullRequestBranchNameFromJson(json);

  Map<String, dynamic> toJson() => _$PullRequestBranchNameToJson(this);

  final String separator;
}

enum RebaseStrategy { auto, disabled }

enum VersioningStrategy {
  auto,
  increase,
  @JsonValue('increase-if-necessary')
  increaseIfNecessary,
  @JsonValue('lockfile-only')
  lockfileOnly,
  widen,
}
