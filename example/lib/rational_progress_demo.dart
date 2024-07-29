import 'package:flutter/material.dart';
import 'package:parent_progress/parent_progress.dart';

class RationalProgressDemo extends StatefulWidget {
  final RationalProgress
      rationalProgress; // RationalProgress nesnesini üst widget'tan alacak şekilde güncelleme

  const RationalProgressDemo({
    super.key,
    required this.rationalProgress, // Dependency injection via constructor
  });

  @override
  State<RationalProgressDemo> createState() => _RationalProgressDemoState();
}

class _RationalProgressDemoState extends State<RationalProgressDemo> {
  late RationalProgress rationalProgress;
  double _sliderValue = 0.0; // Independent state variable for the slider

  @override
  void initState() {
    super.initState();
    rationalProgress = widget.rationalProgress;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
            valueListenable: rationalProgress.percentageNotifier,
            builder: (_, currentPercentage, __) {
              return Column(children: [
                Text('Rational Progress Value: $currentPercentage%'),
                LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  value: currentPercentage / 100.0,
                  minHeight: 20,
                  borderRadius: BorderRadius.circular(8),
                ),
              ]);
            }),
        Text(
            '${_sliderValue.toStringAsFixed(0)} MB / ${rationalProgress.getTotalWork.toStringAsFixed(0)} MB'), // Displaying the current value of the slider
        Slider(
          min: 0,
          max: rationalProgress.getTotalWork,
          value: _sliderValue,
          onChanged: (value) {
            setState(() {
              _sliderValue = value; // Update slider value
            });
            rationalProgress.currentWorkDone(value);
          },
          inactiveColor: Colors.greenAccent.withOpacity(0.1),
        ),
        ElevatedButton(
          child: const Text("Reset Rational Progress"),
          onPressed: () {
            setState(() {
              _sliderValue = 0; // Resetting slider value
            });
            rationalProgress.resetProgress();
          },
        ),
      ],
    );
  }
}
