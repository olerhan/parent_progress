import 'package:flutter_test/flutter_test.dart';
import 'package:parent_progress/parent_progress.dart';

void main() {
  group('RationalProgress Tests', () {
    test('Initial values are set correctly', () {
      final progress = RationalProgress(totalWork: 100);

      expect(progress.getCurrentPercentage, 0);
      expect(progress.getTotalWork, 100);
    });

    test('Progress updates correctly after half the work is done', () async {
      final progress = RationalProgress(totalWork: 100);
      await progress.currentWorkDone(50);

      // After updating the work to 50, the current progress should reflect 50% completion.
      expect(progress.getCurrentPercentage, 50);

      await progress.currentWorkDone(120);
      expect(progress.getCurrentPercentage, isNot(120),
          reason: "Initial percentage should not be 120.");
    });

    test('Reset works correctly', () async {
      final progress = RationalProgress(totalWork: 100);
      await progress.currentWorkDone(100);
      progress.resetProgress();

      expect(progress.getCurrentPercentage, 0);
    });
  });
}
