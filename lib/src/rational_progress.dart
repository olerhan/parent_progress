import 'dart:async';
import 'dart:math';
import 'package:parent_progress/src/child_progress.dart';
import 'debug_helpers.dart';

/// A class that tracks and notifies the progress of a task by measuring the amount of work completed
/// relative to the total required work. This class is useful for monitoring progress in tasks where
/// progress can be quantified, such as data processing, file uploads, or long-running computations.
///
/// The class uses percentage values to represent progress, providing a universal measure that can be
/// easily understood and displayed in user interfaces. It is designed to handle various units of work,
/// from bytes in file operations to abstract units in custom processes, making it versatile for a range
/// of applications.
///
/// Features include:
/// - Real-time progress updates through a [ValueNotifier] that others can subscribe to for UI updates.
/// - Capability to adjust the total amount of work dynamically, allowing for flexible task management.
/// - Smooth progress updates option, which can help in creating smoother visual transitions in progress bars.
class RationalProgress extends ChildProgress {
  double _totalWork;
  double _currentWork = 0;
  double _currentPercentage = 0;
  double _targetPercentage = 0;
  Timer? _timer;
  int _smoothUpdateInterval;
  Completer<void>? _completer;
  bool isShowDebugSmoothUpdater;

  /// Constructs a [RationalProgress].
  ///
  /// The [totalWork] parameter specifies the total amount of work to be done.
  /// The [uniqueName] can be used for logging and identifying the progress.
  /// The [smoothUpdateInterval] sets how frequently (in milliseconds) the smooth progress update should occur.
  /// To disable the smooth feature, set [smoothUpdateInterval] to 0.
  RationalProgress({
    super.uniqueName,
    required double totalWork,
    int smoothUpdateInterval = 50, // default value set to 50 milliseconds
    this.isShowDebugSmoothUpdater = false,
  })  : _totalWork = totalWork,
        _smoothUpdateInterval = smoothUpdateInterval {
    if (_totalWork <= 0 || _currentWork <= 0) {
      throw ArgumentError('List contains negative values.');
    }
  }

  /// Returns the current percentage of work completed.
  double get getCurrentPercentage => _currentPercentage;

  /// Returns the target percentage calculated from the current work done.
  double get getTargetPercentage => _targetPercentage;

  /// Returns the amount of work completed so far.
  double get getCurrentWork => _currentWork;

  /// Returns the total amount of work that needs to be done.
  double get getTotalWork => _totalWork;

  /// Sets the smooth update interval in milliseconds and restarts the timer if it is already running.
  /// This allows for dynamic adjustments to the frequency of progress updates based on runtime conditions.
  set setSmoothUpdateInterval(int value) {
    _smoothUpdateInterval = value;
    if (_timer != null) {
      _restartTimer();
    }
  }

  /// Updates the amount of work done and recalculates the target percentage.
  ///
  /// Optionally, the total amount of work can be adjusted by providing [newTotalWork].
  Future<void> currentWorkDone(
    double workDone, {
    double? newTotalWork,
  }) async {
    if (newTotalWork != null) _totalWork = newTotalWork;
    _stopTimer(); // Existing timer is canceled if any
    _completer?.complete(); // Complete the previous operation
    _currentWork = workDone;
    if (_totalWork != 0) {
      _targetPercentage = (_currentWork / _totalWork) *
          100; // Calculates the target percentage based on the current and total work.
      await _startSmoothUpdate();
    } else {
      doneProgress();
    }
  }

  /// Initiates or restarts the smooth update mechanism. This process incrementally updates the progress percentage
  /// towards the target, smoothing out the visual representation of progress changes.
  Future<void> _startSmoothUpdate() async {
    _completer = Completer<void>();
    _startTimer();
    await _completer?.future;
    _completer = null;
  }

  /// Resets the progress to zero and optionally sets a new total amount of work.
  void resetProgress({double? newTotalWork}) {
    _stopTimer(); // Cancel the previous timer
    _completer?.complete(); // Complete the previous operation
    _currentWork = 0;
    _currentPercentage = 0;
    _targetPercentage = 0;
    printDebugInfo(
        "RationalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Progress reset to zero");
    if (newTotalWork != null) {
      _totalWork = newTotalWork;
      printDebugInfo(
          "RationalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}New Total Work Initialized: $newTotalWork");
    }
    percentageNotifier.value = _currentPercentage.round();
  }

  /// Completes the progress at the current work amount, setting the percentage to 100% and ensuring no further updates.
  /// Completes the `currentWorkDone` future.
  void doneProgress() {
    _stopTimer(); // Ensure the timer is stopped before setting progress to complete
    _completer?.complete(); // Complete any pending operations
    _currentWork = _totalWork;
    _currentPercentage = 100;
    _targetPercentage = 100;
    percentageNotifier.value =
        100; // Notify all listeners that the progress is complete
    printDebugInfo(
        "RationalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Progress done");
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _smoothUpdateInterval), (_) {
      double difference = _targetPercentage - _currentPercentage;
      if (difference.abs() < 1 || _smoothUpdateInterval == 0) {
        _currentPercentage = _targetPercentage;
        _stopTimer();
        percentageNotifier.value = _currentPercentage.round();
        printDebugInfo(
            'RationalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Smoother Reached Target Percentage: ${percentageNotifier.value}');
        _completer?.complete();
      } else {
        double scale = min(1 / (log(difference.abs())), 1);
        double increment = difference * scale;
        if (increment.abs() < 1) {
          increment =
              increment.sign; // Ensure at least a minimum of 1 unit change
        }
        _currentPercentage += increment;
        percentageNotifier.value = _currentPercentage.round();
        if (isShowDebugSmoothUpdater) {
          printDebugInfo(
              'RationalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Smoother Percentage: ${percentageNotifier.value}');
        }
      }
    });
  }

  /// Restarts the timer with the current settings for the smooth update interval. This method is used internally
  /// to apply changes to the timer's interval without stopping the progress tracking.
  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  /// Stops the active timer, halting any ongoing smooth progress updates. This method ensures that no further updates
  /// are made to the progress after it's called, typically in preparation for a reset or when the task is completed.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes the progress and releases all resources.
  void dispose() {
    _stopTimer();
    percentageNotifier.dispose();
  }
}
