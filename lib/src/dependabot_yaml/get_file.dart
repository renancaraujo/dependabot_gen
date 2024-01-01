import 'dart:io';

import 'package:dependabot_gen/src/dependabot_yaml/dependabot_yaml.dart';
import 'package:path/path.dart' as p;

DependabotFile getDependabotFile({required Directory repositoryRoot}) {
  final filePath = p.join(repositoryRoot.path, '.github', 'dependabot.yaml');
  final file = File(filePath);
  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }

  return DependabotFile.fromFile(file);
}

class DependabotFile {
  const DependabotFile({
    required this.path,
    required this.content,
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
    );
  }

  final String path;

  final DependabotSpec content;
}
