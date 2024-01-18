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
            'enable-beta-ecosystems',
            'ignore',
            'registries',
            'updates'
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
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('enable-beta-ecosystems', instance.enableBetaEcosystems);
  writeNotNull('ignore', _ignoresToJson(instance.ignore));
  writeNotNull('registries', instance.registries);
  val['updates'] = _updatesToJson(instance.updates);
  return val;
}

const _$DependabotVersionEnumMap = {
  DependabotVersion.v2: 2,
};

UpdateEntry _$UpdateEntryFromJson(Map json) => $checkedCreate(
      'UpdateEntry',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const [
            'package-ecosystem',
            'directory',
            'schedule',
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
        final val = UpdateEntry(
          directory: $checkedConvert('directory', (v) => v as String),
          ecosystem: $checkedConvert('package-ecosystem', (v) => v as String),
          schedule: $checkedConvert('schedule',
              (v) => Schedule.fromJson(Map<String, dynamic>.from(v as Map))),
          allow: $checkedConvert(
              'allow',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => const _AllowedEntryConverter().fromJson(e as Map))
                  .toList()),
          assignees: $checkedConvert('assignees',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          commitMessage: $checkedConvert(
              'commit-message',
              (v) => v == null
                  ? null
                  : CommitMessage.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          groups: $checkedConvert(
              'groups',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
          ignore: $checkedConvert(
              'ignore',
              (v) => (v as List<dynamic>?)
                  ?.map((e) =>
                      Ignore.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          insecureExternalCodeExecution: $checkedConvert(
              'insecure-external-code-execution',
              (v) => $enumDecodeNullable(
                  _$InsecureExternalCodeExecutionEnumMap, v)),
          labels: $checkedConvert('labels',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          milestone: $checkedConvert('milestone', (v) => v as int?),
          openPullRequestsLimit:
              $checkedConvert('open-pull-requests-limit', (v) => v as int?),
          pullRequestBranchName: $checkedConvert(
              'pull-request-branch-name',
              (v) => v == null
                  ? null
                  : PullRequestBranchName.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          rebaseStrategy: $checkedConvert('rebase-strategy',
              (v) => $enumDecodeNullable(_$RebaseStrategyEnumMap, v)),
          registries: $checkedConvert('registries',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          reviewers: $checkedConvert('reviewers',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          targetBranch: $checkedConvert('target-branch', (v) => v as String?),
          vendor: $checkedConvert('vendor', (v) => v as bool?),
          versioningStrategy: $checkedConvert('versioning-strategy',
              (v) => $enumDecodeNullable(_$VersioningStrategyEnumMap, v)),
        );
        return val;
      },
      fieldKeyMap: const {
        'ecosystem': 'package-ecosystem',
        'commitMessage': 'commit-message',
        'insecureExternalCodeExecution': 'insecure-external-code-execution',
        'openPullRequestsLimit': 'open-pull-requests-limit',
        'pullRequestBranchName': 'pull-request-branch-name',
        'rebaseStrategy': 'rebase-strategy',
        'targetBranch': 'target-branch',
        'versioningStrategy': 'versioning-strategy'
      },
    );

Map<String, dynamic> _$UpdateEntryToJson(UpdateEntry instance) {
  final val = <String, dynamic>{
    'package-ecosystem': instance.ecosystem,
    'directory': instance.directory,
    'schedule': instance.schedule.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('allow',
      instance.allow?.map(const _AllowedEntryConverter().toJson).toList());
  writeNotNull('assignees', instance.assignees?.toList());
  writeNotNull('commit-message', instance.commitMessage?.toJson());
  writeNotNull('groups', instance.groups);
  writeNotNull('ignore', _ignoresToJson(instance.ignore));
  writeNotNull(
      'insecure-external-code-execution',
      _$InsecureExternalCodeExecutionEnumMap[
          instance.insecureExternalCodeExecution]);
  writeNotNull('labels', instance.labels?.toList());
  writeNotNull('milestone', instance.milestone);
  writeNotNull('open-pull-requests-limit', instance.openPullRequestsLimit);
  writeNotNull(
      'pull-request-branch-name', instance.pullRequestBranchName?.toJson());
  writeNotNull(
      'rebase-strategy', _$RebaseStrategyEnumMap[instance.rebaseStrategy]);
  writeNotNull('registries', instance.registries);
  writeNotNull('reviewers', instance.reviewers);
  writeNotNull('target-branch', instance.targetBranch);
  writeNotNull('vendor', instance.vendor);
  writeNotNull('versioning-strategy',
      _$VersioningStrategyEnumMap[instance.versioningStrategy]);
  return val;
}

const _$InsecureExternalCodeExecutionEnumMap = {
  InsecureExternalCodeExecution.allow: 'allow',
  InsecureExternalCodeExecution.deny: 'deny',
};

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

Schedule _$ScheduleFromJson(Map json) => $checkedCreate(
      'Schedule',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['interval', 'day', 'time', 'timezone'],
          requiredKeys: const ['interval'],
          disallowNullValues: const ['day', 'time', 'timezone'],
        );
        final val = Schedule(
          interval: $checkedConvert(
              'interval', (v) => $enumDecode(_$ScheduleIntervalEnumMap, v)),
          day: $checkedConvert(
              'day', (v) => $enumDecodeNullable(_$ScheduleDayEnumMap, v)),
          time: $checkedConvert('time', (v) => v as String?),
          timezone: $checkedConvert('timezone', (v) => v as String?),
        );
        return val;
      },
    );

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

AllowDependency _$AllowDependencyFromJson(Map json) => $checkedCreate(
      'AllowDependency',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['dependency-name'],
          requiredKeys: const ['dependency-name'],
        );
        final val = AllowDependency(
          name: $checkedConvert('dependency-name', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'name': 'dependency-name'},
    );

Map<String, dynamic> _$AllowDependencyToJson(AllowDependency instance) =>
    <String, dynamic>{
      'dependency-name': instance.name,
    };

AllowDependencyType _$AllowDependencyTypeFromJson(Map json) => $checkedCreate(
      'AllowDependencyType',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['dependency-type'],
          requiredKeys: const ['dependency-type'],
        );
        final val = AllowDependencyType(
          dependencyType:
              $checkedConvert('dependency-type', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'dependencyType': 'dependency-type'},
    );

Map<String, dynamic> _$AllowDependencyTypeToJson(
        AllowDependencyType instance) =>
    <String, dynamic>{
      'dependency-type': instance.dependencyType,
    };

CommitMessage _$CommitMessageFromJson(Map json) => $checkedCreate(
      'CommitMessage',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['prefix', 'prefix-development', 'include'],
          disallowNullValues: const ['prefix', 'prefix-development', 'include'],
        );
        final val = CommitMessage(
          prefix: $checkedConvert('prefix', (v) => v as String?),
          prefixDevelopment:
              $checkedConvert('prefix-development', (v) => v as String?),
          include: $checkedConvert('include', (v) => v as String? ?? 'scope'),
        );
        return val;
      },
      fieldKeyMap: const {'prefixDevelopment': 'prefix-development'},
    );

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

Ignore _$IgnoreFromJson(Map json) => $checkedCreate(
      'Ignore',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['dependency-name', 'versions', 'update-types'],
          requiredKeys: const ['dependency-name'],
          disallowNullValues: const ['versions', 'update-types'],
        );
        final val = Ignore(
          dependencyName:
              $checkedConvert('dependency-name', (v) => v as String),
          versions: $checkedConvert('versions',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          updateTypes: $checkedConvert(
              'update-types',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecode(_$UpdateTypeEnumMap, e))
                  .toList()),
        );
        return val;
      },
      fieldKeyMap: const {
        'dependencyName': 'dependency-name',
        'updateTypes': 'update-types'
      },
    );

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
    $checkedCreate(
      'PullRequestBranchName',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          allowedKeys: const ['separator'],
        );
        final val = PullRequestBranchName(
          separator: $checkedConvert('separator', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$PullRequestBranchNameToJson(
        PullRequestBranchName instance) =>
    <String, dynamic>{
      'separator': instance.separator,
    };
