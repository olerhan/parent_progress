import 'package:flutter_test/flutter_test.dart';
import 'package:parent_progress/parent_progress.dart';
import 'package:flutter/material.dart';

void main() {
  group('ParentProgress Tests', () {
    test('Initial values are correct and initial update is triggered', () {
      List<ValueNotifier<int>> notifiers = [
        ValueNotifier<int>(0),
        ValueNotifier<int>(0)
      ];
      List<int> flexFactors = [1, 1];

      final parent = ParentProgress(notifiers, flexFactors);

      expect(parent.totalPercentageNotifier.value, 0);

      // Update the first notifier to see if the parent updates correctly
      notifiers[0].value = 50;

      // Since both have equal weight and one is at 50%, the total should update to reflect this change
      expect(parent.totalPercentageNotifier.value, 25);
    });

    test('Total progress calculation adjusts with updates', () {
      List<ValueNotifier<int>> notifiers = [
        ValueNotifier<int>(0),
        ValueNotifier<int>(0)
      ];
      List<int> flexFactors = [1, 2]; // The second progress has more weight

      final parent = ParentProgress(notifiers, flexFactors);

      // Update both notifiers
      notifiers[0].value = 50;
      notifiers[1].value = 100;

      // Expected value should consider the weights: (50*1 + 100*2) / (1+2)
      expect(parent.totalPercentageNotifier.value,
          ((50 * 1 + 100 * 2) / 3).round());
    });

    test('Dispose unregisters listeners', () {
      List<ValueNotifier<int>> notifiers = [
        ValueNotifier<int>(0),
        ValueNotifier<int>(0)
      ];
      List<int> flexFactors = [1, 1];

      final parent = ParentProgress(notifiers, flexFactors);
      parent.dispose();

      // After disposal, changes in notifiers should not affect parent's total percentage
      notifiers[0].value = 100;

      expect(parent.totalPercentageNotifier.value, 0);
    });
  });
}
