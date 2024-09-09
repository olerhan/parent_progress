import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:parent_progress/src/child_progress.dart';
import 'debug_helpers.dart';

/// A class that simulates progress for tasks or processes that do not have real-time
/// progress tracking capabilities. This is particularly useful in scenarios where progress
/// needs to be demonstrated for educational purposes, simulations, or software testing.
///
/// This class uses a list of predefined sizes to represent stages or checkpoints in a process.
/// Each size corresponds to a segment of work or a phase in the simulated task. The progress
/// is estimated based on these sizes and a specified rate of processing, allowing for a
/// visual representation of progress without actual data manipulation.
///
/// Progress is managed and communicated through [ValueNotifier], which allows other parts of
/// an application to react to changes in progress. This makes it ideal for use in user interfaces
/// that require feedback on simulated operations.
class FictionalProgress extends ChildProgress {
  int _percentage = 0;
  final List<int>
      _sizes; // List of sizes that represent the segments of data or tasks to be simulated.
  int _totalSize = 0;
  Timer? _timer;
  double _processedSize = 0.0;
  ValueNotifier<double> processedSizeNotifier;
  Completer<void> _completer = Completer<void>();
  late double processingLenghtPerS;
  late int _updateIntervalMs;
  late double _targetSize;
  bool isShowDebugPeriodicUpdate;

  /// Creates a [FictionalProgress] with a list of sizes.
  ///
  /// Each element in the [sizes] list represents the size of a segment of data or a task.
  /// These sizes are crucial as they define the steps and the distribution of progress
  /// during the simulation. The total size is the sum of all sizes and represents the
  /// full scope of the simulated task or data.
  ///
  /// The [uniqueName] parameter can be used to uniquely identify the instance
  /// for debugging purposes.
  FictionalProgress(
    List<int> sizes, {
    super.uniqueName,
    this.isShowDebugPeriodicUpdate = false,
  })  : _sizes = sizes.isNotEmpty ? sizes : [0],
        processedSizeNotifier = ValueNotifier<double>(0) {
    if (_sizes.any((size) => size < 0)) {
      throw ArgumentError('List contains negative values.');
    }
    _totalSize = _sizes.reduce((a, b) => a + b);
  }

  /// Returns the current progress percentage.
  int get getPercentage => _percentage;

  /// Returns the total size processed so far.
  double get getProcessedSize => _processedSize;

  /// Returns the total size.
  int get getTotalSize => _totalSize;

  /// Returns a list of sizes, where each size represents a stage of processing.
  List get getSizes => _sizes;

  // Setter method: sets the value of _updateIntervalMs and restarts the timer if it is already running.
  set setUpdateIntervalMs(int value) {
    _updateIntervalMs = value;
    if (_timer != null) {
      _restartTimer();
    }
  }

  /// Returns the current process index level based on the processed size.
  ///
  /// This indicates which level of the process the current size has reached.
  /// Each index corresponds to a segment in the [sizes] list, and moving to the next
  /// index means that segment has been fully simulated.
  int get getCurrentProcessIndexLevel {
    int size = 0;
    for (int i = 0; i < _sizes.length; i++) {
      size += _sizes[i];
      if (_processedSize < size) {
        return i - 1;
      } else if (_processedSize == size) {
        return i;
      }
    }
    return -1; // Returns -1 if all elements are smaller than processedSize
  }

  /// Simulates finishing the progress up to a certain process index level.
  ///
  /// The [processIndexLevel] parameter indicates the target process level.
  /// The [processingLenghtPerS] parameter defines the lenght of processing per second,
  /// which is a simulated rate of data processing or task completion.
  /// The [updateIntervalMs] parameter specifies the update interval in milliseconds.
  Future<void> finishProgressUpToIndexLevel({
    required int processIndexLevel,
    required double processingLenghtPerS,
    required int updateIntervalMs,
  }) async {
    _stopTimer(); // Cancel the previous timer
    if (!_completer.isCompleted) {
      _completer.complete(); // Complete the previous operation
    }
    _completer = Completer<void>();
    this.processingLenghtPerS = processingLenghtPerS;
    _updateIntervalMs = updateIntervalMs;
    _targetSize = 0;
    processIndexLevel = _getRealIndex(processIndexLevel);
    for (int i = 0; i <= processIndexLevel; i++) {
      _targetSize += _sizes[i];
    }
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}finishProgressUpToIndexLevel started with : $_percentage");
    _startTimer();
    await _completer.future;
  }

  Future<void> waitFinishProgressUpToIndexLevel() async {
    await _completer.future;
  }

  /// Completes the progress up to and including the specified index level, setting the percentage accordingly.
  /// If no index level is specified, completes the entire progress.
  /// Completes the `finishProgressUpToIndexLevel` future.

  void completeProgress({int? upToIndexLevel}) {
    _stopTimer(); // Ensure the timer is stopped before setting progress to complete
    if (!_completer.isCompleted) {
      _completer.complete();
    }
    if (upToIndexLevel != null) {
      _targetSize = 0;
      upToIndexLevel = _getRealIndex(upToIndexLevel);
      for (int i = 0; i <= upToIndexLevel; i++) {
        _targetSize += _sizes[i];
      }
    } else {
      _targetSize = _totalSize.toDouble();
    }
    _processedSize = _targetSize;
    _percentage =
        ((_processedSize / (_totalSize == 0 ? _processedSize : _totalSize)) *
                100)
            .round();
    percentageNotifier.value = _percentage;
    processedSizeNotifier.value = _processedSize;
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Progress complete.");
  }

  void updateToProcessedTotalSize(double newProcessedSize) {
    if (_timer != null && _timer!.isActive && newProcessedSize < _targetSize) {
      _processedSize = newProcessedSize;
    } else {
      // _timer will stop and close because it won't run when newProcessedSize > _targetSize.
      if (newProcessedSize > _totalSize) {
        newProcessedSize = _totalSize.toDouble();
      } // to prevent errors.
      _targetSize = newProcessedSize;
      _processedSize = _targetSize;
      _percentage = ((_processedSize / _totalSize) * 100).round();
      percentageNotifier.value = _percentage;
      processedSizeNotifier.value = _processedSize;
    }
  }

  /// Starts the timer to manage smooth progress updates. This method schedules periodic updates
  /// to simulate progress based on the predefined sizes and processing rate.
  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _updateIntervalMs), (timer) {
      if (_processedSize < _targetSize) {
        _processedSize += processingLenghtPerS * (_updateIntervalMs / 1000);
        if (_processedSize > _targetSize) {
          _processedSize = _targetSize;
        }
        _percentage = ((_processedSize / _totalSize) * 100).round();
        percentageNotifier.value = _percentage;
        processedSizeNotifier.value = _processedSize;
        if (isShowDebugPeriodicUpdate) {
          printDebugInfo(
              "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Processing size: $_processedSize, Percentage: $_percentage");
        }
      } else {
        printDebugInfo(
            "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Target Finished and percentage reached: $_percentage");
        _stopTimer();
        if (!_completer.isCompleted) {
          _completer.complete();
        }
      }
    });
  }

  /// Restarts the timer.
  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  /// Stops the active timer to halt progress updates. This is typically called when the progress
  /// reaches its target or when resetting the progress.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resets the simulated progress to zero and can reinitialize with [newSizes] if provided.
  /// This method effectively restarts the simulation from scratch.
  void resetProgress({List<int>? newSizes}) {
    _stopTimer(); // Cancel the previous timer
    if (!_completer.isCompleted) {
      _completer.complete();
    }
    _percentage = 0;
    _processedSize = 0.0;
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Progress reset to zero");
    if (newSizes != null) {
      _sizes.clear();
      newSizes = newSizes.isNotEmpty ? newSizes : [0];
      if (_sizes.any((size) => size < 0)) {
        throw ArgumentError('List contains negative values.');
      }
      _sizes.addAll(newSizes);
      _totalSize = _sizes.reduce((a, b) => a + b);
      printDebugInfo(
          "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}New Sizes List Initialized: ${newSizes.join(', ')}");
    }
    percentageNotifier.value = _percentage;
    processedSizeNotifier.value = _processedSize;
  }

  int _getRealIndex(int index) {
    if (index < 0) {
      // Eğer negatif bir indeks verilmişse, gerçek indeksi hesapla
      return _sizes.length + index;
    } else {
      // Eğer pozitif bir indeks verilmişse, direkt olarak onu döndür
      return index;
    }
  }

  /// Disposes the progress and releases all resources.
  void dispose() {
    _stopTimer();
    if (!_completer.isCompleted) {
      _completer.complete();
    }
    percentageNotifier.dispose();
    processedSizeNotifier.dispose();
    printDebugInfo(
        "FictionalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}FictionalProgress disposed.");
  }
}
