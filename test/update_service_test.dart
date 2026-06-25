import 'package:flutter_test/flutter_test.dart';
import 'package:vedo/services/update_service.dart';

void main() {
  group('shouldShowUpdate', () {
    test('shows update when remote version name is higher', () {
      expect(
        shouldShowUpdate(
          currentVersion: '1.0.1',
          currentBuildNumber: '2',
          latestVersionName: '1.0.2',
          latestVersionCode: 2,
        ),
        isTrue,
      );
    });

    test('does not show update when versions are equal', () {
      expect(
        shouldShowUpdate(
          currentVersion: '1.0.1',
          currentBuildNumber: '2',
          latestVersionName: '1.0.1',
          latestVersionCode: 2,
        ),
        isFalse,
      );
    });
  });
}
