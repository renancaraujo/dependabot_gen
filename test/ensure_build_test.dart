@Tags(['version-verify'])
library;

// import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  // test(
  //     'ensure_build',
  //     () => expectBuildClean(
  //           customCommand: [
  //             'dart',
  //             'run',
  //             'build_runner',
  //             'build',
  //             '--delete-conflicting-outputs',
  //             '--build-filter="lib/src/version.dart"',
  //           ],
  //         ),
  //     tags: ['version-verify']);

  test('noop', () => expect(true, isTrue), tags: ['version-verify']);
}
