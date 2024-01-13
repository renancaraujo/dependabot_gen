import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:json_annotation/json_annotation.dart';
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

/// Represents a dependabot.yaml file with its [path].
class DependabotFile {
  DependabotFile._(
    this.path,
    this._content,
    this._editor,
  );

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
    final editor = YamlEditor(contents);

    return DependabotFile._(file.path, content, editor);
  }

  /// The path to the dependabot.yaml file.
  final String path;

  /// The content of the dependabot.yaml file represented as a [DependabotSpec].
  DependabotSpec _content;

  final YamlEditor _editor;

  /// The current updates in the dependabot.yaml file.
  Iterable<UpdateEntry> get updates => _content.updates;

  /// Adds a new [UpdateEntry] to the dependabot.yaml file.
  ///
  /// Does not immediately save the changes to the file.
  /// For that, call [commitChanges].
  void addUpdateEntry(UpdateEntry newEntry) {
    _content = _content.copyWith(
      updates: [
        ..._content.updates,
        newEntry,
      ],
    );
    _editor.appendToList(['updates'], newEntry.toJson());
  }

  /// Removes an [UpdateEntry] from the dependabot.yaml file.
  ///
  /// Does not immediately save the changes to the file.
  /// For that, call [commitChanges].
  void removeUpdateEntry(UpdateEntry entry) {
    final index = _content.updates.indexWhere(
      (element) =>
          element.directory == entry.directory &&
          element.ecosystem == entry.ecosystem,
    );

    if (index == -1) {
      return;
    }

    _content = _content.copyWith(
      updates: [
        ..._content.updates.take(index),
        ..._content.updates.skip(index + 1),
      ],
    );

    _editor.remove(['updates', index]);
  }

  /// Saves the changes to the actual dependabot.yaml file.
  void commitChanges() {
    File(path).writeAsStringSync(_editor.toString());
  }
}
