import 'dart:io';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:meta/meta.dart';

import 'package:path/path.dart' as p;

enum PackageEcosystem {
  githubActions(PackageEcosystemFinder.githubActions),
  docker(PackageEcosystemFinder.docker),
  gitModules(PackageEcosystemFinder.gitModules),
  pub(PackageEcosystemFinder.pub),
  gomod(PackageEcosystemFinder.gomod),
  maven(PackageEcosystemFinder.maven),
  npm(PackageEcosystemFinder.npm),
  composer(PackageEcosystemFinder.composer),
  pip(PackageEcosystemFinder.pip),
  bundler(PackageEcosystemFinder.bundler),
  cargo(PackageEcosystemFinder.cargo),
  nuget(PackageEcosystemFinder.nuget),
  hex(PackageEcosystemFinder.hex),
  ;

  const PackageEcosystem(this.finder);

  final PackageEcosystemFinder finder;
}

abstract interface class PackageEcosystemFinder {
  static const pub = _ManifestPackageEcosystemFinder(
    ecosystem: 'pub',
    indexFiles: {
      'pubspec.yaml',
    },
  );

  static const gomod = _ManifestPackageEcosystemFinder(
    ecosystem: 'gomod',
    indexFiles: {
      'go.mod',
    },
  );

  static const maven = _ManifestPackageEcosystemFinder(
    ecosystem: 'maven',
    indexFiles: {
      'pom.xml',
    },
  );

  static const npm = _ManifestPackageEcosystemFinder(
    ecosystem: 'npm',
    indexFiles: {
      'package.json',
    },
  );

  static const composer = _ManifestPackageEcosystemFinder(
    ecosystem: 'composer',
    indexFiles: {
      'composer.json',
    },
  );

  static const pip = _ManifestPackageEcosystemFinder(
    ecosystem: 'pip',
    indexFiles: {
      'requirements.txt',
      'Pipfile',
      'pyproject.toml',
    },
  );

  static const bundler = _ManifestPackageEcosystemFinder(
    ecosystem: 'bundler',
    indexFiles: {
      'Gemfile',
    },
  );

  static const cargo = _ManifestPackageEcosystemFinder(
    ecosystem: 'cargo',
    indexFiles: {
      'Cargo.toml',
    },
  );

  static const nuget = _ManifestPackageEcosystemFinder(
    ecosystem: 'nuget',
    indexFiles: {
      '.nuspec',
      '.csproj',
    },
  );

  static const hex = _ManifestPackageEcosystemFinder(
    ecosystem: 'mix',
    indexFiles: {
      'mix.exs',
    },
  );

  static const githubActions = _HeuristicPackageEcosystemFinder(
    ecosystem: 'github-actions',
    directory: '/',
    repoHeuristics: _githubActionsHeuristics,
  );

  static const docker = _HeuristicPackageEcosystemFinder(
    ecosystem: 'docker',
    directory: '/',
    repoHeuristics: _dockerHeuristics,
  );

  static const gitModules = _HeuristicPackageEcosystemFinder(
    ecosystem: 'git-submodule',
    directory: '/',
    repoHeuristics: _gitmodulesHeuristics,
  );

  Iterable<UpdateEntry> findUpdateEntries({
    required Directory repoRoot,
    required Schedule schedule,
    Set<String> ignore = const {},
  });

  String get ecosystem;
}

bool _githubActionsHeuristics(Directory repoRoot) {
  final workflows = Directory(
    p.join(repoRoot.path, '.github', 'workflows'),
  );
  return workflows.existsSync();
}

bool _dockerHeuristics(Directory repoRoot) {
  final dockerfile = File(
    p.join(repoRoot.path, 'Dockerfile'),
  );
  return dockerfile.existsSync();
}

bool _gitmodulesHeuristics(Directory repoRoot) {
  final gitModules = File(
    p.join(repoRoot.path, '.gitmodules'),
  );
  return gitModules.existsSync();
}

class _HeuristicPackageEcosystemFinder implements PackageEcosystemFinder {
  const _HeuristicPackageEcosystemFinder({
    required this.ecosystem,
    required this.directory,
    required this.repoHeuristics,
  });

  @override
  final String ecosystem;

  final String directory;

  final bool Function(Directory repoRoot) repoHeuristics;

  @override
  Iterable<UpdateEntry> findUpdateEntries({
    required Directory repoRoot,
    required Schedule schedule,
    Set<String> ignore = const {},
  }) sync* {
    if (repoHeuristics(repoRoot)) {
      yield UpdateEntry(
        directory: '/',
        ecosystem: ecosystem,
        schedule: schedule,
      );
    }
  }
}

@immutable
class _ManifestPackageEcosystemFinder implements PackageEcosystemFinder {
  const _ManifestPackageEcosystemFinder({
    required this.indexFiles,
    required this.ecosystem,
  });

  @override
  final String ecosystem;

  final Set<String> indexFiles;

  @override
  Iterable<UpdateEntry> findUpdateEntries({
    required Directory repoRoot,
    required Schedule schedule,
    Set<String> ignore = const {},
  }) sync* {
    final paths = _findFilesRecursivelyOn(
      directory: repoRoot,
      withNames: indexFiles,
    ).where((element) => element.isNotIgnored()).map((e) => e.path);

    outer:
    for (final manifestPath in paths) {
      for (final parent in ignore) {
        if (p.isWithin(parent, manifestPath) ||
            p.equals(parent, manifestPath)) {
          continue outer;
        }
      }

      final dirPath = p.relative(
        p.dirname(manifestPath),
        from: repoRoot.path,
      );

      // replace '.' and './' with '/' (only if it's at the beginning)
      final convertedPath = dirPath.replaceFirst(RegExp(r'^\.\/?'), '/');

      yield UpdateEntry(
        directory: convertedPath,
        ecosystem: ecosystem,
        schedule: schedule,
      );
    }
  }
}

List<File> _findFilesRecursivelyOn({
  required Directory directory,
  required Set<String> withNames,
}) {
  final result = <File>[];
  for (final entity in directory.absolute.listSync(recursive: true)) {
    if (entity is File && withNames.contains(p.basename(entity.path))) {
      result.add(entity);
    }
  }
  return result;
}

extension on File {
  bool isNotIgnored() {
    final result = Process.runSync(
      'git',
      'check-ignore $path --quiet'.split(' '),
    );

    return result.exitCode != 0;
  }
}
