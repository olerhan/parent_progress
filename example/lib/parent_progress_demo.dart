import 'package:example/fictional_progress_demo.dart';
import 'package:example/rational_progress_demo.dart';
import 'package:flutter/material.dart';
import 'package:parent_progress/parent_progress.dart';

class ParentProgressDemo extends StatefulWidget {
  const ParentProgressDemo({super.key});

  @override
  State<ParentProgressDemo> createState() => _ParentProgressDemoState();
}

class _ParentProgressDemoState extends State<ParentProgressDemo> {
  late FictionalProgress _fictionalProgress;
  late RationalProgress _rationalProgress;
  late ParentProgress _parentProgress;

  @override
  void initState() {
    super.initState();
    _fictionalProgress =
        FictionalProgress([10, 20, 30, 40], uniqueName: "Fictional Progress");
    _rationalProgress = RationalProgress(
        totalWork: 100.0,
        smoothUpdateInterval: 50,
        uniqueName: "Rational Progress");

    // ParentProgress initialization with the notifiers from both progress indicators
    _parentProgress = ParentProgress(
      [_fictionalProgress, _rationalProgress],
      [60, 40], // Assuming equal weight for simplicity
    );
  }

  @override
  void dispose() {
    _fictionalProgress.dispose();
    _rationalProgress.dispose();
    _parentProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _parentProgress.percentageNotifier,
              builder: (_, totalPercentage, __) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text('Parent Progress Value: $totalPercentage%'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.greenAccent.withOpacity(0.1),
                          value: totalPercentage / 100.0,
                          strokeWidth: 8.0,
                        ),
                      ),
                      Text(
                          '${_parentProgress.getChildren[0].uniqueName} Factor: ${_parentProgress.getFlexFactors[0]}'),
                      Text(
                          '${_parentProgress.getChildren[1].uniqueName} Factor: ${_parentProgress.getFlexFactors[1]}'),
                    ],
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                thickness: 10,
                color: Colors.black,
              ),
            ),
            Expanded(
                flex: 24,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FictionalProgressDemo(
                      fictionalProgress: _fictionalProgress),
                )),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                thickness: 10,
                color: Colors.black,
              ),
            ),
            Expanded(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child:
                      RationalProgressDemo(rationalProgress: _rationalProgress),
                )),
          ],
        ),
      ),
    );
  }
}
