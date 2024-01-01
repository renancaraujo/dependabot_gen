import 'dart:io';

const _kDefaultNewYaml = '''
version: 2
enable-beta-ecosystems: true''';

File getDependabotFile({required Directory repositoryRoot}) {
  final filePath = p.join(repositoryRoot.path, '.github', 'dependabot.yaml');
  final file = File(filePath);
  if (!file.existsSync()) {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(_kDefaultNewYaml);
  }

  return file;
}



