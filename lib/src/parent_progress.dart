import 'package:flutter/foundation.dart';
import 'package:parent_progress/src/child_progress.dart';

import 'debug_helpers.dart';

/// A class that aggregates multiple progress progresses and calculates a weighted total progress.
/// This class uses `_flexFactors` to determine the weight of each child progress's contribution to the total progress.
class ParentProgress extends ChildProgress {
  int _percentage = 0;
  final List<int>
      _flexFactors; // Weights for each child progress's contribution to the total.
  final List<ChildProgress> _children;
  final List<ValueNotifier<int>>
      _slices; // Child progresses' percentage notifiers.
  final List<double>
      _progressWeights; // Calculated progress contributions from each child.
  final List<VoidCallback> _listeners =
      []; // List to store listeners for cleanup.

  /// Initializes a new ParentProgress with a list of child percentage notifiers and their corresponding flex factors.
  /// Throws ArgumentError if the lists' lengths do not match.
  ///
  /// The `percentageNotifiers` list should include ValueNotifier<int> from each child progress,
  /// and `flexFactors` determines the importance or weight of each child's progress.
  ParentProgress(
    List<ChildProgress> children,
    List<int> flexFactors, {
    super.uniqueName,
  })  : _flexFactors = flexFactors,
        _children = children,
        _slices = children.map((child) => child.percentageNotifier).toList(),
        _progressWeights = List<double>.filled(flexFactors.length, 0.0) {
    if (_slices.length != flexFactors.length) {
      throw ArgumentError(
          '${uniqueName != null ? '${uniqueName!}: ' : ''}Length of percentageNotifiers must match length of flexFactors');
    }
    _initializeListeners();
  }

  List<int> get getFlexFactors => _flexFactors;
  List<ChildProgress> get getChildren => _children;
  List<ValueNotifier<int>> get getSlices => _slices;
  List<double> get getProgressWeights => _progressWeights;

  /// Sets up listeners on each child progress's ValueNotifier to update the parent progress.
  void _initializeListeners() {
    for (int i = 0; i < _slices.length; i++) {
      listener() => _updateSliceProgress(i, _slices[i].value);
      _listeners.add(listener);
      _slices[i].addListener(listener);
    }
    printDebugInfo(
        '${uniqueName != null ? '${uniqueName!}: ' : ''}ParentProgress initialized.');
  }

  /// Updates the progress contribution from a specific child progress based on its new percentage.
  /// Validates the index and percentage range, and recalculates the total progress.
  void _updateSliceProgress(int sliceIndex, int newPercentage) {
    if (sliceIndex < 0 || sliceIndex >= _flexFactors.length) {
      throw IndexError.withLength(sliceIndex, _flexFactors.length);
    }
    if (newPercentage < 0 || newPercentage > 100) {
      throw ArgumentError(
          '${uniqueName != null ? '${uniqueName!}: ' : ''}Percentage must be between 0 and 100');
    }

    int totalFlex = _flexFactors.reduce((a, b) => a + b);
    double slicePercentage = (_flexFactors[sliceIndex] / totalFlex) * 100;
    _progressWeights[sliceIndex] = (newPercentage / 100) * slicePercentage;
    _updateParentProgress();
  }

  /// Aggregates all child contributions and updates the total percentage.
  void _updateParentProgress() {
    _percentage = _progressWeights.reduce((a, b) => a + b).round();
    percentageNotifier.value = _percentage;
    printDebugInfo(
        "${uniqueName != null ? '${uniqueName!}: ' : ''}Parent percentage updated: $_percentage");
  }

  /// Cleans up by removing listeners and disposing of the notifier.
  void dispose() {
    for (int i = 0; i < _slices.length; i++) {
      _slices[i].removeListener(_listeners[i]);
    }
    percentageNotifier.dispose();
    printDebugInfo(
        "${uniqueName != null ? '${uniqueName!}: ' : ''}ParentProgress disposed.");
  }
}
