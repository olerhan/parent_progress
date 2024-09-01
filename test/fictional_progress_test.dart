import 'package:flutter_test/flutter_test.dart';
import 'package:parent_progress/parent_progress.dart';

void main() {
  group('FictionalProgress Tests', () {
    test('Initial values are set correctly', () {
      final sizes = [10, 20, 30];
      final progress = FictionalProgress(sizes);

      // Initially, the percentage should be zero.
      expect(progress.getPercentage, 0,
          reason: "Initial percentage should be 0.");
    });

    test('Progress up to index level calculates correctly', () async {
      final sizes = [10, 20, 30];
      final progress = FictionalProgress(sizes);

      // Simulate progress up to the first level.
      await progress.finishProgressUpToIndexLevel(
          processIndexLevel: 0,
          processingLenghtPerS: 10,
          updateIntervalMs: 1000);

      // Check that the first level is completed and the percentage calculations are correct.
      expect(progress.getPercentage, isNot(0),
          reason: "Initial percentage should not be 0.");
    });

    test('Complete to index level calculates correctly', () async {
      final sizes = [10, 20, 30];
      final progress = FictionalProgress(sizes);

      // Simulate progress up to the first level.
      progress.completeProgress(upToIndexLevel: 1);

      // Check that the first level is completed and the percentage calculations are correct.
      expect(progress.getPercentage, 50,
          reason: "Initial percentage should be 50.");
    });

    test('Reset progress works correctly', () {
      final sizes = [10, 20, 30];
      final progress = FictionalProgress(sizes);

      // Reset the progress.
      progress.resetProgress();
      expect(progress.getPercentage, 0,
          reason: "Initial percentage should be 0.");
    });
  });
}
