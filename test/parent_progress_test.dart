import 'package:flutter_test/flutter_test.dart';
import 'package:parent_progress/parent_progress.dart';
import 'package:parent_progress/src/child_progress.dart';

void main() {
  group('ParentProgress Tests', () {
    test('Initial values are correct and initial update is triggered', () {
      List<ChildProgress> children = [
        FictionalProgress([100]),
        FictionalProgress([100]),
      ];
      List<int> flexFactors = [1, 1];

      final parent = ParentProgress(children, flexFactors);

      expect(parent.percentageNotifier.value, 0);

      // Update the first notifier to see if the parent updates correctly
      children[0].percentageNotifier.value = 50;

      // Since both have equal weight and one is at 50%, the total should update to reflect this change
      expect(parent.percentageNotifier.value, 25);
    });

    test('Total progress calculation adjusts with updates', () {
      List<ChildProgress> children = [
        FictionalProgress([100]),
        FictionalProgress([100]),
      ];
      List<int> flexFactors = [1, 2]; // The second progress has more weight

      final parent = ParentProgress(children, flexFactors);

      // Update both notifiers
      children[0].percentageNotifier.value = 50;
      children[1].percentageNotifier.value = 100;

      // Expected value should consider the weights: (50*1 + 100*2) / (1+2)
      expect(parent.percentageNotifier.value, ((50 * 1 + 100 * 2) / 3).round());
    });

    test('Dispose unregisters listeners', () {
      List<ChildProgress> children = [
        FictionalProgress([100]),
        FictionalProgress([100]),
      ];
      List<int> flexFactors = [1, 1];

      final parent = ParentProgress(children, flexFactors);
      parent.dispose();

      // After disposal, changes in notifiers should not affect parent's total percentage
      children[0].percentageNotifier.value = 100;

      expect(parent.percentageNotifier.value, 0);
    });
  });
}
