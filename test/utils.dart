import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

File createFile(String content, [String name = 'dependabot.yaml']) {
  return File(
    p.join(Directory.systemTemp.absolute.path, name),
  )..writeAsStringSync(content);
}

Directory prepareFixture(List<String> fixturePath) {
  final currentDir = Directory(
    p.join('test', 'fixtures', p.joinAll(fixturePath)),
  );
  assert(
    currentDir.existsSync(),
    'Fixture does not exist: ${currentDir.absolute}',
  );
  final sisDir = Directory.systemTemp.createTempSync(fixturePath.join('_'));

  /// recursively copy everything from current to sis
  for (final entity in currentDir.listSync(recursive: true)) {
    final relative = p.relative(entity.path, from: currentDir.path);
    final destination = p.join(sisDir.path, relative);
    if (entity is Directory) {
      Directory(destination).createSync(recursive: true);
    } else if (entity is File) {
      File(destination).writeAsBytesSync(entity.readAsBytesSync());
    } else {
      throw UnsupportedError('Unsupported entity: $entity');
    }
  }

  return sisDir;
}

void runCommand(
  String line, {
  String? workingDirectory,
  Map<String, String>? environment,
  Logger? logger,
}) {
  final [command, ...args] = line.split(' ');
  final result = Process.runSync(
    command,
    args,
    runInShell: true,
    workingDirectory: workingDirectory,
    environment: environment,
  );

  if (result.exitCode != 0) {
    logger?.err(result.stdout as String);
    logger?.err(result.stderr as String);
    throw Exception('Failed to run command "$line"');
  }
}
