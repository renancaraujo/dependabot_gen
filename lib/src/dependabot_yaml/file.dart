import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

/// Retrieves the [DependabotFile] for the given [repositoryRoot].
///
/// If the file does not exist, it will be created.
DependabotFile getDependabotFile({required Directory repositoryRoot}) {
  final filePath = p.join(repositoryRoot.path, '.github', 'dependabot.yaml');
  final filePath2 = p.join(repositoryRoot.path, '.github', 'dependabot.yml');
  var file = File(filePath);

  if (!file.existsSync()) {
    file = File(filePath2);
  }

  if (!file.existsSync()) {
    file = File(filePath)..createSync(recursive: true);
  }

  return DependabotFile.fromFile(file);
}

/// Represents a dependabot.yaml file with its [path] and [content].
@immutable
class DependabotFile {
  const DependabotFile._({
    required this.path,
    required this.content,
  });

  /// Creates a new [DependabotFile] from the given [file].
  ///
  /// If the file is empty, a default [DependabotSpec] will be created.
  factory DependabotFile.fromFile(File file) {
    final contents = file.readAsStringSync();

    DependabotSpec content;
    if (contents.isEmpty) {
      content = const DependabotSpec(
        version: DependabotVersion.v2,
        updates: [],
        enableBetaEcosystems: true,
      );
    } else {
      content = checkedYamlDecode(
        contents,
        (m) {
          if (m == null) {
            throw CheckedFromJsonException(
              m ?? {},
              'DependabotSpec',
              'yaml',
              'Expected a Map<String, dynamic>, but got ${m.runtimeType}',
            );
          }
          return DependabotSpec.fromJson(m);
        },
        sourceUrl: file.uri,
      );
    }

    return DependabotFile._(
      path: file.path,
      content: content,
    );
  }

  /// The path to the dependabot.yaml file.
  final String path;

  /// The content of the dependabot.yaml file represented as a [DependabotSpec].
  final DependabotSpec content;

  /// Creates a copy of this [DependabotFile] with the given fields replaced.
  DependabotFile copyWith({
    String? path,
    DependabotSpec? content,
  }) {
    return DependabotFile._(
      path: path ?? this.path,
      content: content ?? this.content,
    );
  }

  /// Writes the [content] to the dependabot.yaml file.
  void writeToFile() {
    final editor = YamlEditor('')..update([], content.toJson());
    File(path).writeAsStringSync(editor.toString());
  }
}
