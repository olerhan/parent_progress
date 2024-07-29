import 'package:flutter/material.dart';

/// An abstract class serving as a base for various types of progress trackers.
///
/// This class standardizes the interface for all progress tracking mechanisms,
/// facilitating the creation of composite progress trackers, such as `ParentProgress`,
/// which may aggregate multiple progress updates from diverse sources.
///
/// Features include:
/// - A `percentageNotifier` that observers can listen to for real-time progress updates.
///   This notifier supports synchronous UI updates and inter-process communication.
/// - An optional `uniqueName` that helps in identifying instances when debugging or logging,
///   especially useful when multiple trackers operate concurrently.
///
/// `ChildProgress` is designed to be extended by specific progress tracking implementations
/// like `FictionalProgress` or `RationalProgress`, allowing `ParentProgress` to uniformly
/// handle diverse progress sources. It ensures that `ParentProgress` can interact with any
/// progress tracker that extends this class, using their notifiers and names for efficient
/// progress management and tracking.
abstract class ChildProgress {
  String? uniqueName;
  final ValueNotifier<int> percentageNotifier;

  ChildProgress({this.uniqueName}) : percentageNotifier = ValueNotifier<int>(0);
}
