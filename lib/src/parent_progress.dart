import 'package:flutter/foundation.dart';
import 'package:parent_progress/src/child_progress.dart';
import 'debug_helpers.dart';

/// A class that aggregates multiple child progress instances and calculates a total progress
/// with weighted contributions from each child. This class is particularly useful in scenarios
/// where multiple concurrent operations contribute to a single overarching goal, such as
/// downloading multiple files, processing multiple data streams, or completing stages of a
/// complex task. Inherits functionalities from `ChildProgress`.
///
/// Features include:
/// - Dynamic weighting of each child's progress contribution, allowing for flexible prioritization
///   of tasks based on their importance or impact on the overall process.
/// - Real-time calculation and notification of total progress, providing a comprehensive view
///   of the combined progress of all children.
/// - Easy integration with UI components to display collective progress, enhancing user
///   experience by showing unified progress details.
///
/// The class uses `_flexFactors` to determine the weight of each child progress's contribution
/// to the total progress, offering a customizable approach to progress aggregation. This mechanism
/// ensures that some tasks can be prioritized higher than others, depending on the specified
/// weights, making the class adaptable to a wide range of applications.
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

  /// Initializes a new ParentProgress with a list of child progress objects and their corresponding flex factors.
  /// Each child progress's `percentageNotifier` is included implicitly via the `children` list,
  /// and `flexFactors` determines the importance or weight of each child's progress.
  /// Throws an ArgumentError if the lists' lengths do not match.
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

  /// Returns a list of flex factors that determine the weight of each child progress's contribution.
  List<int> get getFlexFactors => _flexFactors;

  /// Returns a list of child progress instances, each representing a progress tracking component.
  List<ChildProgress> get getChildren => _children;

  /// Returns a list of `ValueNotifier<int>` from each child progress, used to notify listeners of percentage changes.
  List<ValueNotifier<int>> get getSlices => _slices;

  /// Returns a list of progress weights calculated from each child's current percentage, influenced by the associated flex factor.
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

  /// Updates the progress contribution from a specific child based on its new percentage.
  /// Validates the provided index against the range of child progress instances and the percentage value must be between 0 and 100.
  /// Throws an `IndexError` if the index is out of bounds or an `ArgumentError` if the percentage is out of valid range.
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

  /// Cleans up by removing all listeners from child progress notifiers and disposing of the total percentage notifier.
  /// It's essential to call this method to free up resources when the `ParentProgress` instance is no longer needed.
  void dispose() {
    for (int i = 0; i < _slices.length; i++) {
      _slices[i].removeListener(_listeners[i]);
    }
    percentageNotifier.dispose();
    printDebugInfo(
        "${uniqueName != null ? '${uniqueName!}: ' : ''}ParentProgress disposed.");
  }
}
