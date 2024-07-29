import 'dart:async';
import 'dart:math';
import 'package:parent_progress/src/child_progress.dart';
import 'debug_helpers.dart';

/// A class that tracks and notifies the progress of a task based on the work done compared to the total work.
/// It uses percentage values to represent progress and can handle both byte-level progress and other units of work.
class RationalProgress extends ChildProgress {
  double _totalWork;
  double _currentWork = 0;
  double _currentPercentage = 0;
  double _targetPercentage = 0;
  Timer? _smoothUpdateTimer;
  int smoothUpdateInterval;
  Completer<void>? _completer;
  bool isShowDebugSmoothUpdater;

  /// Constructs a [RationalProgress].
  ///
  /// The [totalWork] parameter specifies the total amount of work to be done.
  /// The [uniqueName] can be used for logging and identifying the progress.
  /// The [smoothUpdateInterval] sets how frequently (in milliseconds) the smooth progress update should occur.
  RationalProgress({
    super.uniqueName,
    required double totalWork,
    this.smoothUpdateInterval = 50, // default value set to 50 milliseconds
    this.isShowDebugSmoothUpdater = false,
  }) : _totalWork = totalWork;

  /// Returns the current percentage of work completed.
  double get getCurrentPercentage => _currentPercentage;

  /// Returns the target percentage calculated from the current work done.
  double get getTargetPercentage => _targetPercentage;

  /// Returns the amount of work completed so far.
  double get getCurrentWork => _currentWork;

  /// Returns the total amount of work that needs to be done.
  double get getTotalWork => _totalWork;

  /// Updates the amount of work done and recalculates the target percentage.
  ///
  /// Optionally, the total amount of work can be adjusted by providing [newTotalWork].
  Future<void> currentWorkDone(
    double workDone, {
    double? newTotalWork,
  }) async {
    if (newTotalWork != null) _totalWork = newTotalWork;
    _smoothUpdateTimer?.cancel(); // Existing timer is canceled if any
    _smoothUpdateTimer = null;
    _completer?.complete(); // Complete the previous operation
    _currentWork = workDone;
    _calculateTargetPercentage();
    await _startSmoothUpdate();
  }

  /// Calculates the target percentage based on the current and total work.
  void _calculateTargetPercentage() {
    _targetPercentage = (_currentWork / _totalWork) * 100;
  }

  /// Starts or restarts a timer for smooth progress updates.
  Future<void> _startSmoothUpdate() async {
    _completer = Completer<void>();

    _smoothUpdateTimer =
        Timer.periodic(Duration(milliseconds: smoothUpdateInterval), (timer) {
      double difference = _targetPercentage - _currentPercentage;
      if (difference.abs() < 1 || smoothUpdateInterval == 0) {
        _currentPercentage = _targetPercentage;
        timer.cancel();
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
    await _completer?.future;
    _completer = null;
  }

  /// Resets the progress to zero and optionally sets a new total amount of work.
  void resetProgress({double? newTotalWork}) {
    _smoothUpdateTimer?.cancel(); // Cancel the previous timer
    _smoothUpdateTimer = null;
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

  /// Marks the progress as complete.
  void doneProgress() {
    _smoothUpdateTimer?.cancel(); // Cancel the previous timer
    _smoothUpdateTimer = null;
    _completer?.complete(); // Complete the previous operation
    _currentWork = _totalWork;
    _currentPercentage = 100;
    _targetPercentage = 100;
    percentageNotifier.value = 100;
    printDebugInfo(
        "RationalProgress ${uniqueName != null ? '${uniqueName!}: ' : ''}Progress done");
  }

  /// Disposes the progress and releases all resources.
  void dispose() {
    _smoothUpdateTimer?.cancel();
    percentageNotifier.dispose();
  }
}
