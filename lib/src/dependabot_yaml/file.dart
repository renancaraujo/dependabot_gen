import 'dart:io';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

DependabotFile getDependabotFile({required Directory repositoryRoot}) {
  final filePath = p.join(repositoryRoot.path, '.github', 'dependabot.yaml');
  final file = File(filePath);
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }

  return DependabotFile.fromFile(file);
}

@immutable
class DependabotFile {
  const DependabotFile({
    required this.path,
    required this.content,
    required this.editor,
  });

  factory DependabotFile.fromFile(File file) {
    final contents = file.readAsStringSync();

    DependabotSpec content;
    if (contents.isEmpty) {
      content = DependabotSpec(
        version: DependabotVersion.v2,
        updates: [],
        enableBetaEcosystems: true,
      );
    } else {
      content = DependabotSpec.parse(contents, sourceUri: file.uri);
    }

    return DependabotFile(
      path: file.path,
      content: content,
      editor: YamlEditor(contents),
    );
  }

  final String path;

  final DependabotSpec content;

  final YamlEditor editor;

  DependabotFile copyWith({
    String? path,
    DependabotSpec? content,
  }) {
    return DependabotFile(
      path: path ?? this.path,
      content: content ?? this.content,
      editor: editor,
    );
  }

  void writeToFile() {
    editor.update([], content.toJson());
    File(path).writeAsStringSync(editor.toString());
  }
}
