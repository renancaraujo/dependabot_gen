import 'dart:io';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:meta/meta.dart';

import 'package:path/path.dart' as p;

/// The package ecosystems supported by dependabot.
enum PackageEcosystem {
  /// The GitHub Actions package ecosystem for GitHub Actions.
  githubActions(_PackageEcosystemFinder.githubActions),

  /// The Docker package ecosystem.
  docker(_PackageEcosystemFinder.docker),

  /// The git submodule package ecosystem.
  gitModules(_PackageEcosystemFinder.gitModules),

  /// The pub package ecosystem for Dart.
  pub(_PackageEcosystemFinder.pub),

  /// The go.mod package ecosystem for Go.
  gomod(_PackageEcosystemFinder.gomod),

  /// The Maven package ecosystem for JVM languages.
  maven(_PackageEcosystemFinder.maven),

  /// The npm package ecosystem for JavaScript.
  npm(_PackageEcosystemFinder.npm),

  /// LOL
  composer(_PackageEcosystemFinder.composer),

  /// The pip package ecosystem for Python.
  pip(_PackageEcosystemFinder.pip),

  /// The bundler package ecosystem for Ruby.
  bundler(_PackageEcosystemFinder.bundler),

  /// The cargo package ecosystem for Rust.
  cargo(_PackageEcosystemFinder.cargo),

  /// The nuget package ecosystem for .NET.
  nuget(_PackageEcosystemFinder.nuget),

  /// The hex package ecosystem for Elixir.
  hex(_PackageEcosystemFinder.hex),
  ;

  const PackageEcosystem(this._finder);

  /// The respective [_PackageEcosystemFinder] for this [PackageEcosystem].
  final _PackageEcosystemFinder _finder;

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
        repoRoot: repoRoot,
        schedule: schedule,
        targetBranch: targetBranch,
        labels: labels,
        milestone: milestone,
        ignoreFinding: ignoreFinding,
      );
}

/// A class that encapsulates the logic to find packages that may have
/// its dependencies updated by dependabot.
///
/// Its subclasses are responsible for finding the packages for a specific
/// package ecosystem (e.g. pub, npm, etc) according to the how
/// the package ecosystem is structured.
@immutable
abstract interface class _PackageEcosystemFinder {
  /// Finder for the pub package ecosystem.
  static const pub = _ManifestPackageEcosystemFinder(
    ecosystem: 'pub',
    indexFiles: {
      'pubspec.yaml',
    },
  );

  /// Finder for the go.mod package ecosystem.
  static const gomod = _ManifestPackageEcosystemFinder(
    ecosystem: 'gomod',
    indexFiles: {
      'go.mod',
    },
  );

  /// Finder for the Maven package ecosystem.
  static const maven = _ManifestPackageEcosystemFinder(
    ecosystem: 'maven',
    indexFiles: {
      'pom.xml',
    },
  );

  /// Finder for the npm package ecosystem.
  static const npm = _ManifestPackageEcosystemFinder(
    ecosystem: 'npm',
    indexFiles: {
      'package.json',
    },
  );

  /// LOL
  static const composer = _ManifestPackageEcosystemFinder(
    ecosystem: 'composer',
    indexFiles: {
      'composer.json',
    },
  );

  /// Finder for the pip package ecosystem.
  static const pip = _ManifestPackageEcosystemFinder(
    ecosystem: 'pip',
    indexFiles: {
      'requirements.txt',
      'Pipfile',
      'pyproject.toml',
    },
  );

  /// Finder for the bundler package ecosystem.
  static const bundler = _ManifestPackageEcosystemFinder(
    ecosystem: 'bundler',
    indexFiles: {
      'Gemfile',
    },
  );

  /// Finder for the cargo package ecosystem.
  static const cargo = _ManifestPackageEcosystemFinder(
    ecosystem: 'cargo',
    indexFiles: {
      'Cargo.toml',
    },
  );

  /// Finder for the nuget package ecosystem.
  static const nuget = _ManifestPackageEcosystemFinder(
    ecosystem: 'nuget',
    indexFiles: {
      '.nuspec',
      '.csproj',
    },
  );

  /// Finder for the hex package ecosystem.
  static const hex = _ManifestPackageEcosystemFinder(
    ecosystem: 'mix',
    indexFiles: {
      'mix.exs',
    },
  );

  /// Finder for the GitHub Actions package ecosystem.
  static const githubActions = _HeuristicPackageEcosystemFinder(
    ecosystem: 'github-actions',
    directory: '/',
    repoHeuristics: _githubActionsHeuristics,
  );

  static bool _githubActionsHeuristics(Directory repoRoot) {
    final workflows = Directory(
      p.join(repoRoot.path, '.github', 'workflows'),
    );
    return workflows.existsSync();
  }

  /// Finder for the Docker package ecosystem.
  static const docker = _HeuristicPackageEcosystemFinder(
    ecosystem: 'docker',
    directory: '/',
    repoHeuristics: _dockerHeuristics,
  );

  static bool _dockerHeuristics(Directory repoRoot) {
    final dockerfile = File(
      p.join(repoRoot.path, 'Dockerfile'),
    );
    return dockerfile.existsSync();
  }

  /// Finder for the git submodule package ecosystem.
  static const gitModules = _HeuristicPackageEcosystemFinder(
    ecosystem: 'git-submodule',
    directory: '/',
    repoHeuristics: _gitmodulesHeuristics,
  );

  static bool _gitmodulesHeuristics(Directory repoRoot) {
    final gitModules = File(
      p.join(repoRoot.path, '.gitmodules'),
    );
    return gitModules.existsSync();
  }

  /// Finds the packages that may have its dependencies updated by dependabot.
  Iterable<UpdateEntry> findUpdateEntries({
    required Directory repoRoot,
    required Schedule schedule,
    required String? targetBranch,
    required Set<String>? labels,
    required int? milestone,
    required Set<String>? ignoreFinding,
  });

  /// The name of the package ecosystem.
  String get ecosystem;
}

/// {@template heuristic_package_ecosystem_finder}
/// A [_PackageEcosystemFinder] that uses heuristics to find packages.
/// {@endtemplate}
class _HeuristicPackageEcosystemFinder implements _PackageEcosystemFinder {
  /// {@macro heuristic_package_ecosystem_finder}
  const _HeuristicPackageEcosystemFinder({
    required this.ecosystem,
    required this.directory,
    required this.repoHeuristics,
  });

  @override
  final String ecosystem;

  /// The directory where the package manifests are located.
  final String directory;

  /// The heuristics to find the package manifests.
  final bool Function(Directory repoRoot) repoHeuristics;

  @override
  Iterable<UpdateEntry> findUpdateEntries({
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
/// A [_PackageEcosystemFinder] that uses a list of index files to find packages.
/// {@endtemplate}
final class _ManifestPackageEcosystemFinder implements _PackageEcosystemFinder {
  /// {@macro manifest_package_ecosystem_finder}
  const _ManifestPackageEcosystemFinder({
    required this.indexFiles,
    required this.ecosystem,
  });

  @override
  final String ecosystem;

  /// The index files used to find the package manifests.
  final Set<String> indexFiles;

  @override
  Iterable<UpdateEntry> findUpdateEntries({
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
      final convertedPath = dirPath.replaceFirst(RegExp(r'^\.\/?'), '/');

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
