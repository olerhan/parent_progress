import 'package:flutter/material.dart';
import 'package:parent_progress/parent_progress.dart';

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

  double _processingRatePerS = 5.0; // Amount processed per second, adjustable.
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
      processingRatePerS: _processingRatePerS,
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
          label: 'Processing rate: $_processingRatePerS units/s',
          value: _processingRatePerS,
          onChanged: (double value) {
            setState(() {
              fictionalProgress.processingRatePerS = value;
              _processingRatePerS = value;
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
                  processingRatePerS: _processingRatePerS,
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
