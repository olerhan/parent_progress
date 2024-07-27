import 'dart:async';

import 'debug_helpers.dart';
import 'package:flutter/material.dart';

/// A class that simulates a progress. This is not a real progress tracker,
/// but rather an estimation tool that simulates progress based on predefined sizes and rates.
///
/// This class manages progress calculation and notifies listeners about the
/// current progress using a [ValueNotifier]. It uses a list of sizes to simulate
/// the progress of data processing over time without actually processing any data.
class FictionalProgress {
  int _percentage = 0;
  final List<int>
      _sizes; // List of sizes that represent the segments of data or tasks to be simulated.
  int _totalSize = 0;
  Timer? _timer;
  double _processedSize = 0.0;
  ValueNotifier<int> percentageNotifier;
  Completer<void>? _completer;
  String? uniqueName;

  /// Creates a [FictionalProgress] with a list of sizes.
  ///
  /// Each element in the [sizes] list represents the size of a segment of data or a task.
  /// These sizes are crucial as they define the steps and the distribution of progress
  /// during the simulation. The total size is the sum of all sizes and represents the
  /// full scope of the simulated task or data.
  ///
  /// The [uniqueName] parameter can be used to uniquely identify the instance
  /// for debugging purposes.
  FictionalProgress(this._sizes, {this.uniqueName})
      : percentageNotifier = ValueNotifier<int>(0) {
    _totalSize = _sizes.reduce((a, b) => a + b);
  }

  /// Returns the current progress percentage.
  int get getPercentage => _percentage;

  /// Returns the total size processed so far.
  double get getProcessedSize => _processedSize;

  /// Returns the total size.
  int get getTotalSize => _totalSize;

  /// Returns the current process index level based on the processed size.
  ///
  /// This indicates which level of the process the current size has reached.
  /// Each index corresponds to a segment in the [sizes] list, and moving to the next
  /// index means that segment has been fully simulated.
  int get getCurrentProcessIndexLevel {
    for (int i = 0; i < _sizes.length; i++) {
      if (_processedSize >= _sizes[i]) {
        return i - 1;
      }
    }
    return -1; // Returns -1 if all elements are smaller than processedSize
  }

  /// Simulates finishing the progress up to a certain process index level.
  ///
  /// The [processIndexLevel] parameter indicates the target process level.
  /// The [processingRatePerS] parameter defines the rate of processing per second,
  /// which is a simulated rate of data processing or task completion.
  /// The [updateIntervalMs] parameter specifies the update interval in milliseconds.
  Future<void> finishProgressUpToIndexLevel({
    required int processIndexLevel,
    required double processingRatePerS,
    required int updateIntervalMs,
  }) async {
    _timer?.cancel(); // Cancel the previous timer
    _timer = null;
    _completer?.complete(); // Complete the previous operation
    _completer = Completer<void>();

    double targetSize = 0;
    for (int i = 0; i <= processIndexLevel; i++) {
      targetSize += _sizes[i];
    }
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Start method started with : $_percentage");
    _timer = Timer.periodic(Duration(milliseconds: updateIntervalMs), (timer) {
      if (_processedSize < targetSize) {
        _processedSize += processingRatePerS * (updateIntervalMs / 1000);
        if (_processedSize > targetSize) {
          _processedSize = targetSize;
        }
        _percentage = ((_processedSize / _totalSize) * 100).round();
        percentageNotifier.value = _percentage;
        printDebugInfo(
            "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Processing size: $_processedSize, Percentage: $_percentage");
      } else {
        printDebugInfo(
            "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Level Finished and percentage reached: $_percentage");
        _timer?.cancel();
        _timer = null;
        _completer?.complete();
      }
    });
    await _completer?.future;
    _completer = null;
  }

  /// Resets the progress and optionally initializes new sizes.
  ///
  /// If [newSizes] is provided, it will replace the current sizes and
  /// reinitialize the total size.
  void resetProgress({List<int>? newSizes}) {
    _timer?.cancel(); // Cancel the previous timer
    _timer = null;
    _completer?.complete();
    _percentage = 0;
    _processedSize = 0.0;
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Progress reset to zero");
    if (newSizes != null) {
      _sizes.clear();
      _sizes.addAll(newSizes);
      _totalSize = _sizes.reduce((a, b) => a + b);
      printDebugInfo(
          "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}New Sizes List Initialized: ${newSizes.join(', ')}");
    }
    percentageNotifier.value = _percentage;
  }

  /// Disposes the progress and releases all resources.
  void dispose() {
    _timer?.cancel();
    _completer?.complete();
    percentageNotifier.dispose();
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}FictionalProgress disposed.");
  }
}
