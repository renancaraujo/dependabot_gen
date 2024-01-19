import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';
import 'package:yaml_writer/yaml_writer.dart';

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
  @visibleForTesting
  factory DependabotFile.fromFile(File file) {
    var contents = file.existsSync() ? file.readAsStringSync() : '';

    DependabotSpec content;
    if (contents.isEmpty) {
      content = const DependabotSpec(
        version: DependabotVersion.v2,
        updates: [],
      );
      contents = YAMLWriter().write(content);
    } else {
      content = checkedYamlDecode(
        contents,
        (m) => DependabotSpec.fromJson(m!),
        sourceUrl: file.uri,
      );
    }

    final editor = YamlEditor(contents);

    return DependabotFile._(file.path, content, editor);
  }

  /// Retrieves the [DependabotFile] for the given [repositoryRoot].
  ///
  /// If the file does not exist, it will be created.
  factory DependabotFile.fromRepositoryRoot(Directory repositoryRoot) {
    final filePath = p.join(repositoryRoot.path, '.github', 'dependabot.yml');
    final filePath2 = p.join(repositoryRoot.path, '.github', 'dependabot.yaml');
    var file = File(filePath);

    if (!file.existsSync()) {
      file = File(filePath2);
    }

    if (!file.existsSync()) {
      file = File(filePath);
    }

    return DependabotFile.fromFile(file);
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
  /// For that, call [saveToFile].
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
  /// For that, call [saveToFile].
  void removeUpdateEntry({
    required String directory,
    required String ecosystem,
  }) {
    final matchingEntries = [..._content.updates].indexed.where(
          (e) => e.$2.directory == directory && e.$2.ecosystem == ecosystem,
        );

    if (matchingEntries.isEmpty) {
      return;
    }

    _content.updates.removeWhere(
      (e) => e.directory == directory && e.ecosystem == ecosystem,
    );

    for (final (index, _) in matchingEntries) {
      _editor.remove(['updates', index]);
    }
  }

  /// Saves the changes to the actual dependabot.yaml file.
  void saveToFile() {
    final file = File(path);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    file.writeAsStringSync(_editor.toString());
  }
}
