import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:runout/core/constants/app_constants.dart';

void main() {
  test('app version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)?.group(1)?.split('+').first;

    expect(version, isNotNull);
    expect(AppConstants.appVersion, version);
  });
}
