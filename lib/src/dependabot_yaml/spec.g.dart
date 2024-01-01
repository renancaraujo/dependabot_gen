// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DependabotSpec _$DependabotSpecFromJson(Map json) => $checkedCreate(
      'DependabotSpec',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const [
            'version',
            'updates',
            'enable-beta-ecosystems',
            'ignore',
            'registries'
          ],
          disallowNullValues: const [
            'enable-beta-ecosystems',
            'ignore',
            'registries'
          ],
        );
        final val = DependabotSpec(
          version: $checkedConvert(
              'version',
              (v) =>
                  $enumDecodeNullable(_$DependabotVersionEnumMap, v) ??
                  DependabotVersion.v2),
          updates: $checkedConvert(
              'updates',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      UpdateEntry.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          enableBetaEcosystems:
              $checkedConvert('enable-beta-ecosystems', (v) => v as bool?),
          ignore: $checkedConvert(
              'ignore',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      Ignore.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          registries: $checkedConvert(
              'registries',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
        );
        return val;
      },
      fieldKeyMap: const {'enableBetaEcosystems': 'enable-beta-ecosystems'},
    );

Map<String, dynamic> _$DependabotSpecToJson(DependabotSpec instance) {
  final val = <String, dynamic>{
    'version': _$DependabotVersionEnumMap[instance.version]!,
    'updates': _updatesToJson(instance.updates),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('enable-beta-ecosystems', instance.enableBetaEcosystems);
  writeNotNull('ignore', _ignoresToJson(instance.ignore));
  writeNotNull('registries', instance.registries);
  return val;
}

const _$DependabotVersionEnumMap = {
  DependabotVersion.v2: 2,
};

UpdateEntry _$UpdateEntryFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['package-ecosystem'],
    disallowNullValues: const [
      'allow',
      'assignees',
      'commit-message',
      'groups',
      'ignore',
      'insecure-external-code-execution',
      'labels',
      'milestone',
      'open-pull-requests-limit',
      'pull-request-branch-name',
      'rebase-strategy',
      'registries',
      'reviewers',
      'target-branch',
      'vendor',
      'versioning-strategy'
    ],
  );
  return UpdateEntry(
    directory: json['directory'] as String,
    allow: (json['allow'] as List<dynamic>?)
        ?.map((e) =>
            const AllowedEntryConverter().fromJson(e as Map<String, dynamic>))
        .toList(),
    assignees:
        (json['assignees'] as List<dynamic>?)?.map((e) => e as String).toList(),
    commitMessage: json['commit-message'] == null
        ? null
        : CommitMessage.fromJson(
            Map<String, dynamic>.from(json['commit-message'] as Map)),
    groups: (json['groups'] as Map?)?.map(
      (k, e) => MapEntry(k as String, e),
    ),
    ignore: (json['ignore'] as List<dynamic>?)
        ?.map((e) => Ignore.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    insecureExternalCodeExecution:
        json['insecure-external-code-execution'] as String?,
    labels:
        (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList(),
    milestone: json['milestone'] as int?,
    openPullRequestsLimit: json['open-pull-requests-limit'] as int?,
    ecosystem: json['package-ecosystem'] as String,
    pullRequestBranchName: json['pull-request-branch-name'] == null
        ? null
        : PullRequestBranchName.fromJson(
            Map<String, dynamic>.from(json['pull-request-branch-name'] as Map)),
    rebaseStrategy:
        $enumDecodeNullable(_$RebaseStrategyEnumMap, json['rebase-strategy']),
    registries: (json['registries'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    reviewers: json['reviewers'] as String?,
    schedule:
        Schedule.fromJson(Map<String, dynamic>.from(json['schedule'] as Map)),
    targetBranch: json['target-branch'] as String?,
    vendor: json['vendor'] as bool?,
    versioningStrategy: $enumDecodeNullable(
        _$VersioningStrategyEnumMap, json['versioning-strategy']),
  );
}

Map<String, dynamic> _$UpdateEntryToJson(UpdateEntry instance) {
  final val = <String, dynamic>{
    'directory': instance.directory,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('allow',
      instance.allow?.map(const AllowedEntryConverter().toJson).toList());
  writeNotNull('assignees', instance.assignees);
  writeNotNull('commit-message', instance.commitMessage);
  writeNotNull('groups', instance.groups);
  writeNotNull('ignore', _ignoresToJson(instance.ignore));
  writeNotNull('insecure-external-code-execution',
      instance.insecureExternalCodeExecution);
  writeNotNull('labels', instance.labels);
  writeNotNull('milestone', instance.milestone);
  writeNotNull('open-pull-requests-limit', instance.openPullRequestsLimit);
  val['package-ecosystem'] = instance.ecosystem;
  writeNotNull('pull-request-branch-name', instance.pullRequestBranchName);
  writeNotNull(
      'rebase-strategy', _$RebaseStrategyEnumMap[instance.rebaseStrategy]);
  writeNotNull('registries', instance.registries);
  writeNotNull('reviewers', instance.reviewers);
  val['schedule'] = instance.schedule;
  writeNotNull('target-branch', instance.targetBranch);
  writeNotNull('vendor', instance.vendor);
  writeNotNull('versioning-strategy',
      _$VersioningStrategyEnumMap[instance.versioningStrategy]);
  return val;
}

const _$RebaseStrategyEnumMap = {
  RebaseStrategy.auto: 'auto',
  RebaseStrategy.disabled: 'disabled',
};

const _$VersioningStrategyEnumMap = {
  VersioningStrategy.auto: 'auto',
  VersioningStrategy.increase: 'increase',
  VersioningStrategy.increaseIfNecessary: 'increase-if-necessary',
  VersioningStrategy.lockfileOnly: 'lockfile-only',
  VersioningStrategy.widen: 'widen',
};

Schedule _$ScheduleFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['interval'],
    disallowNullValues: const ['day', 'time', 'timezone'],
  );
  return Schedule(
    interval: $enumDecode(_$ScheduleIntervalEnumMap, json['interval']),
    day: $enumDecodeNullable(_$ScheduleDayEnumMap, json['day']),
    time: json['time'] as String?,
    timezone: json['timezone'] as String?,
  );
}

Map<String, dynamic> _$ScheduleToJson(Schedule instance) {
  final val = <String, dynamic>{
    'interval': _$ScheduleIntervalEnumMap[instance.interval]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('day', _$ScheduleDayEnumMap[instance.day]);
  writeNotNull('time', instance.time);
  writeNotNull('timezone', instance.timezone);
  return val;
}

const _$ScheduleIntervalEnumMap = {
  ScheduleInterval.daily: 'daily',
  ScheduleInterval.weekly: 'weekly',
  ScheduleInterval.monthly: 'monthly',
};

const _$ScheduleDayEnumMap = {
  ScheduleDay.monday: 'monday',
  ScheduleDay.tuesday: 'tuesday',
  ScheduleDay.wednesday: 'wednesday',
  ScheduleDay.thursday: 'thursday',
  ScheduleDay.friday: 'friday',
  ScheduleDay.saturday: 'saturday',
  ScheduleDay.sunday: 'sunday',
};

AllowDependency _$AllowDependencyFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['dependency-name'],
  );
  return AllowDependency(
    name: json['dependency-name'] as String,
  );
}

Map<String, dynamic> _$AllowDependencyToJson(AllowDependency instance) =>
    <String, dynamic>{
      'dependency-name': instance.name,
    };

AllowDependencyType _$AllowDependencyTypeFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['dependency-type'],
  );
  return AllowDependencyType(
    dependencyType: json['dependency-type'] as String,
  );
}

Map<String, dynamic> _$AllowDependencyTypeToJson(
        AllowDependencyType instance) =>
    <String, dynamic>{
      'dependency-type': instance.dependencyType,
    };

CommitMessage _$CommitMessageFromJson(Map json) {
  $checkKeys(
    json,
    disallowNullValues: const ['prefix', 'prefix-development', 'include'],
  );
  return CommitMessage(
    prefix: json['prefix'] as String?,
    prefixDevelopment: json['prefix-development'] as String?,
    include: json['include'] as String? ?? 'scope',
  );
}

Map<String, dynamic> _$CommitMessageToJson(CommitMessage instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prefix', instance.prefix);
  writeNotNull('prefix-development', instance.prefixDevelopment);
  writeNotNull('include', instance.include);
  return val;
}

Ignore _$IgnoreFromJson(Map json) {
  $checkKeys(
    json,
    requiredKeys: const ['dependency-name'],
    disallowNullValues: const ['versions', 'update-types'],
  );
  return Ignore(
    dependencyName: json['dependency-name'] as String,
    versions:
        (json['versions'] as List<dynamic>?)?.map((e) => e as String).toList(),
    updateTypes: (json['update-types'] as List<dynamic>?)
        ?.map((e) => $enumDecode(_$UpdateTypeEnumMap, e))
        .toList(),
  );
}

Map<String, dynamic> _$IgnoreToJson(Ignore instance) {
  final val = <String, dynamic>{
    'dependency-name': instance.dependencyName,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('versions', instance.versions);
  writeNotNull('update-types',
      instance.updateTypes?.map((e) => _$UpdateTypeEnumMap[e]!).toList());
  return val;
}

const _$UpdateTypeEnumMap = {
  UpdateType.major: 'version-update:semver-major',
  UpdateType.minor: 'version-update:semver-minor',
  UpdateType.patch: 'version-update:semver-patch',
};

PullRequestBranchName _$PullRequestBranchNameFromJson(Map json) =>
    PullRequestBranchName(
      separator: json['separator'] as String,
    );

Map<String, dynamic> _$PullRequestBranchNameToJson(
        PullRequestBranchName instance) =>
    <String, dynamic>{
      'separator': instance.separator,
    };
