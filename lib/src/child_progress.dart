import 'package:flutter/material.dart';

abstract class ChildProgress {
  String? uniqueName;
  final ValueNotifier<int> percentageNotifier;

  ChildProgress({this.uniqueName}) : percentageNotifier = ValueNotifier<int>(0);
}
