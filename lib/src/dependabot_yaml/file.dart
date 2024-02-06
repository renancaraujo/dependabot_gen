import 'dart:io';

import 'package:checked_yaml/checked_yaml.dart';
import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';
import 'package:yaml_writer/yaml_writer.dart';

/// A dummy [UpdateEntry] used to create a default dependabot.yaml file.
const kDummyEntry = UpdateEntry(
  directory: 'dummy',
  ecosystem: 'dummy',
  schedule: Schedule(interval: ScheduleInterval.monthly),
);

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
    String contents;
    contents = file.existsSync() ? file.readAsStringSync() : '';

    DependabotSpec content;
    if (contents.isEmpty) {
      content = const DependabotSpec(
        version: DependabotVersion.v2,
        updates: [kDummyEntry],
      );
      contents = YamlWriter().write(content);
    } else {
      try {
        content = checkedYamlDecode(
          contents,
          (m) => DependabotSpec.fromJson(m!),
          sourceUrl: file.uri,
        );
      } on ParsedYamlException catch (e) {
        throw DependabotFileParsingException(
          internalError: e,
          filePath: file.path,
          message: 'Error parsing the contents of the dependabot config file, '
              'verify if it is compliant with the dependabot specification at '
              '${link(uri: dependabotSpecUri)}',
        );
      }
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
    final hasDummy =
        _content.updates.isNotEmpty && _content.updates.first == kDummyEntry;
    if (hasDummy) {
      _content = _content.copyWith(updates: []);
    }

    _content = _content.copyWith(
      updates: [
        ..._content.updates,
        newEntry,
      ],
    );

    _editor.appendToList(['updates'], newEntry.toJson());

    if (hasDummy) {
      _editor.remove(['updates', 0]);
    }
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
    if (_content.updates.length == 1 && _content.updates.first == kDummyEntry) {
      _content = _content.copyWith(
        updates: [],
      );
      _editor.remove(['updates', 0]);
    }

    final file = File(path);

    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    file.writeAsStringSync(_editor.toString());
  }
}

/// An exception that is thrown when parsing a Dependabot file fails.
class DependabotFileParsingException implements Exception {
  /// Creates a [DependabotFileParsingException]
  DependabotFileParsingException({
    required this.internalError,
    required this.filePath,
    required this.message,
  });

  /// The containing exception or error
  final ParsedYamlException internalError;

  /// The path tot he dependabot file in question
  final String filePath;

  /// Some more deets.
  final String message;
}

/// The uri of some dependabot docs
final dependabotSpecUri = Uri.parse(
  'https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file',
);
