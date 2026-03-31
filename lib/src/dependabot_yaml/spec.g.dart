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
                  .map((e) => UpdateEntry.fromJson(e as Map))
                  .toList()),
          enableBetaEcosystems:
              $checkedConvert('enable-beta-ecosystems', (v) => v as bool?),
          ignore: $checkedConvert(
              'ignore',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Ignore.fromJson(e as Map))
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

Map<String, dynamic> _$DependabotSpecToJson(DependabotSpec instance) =>
    <String, dynamic>{
      'version': _$DependabotVersionEnumMap[instance.version]!,
      if (instance.enableBetaEcosystems case final value?)
        'enable-beta-ecosystems': value,
      if (_ignoresToJson(instance.ignore) case final value?) 'ignore': value,
      if (instance.registries case final value?) 'registries': value,
      'updates': _updatesToJson(instance.updates),
    };

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
          schedule:
              $checkedConvert('schedule', (v) => Schedule.fromJson(v as Map)),
          allow: $checkedConvert(
              'allow',
              (v) => (v as List<dynamic>?)
                  ?.map(
                      (e) => const _AllowedEntryConverter().fromJson(e as Map))
                  .toList()),
          assignees: $checkedConvert('assignees',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          commitMessage: $checkedConvert('commit-message',
              (v) => v == null ? null : CommitMessage.fromJson(v as Map)),
          groups: $checkedConvert(
              'groups',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e),
                  )),
          ignore: $checkedConvert(
              'ignore',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Ignore.fromJson(e as Map))
                  .toList()),
          insecureExternalCodeExecution: $checkedConvert(
              'insecure-external-code-execution',
              (v) => $enumDecodeNullable(
                  _$InsecureExternalCodeExecutionEnumMap, v)),
          labels: $checkedConvert('labels',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          milestone: $checkedConvert('milestone', (v) => (v as num?)?.toInt()),
          openPullRequestsLimit: $checkedConvert(
              'open-pull-requests-limit', (v) => (v as num?)?.toInt()),
          pullRequestBranchName: $checkedConvert(
              'pull-request-branch-name',
              (v) =>
                  v == null ? null : PullRequestBranchName.fromJson(v as Map)),
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

Map<String, dynamic> _$UpdateEntryToJson(UpdateEntry instance) =>
    <String, dynamic>{
      'package-ecosystem': instance.ecosystem,
      'directory': instance.directory,
      'schedule': instance.schedule.toJson(),
      if (instance.allow?.map(const _AllowedEntryConverter().toJson).toList()
          case final value?)
        'allow': value,
      if (instance.assignees?.toList() case final value?) 'assignees': value,
      if (instance.commitMessage?.toJson() case final value?)
        'commit-message': value,
      if (instance.groups case final value?) 'groups': value,
      if (_ignoresToJson(instance.ignore) case final value?) 'ignore': value,
      if (_$InsecureExternalCodeExecutionEnumMap[
              instance.insecureExternalCodeExecution]
          case final value?)
        'insecure-external-code-execution': value,
      if (instance.labels?.toList() case final value?) 'labels': value,
      if (instance.milestone case final value?) 'milestone': value,
      if (instance.openPullRequestsLimit case final value?)
        'open-pull-requests-limit': value,
      if (instance.pullRequestBranchName?.toJson() case final value?)
        'pull-request-branch-name': value,
      if (_$RebaseStrategyEnumMap[instance.rebaseStrategy] case final value?)
        'rebase-strategy': value,
      if (instance.registries case final value?) 'registries': value,
      if (instance.reviewers case final value?) 'reviewers': value,
      if (instance.targetBranch case final value?) 'target-branch': value,
      if (instance.vendor case final value?) 'vendor': value,
      if (_$VersioningStrategyEnumMap[instance.versioningStrategy]
          case final value?)
        'versioning-strategy': value,
    };

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

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'interval': _$ScheduleIntervalEnumMap[instance.interval]!,
      if (_$ScheduleDayEnumMap[instance.day] case final value?) 'day': value,
      if (instance.time case final value?) 'time': value,
      if (instance.timezone case final value?) 'timezone': value,
    };

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
          include: $checkedConvert(
              'include',
              (v) =>
                  $enumDecodeNullable(_$CommitMessageIncludeEnumMap, v) ??
                  CommitMessageInclude.scope),
        );
        return val;
      },
      fieldKeyMap: const {'prefixDevelopment': 'prefix-development'},
    );

Map<String, dynamic> _$CommitMessageToJson(CommitMessage instance) =>
    <String, dynamic>{
      if (instance.prefix case final value?) 'prefix': value,
      if (instance.prefixDevelopment case final value?)
        'prefix-development': value,
      if (_$CommitMessageIncludeEnumMap[instance.include] case final value?)
        'include': value,
    };

const _$CommitMessageIncludeEnumMap = {
  CommitMessageInclude.scope: 'scope',
};

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

Map<String, dynamic> _$IgnoreToJson(Ignore instance) => <String, dynamic>{
      'dependency-name': instance.dependencyName,
      if (instance.versions case final value?) 'versions': value,
      if (instance.updateTypes?.map((e) => _$UpdateTypeEnumMap[e]!).toList()
          case final value?)
        'update-types': value,
    };

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
