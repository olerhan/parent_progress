import 'package:flutter/material.dart';
import 'package:parent_progress/parent_progress.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.greenAccent,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const ParentProgressDemo(),
    );
  }
}

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Card(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _parentProgress.percentageNotifier,
                      builder: (_, totalPercentage, __) {
                        return Column(
                          children: [
                            Text('Parent Progress Value: $totalPercentage%'),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(
                                backgroundColor:
                                    Colors.greenAccent.withOpacity(0.1),
                                value: totalPercentage / 100.0,
                                strokeWidth: 8.0,
                              ),
                            ),
                            Text(
                                '${_parentProgress.getChildren[0].uniqueName} Factor: ${_parentProgress.getFlexFactors[0]}'),
                            Text(
                                '${_parentProgress.getChildren[1].uniqueName} Factor: ${_parentProgress.getFlexFactors[1]}'),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              SizedBox(
                height: 400,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FictionalProgressDemo(
                        fictionalProgress: _fictionalProgress),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      RationalProgressDemo(rationalProgress: _rationalProgress),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FictionalProgressDemo extends StatefulWidget {
  final FictionalProgress
      fictionalProgress; // FictionalProgress nesnesini üst widget'tan alacak şekilde güncelleme

  const FictionalProgressDemo({
    super.key,
    required this.fictionalProgress, // Dependency injection via constructor
  });

  @override
  State<FictionalProgressDemo> createState() => _FictionalProgressDemoState();
}

class _FictionalProgressDemoState extends State<FictionalProgressDemo> {
  late FictionalProgress fictionalProgress;

  double _processingLenghtPerS =
      5.0; // Amount processed per second, adjustable.
  int _updateIntervalMs = 50; // Update interval in milliseconds, adjustable.

  @override
  void initState() {
    super.initState();
    fictionalProgress = widget.fictionalProgress;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startProgressSimulation(int index) {
    fictionalProgress.finishProgressUpToIndexLevel(
      processIndexLevel: index,
      processingLenghtPerS: _processingLenghtPerS,
      updateIntervalMs: _updateIntervalMs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: fictionalProgress.percentageNotifier,
          builder: (_, percentage, __) {
            return Column(
              children: [
                Text('Fictional Progress Value: $percentage%'),
                LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  value: percentage / 100.0,
                  minHeight: 20,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            );
          },
        ),
        ValueListenableBuilder<double>(
          valueListenable: fictionalProgress.processedSizeNotifier,
          builder: (_, processedSize, __) {
            return Text(
                '${processedSize.toStringAsFixed(2)} / ${fictionalProgress.getTotalSize} units');
          },
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          label: 'Processing rate: $_processingLenghtPerS units/s',
          value: _processingLenghtPerS,
          onChanged: (double value) {
            setState(() {
              fictionalProgress.processingLenghtPerS = value;
              _processingLenghtPerS = value;
            });
          },
          inactiveColor: Colors.greenAccent.withOpacity(0.1),
        ),
        Slider(
          min: 20,
          max: 1000,
          divisions: 49,
          label: 'Update interval: $_updateIntervalMs ms',
          value: _updateIntervalMs.toDouble(),
          onChanged: (double value) {
            setState(() {
              fictionalProgress.setUpdateIntervalMs = value.toInt();
              _updateIntervalMs = value.toInt();
            });
          },
          inactiveColor: Colors.greenAccent.withOpacity(0.1),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: fictionalProgress.getSizes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Simulate Progress up to step ${index + 1}'),
                subtitle: Text(
                    'Step size: ${fictionalProgress.getSizes[index]} units'),
                onTap: () => fictionalProgress.finishProgressUpToIndexLevel(
                  processIndexLevel: index,
                  processingLenghtPerS: _processingLenghtPerS,
                  updateIntervalMs: _updateIntervalMs,
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              fictionalProgress.resetProgress();
            });
          },
          child: const Text('Reset Fictional Progress'),
        ),
      ],
    );
  }
}

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
