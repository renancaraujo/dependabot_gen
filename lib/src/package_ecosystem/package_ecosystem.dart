import 'dart:io';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:meta/meta.dart';

import 'package:path/path.dart' as p;

/// The package ecosystems supported by dependabot.
enum PackageEcosystem {
  /// The GitHub Actions package ecosystem for GitHub Actions.
  githubActions(
    ecosystemName: 'github-actions',
    _HeuristicPackageEcosystemFinder(
      repoHeuristics: _githubActionsHeuristics,
    ),
  ),

  /// The Docker package ecosystem.
  docker(
    _HeuristicPackageEcosystemFinder(
      repoHeuristics: _dockerHeuristics,
    ),
  ),

  /// The git submodule package ecosystem.
  gitModules(
    ecosystemName: 'git-submodule',
    _HeuristicPackageEcosystemFinder(
      repoHeuristics: _gitmodulesHeuristics,
    ),
  ),

  /// The bundler package ecosystem for Ruby.
  bundler(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'Gemfile',
      },
    ),
  ),

  /// The cargo package ecosystem for Rust.
  cargo(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'Cargo.toml',
      },
    ),
  ),

  /// LOL
  composer(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'composer.json',
      },
    ),
  ),

  /// The go.mod package ecosystem for Go.
  gomod(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'go.mod',
      },
    ),
  ),

  /// The hex package ecosystem for Elixir.
  hex(
    ecosystemName: 'mix',
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'mix.exs',
      },
    ),
  ),

  /// The Maven package ecosystem for JVM languages.
  maven(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'pom.xml',
      },
    ),
  ),

  /// The npm package ecosystem for JavaScript.
  npm(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'package.json',
      },
    ),
  ),

  /// The nuget package ecosystem for .NET.
  nuget(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        '.nuspec',
        '.csproj',
      },
    ),
  ),

  /// The pip package ecosystem for Python.
  pip(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'requirements.txt',
        'Pipfile',
        'pyproject.toml',
      },
    ),
  ),

  /// The pub package ecosystem for Dart.
  pub(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'pubspec.yaml',
      },
    ),
  ),

  /// The swift package ecosystem for Swift.
  swift(
    _ManifestPackageEcosystemFinder(
      indexFiles: {
        'Package.swift',
      },
    ),
  ),
  ;

  const PackageEcosystem(
    this._finder, {
    this.ecosystemName,
  });

  /// The respective [_PackageEcosystemFinder] for this [PackageEcosystem].
  final _PackageEcosystemFinder _finder;

  /// The name of the package ecosystem if it's different from [name].
  final String? ecosystemName;

  /// Finds the packages that may have its dependencies updated by dependabot.
  Iterable<UpdateEntry> findUpdateEntries({
    required Directory repoRoot,
    required Schedule schedule,
    required String? targetBranch,
    required Set<String>? labels,
    required int? milestone,
    required Set<String>? ignoreFinding,
  }) =>
      _finder.findUpdateEntries(
        ecosystem: ecosystemName ?? name,
        repoRoot: repoRoot,
        schedule: schedule,
        targetBranch: targetBranch,
        labels: labels,
        milestone: milestone,
        ignoreFinding: ignoreFinding,
      );
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

/// A class that encapsulates the logic to find packages that may have
/// its dependencies updated by dependabot.
///
/// Its subclasses are responsible for finding the packages for a specific
/// package ecosystem (e.g. pub, npm, etc) according to the how
/// the package ecosystem is structured.
@immutable
abstract interface class _PackageEcosystemFinder {
  /// Finds the packages that may have its dependencies updated by dependabot.
  Iterable<UpdateEntry> findUpdateEntries({
    required String ecosystem,
    required Directory repoRoot,
    required Schedule schedule,
    required String? targetBranch,
    required Set<String>? labels,
    required int? milestone,
    required Set<String>? ignoreFinding,
  });
}

/// {@template heuristic_package_ecosystem_finder}
/// A [_PackageEcosystemFinder] that uses heuristics to find packages.
/// {@endtemplate}
class _HeuristicPackageEcosystemFinder implements _PackageEcosystemFinder {
  /// {@macro heuristic_package_ecosystem_finder}
  const _HeuristicPackageEcosystemFinder({
    required this.repoHeuristics,
  });

  /// The heuristics to find the package manifests.
  final bool Function(Directory repoRoot) repoHeuristics;

  @override
  Iterable<UpdateEntry> findUpdateEntries({
    required String ecosystem,
    required Directory repoRoot,
    required Schedule schedule,
    required String? targetBranch,
    required Set<String>? labels,
    required int? milestone,
    required Set<String>? ignoreFinding,
  }) sync* {
    if (repoHeuristics(repoRoot)) {
      yield UpdateEntry(
        directory: '/',
        ecosystem: ecosystem,
        schedule: schedule,
        targetBranch: targetBranch,
        labels: labels,
        milestone: milestone,
      );
    }
  }
}

/// {@template manifest_package_ecosystem_finder}
/// A [_PackageEcosystemFinder] that uses a list of index files to
/// find packages.
/// {@endtemplate}
class _ManifestPackageEcosystemFinder implements _PackageEcosystemFinder {
  /// {@macro manifest_package_ecosystem_finder}
  const _ManifestPackageEcosystemFinder({
    required this.indexFiles,
  });

  /// The index files used to find the package manifests.
  final Set<String> indexFiles;

  @override
  Iterable<UpdateEntry> findUpdateEntries({
    required String ecosystem,
    required Directory repoRoot,
    required Schedule schedule,
    required String? targetBranch,
    required Set<String>? labels,
    required int? milestone,
    required Set<String>? ignoreFinding,
  }) sync* {
    final paths = _findFilesRecursivelyOn(
      directory: repoRoot,
      withNames: indexFiles,
    ).where((e) => e.isNotIgnored()).map((e) => e.path);

    outer:
    for (final manifestPath in paths) {
      if (ignoreFinding != null) {
        for (final parent in ignoreFinding) {
          if (p.isWithin(parent, manifestPath) ||
              p.equals(parent, manifestPath)) {
            continue outer;
          }
        }
      }

      final dirPath = p.relative(
        p.dirname(manifestPath),
        from: repoRoot.path,
      );

      // replace '.' and './' with '/' (only if it's at the beginning)
      var convertedPath = dirPath.replaceFirst(RegExp(r'^\.\/?'), '/');

      if (!convertedPath.startsWith('/')) {
        convertedPath = '/$convertedPath';
      }

      yield UpdateEntry(
        directory: convertedPath,
        ecosystem: ecosystem,
        schedule: schedule,
        targetBranch: targetBranch,
        labels: labels,
        milestone: milestone,
      );
    }
  }
}

List<File> _findFilesRecursivelyOn({
  required Directory directory,
  required Set<String> withNames,
}) {
  final result = <File>[];
  final dirlist = directory.absolute
      .listSync(recursive: true)
      .whereType<File>()
      .toList()
    ..sort((l, r) => l.path.compareTo(r.path));
  for (final entity in dirlist) {
    if (withNames.contains(p.basename(entity.path))) {
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
      workingDirectory: p.dirname(path),
    );

    return result.exitCode != 0;
  }
}
