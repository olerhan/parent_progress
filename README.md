# Parent Progress

This package provides a robust framework for managing and tracking progress across multiple tasks or operations in Flutter applications. It features three main classes: `FictionalProgress`, `RationalProgress`, and `ParentProgress`, designed to handle complex progress tracking scenarios.

## Features

- **FictionalProgress**
  - Simulates progress for scenarios where actual data processing details are abstracted.
  - Useful for representing progress when exact data or task completion metrics are not available.
- **RationalProgress**
  - Tracks actual progress based on real data processing or task completion.
  - Suitable for scenarios where precise tracking of completed vs. total work is required.
- **ParentProgress**
  - Aggregates progress from multiple child progresses using a weighted system.
  - Provides a comprehensive overview of progress across various components or modules.

## Getting Started

To use this package in your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  parent_progress: ^0.0.1
```
## Usage

### FictionalProgress
`FictionalProgress` is used to simulate progress based on predefined sizes. It's ideal for use cases where progress needs to be demonstrated but actual metrics are abstract or not directly measurable.

```dart
List<int> sizes = [10, 20, 30]; // Each number represents a segment of the task
FictionalProgress progress = FictionalProgress(sizes);

// Start the simulation of progress
progress.finishProgressUpToIndexLevel(
    processIndexLevel: 1, 
    processingRatePerS: 5, 
    updateIntervalMs: 100);
```

### RationalProgress
Use `RationalProgress` to track real-time progress of a measurable task or data processing activity. This progress is perfect for applications that require precise progress tracking.

```dart
RationalProgress progress = RationalProgress(totalWork: 100);

// Update the progress as the task progresses
progress.currentWorkDone(50); // 50% of the work is done

// Get the current progress
print("Current progress: ${progress.getCurrentPercentage}%");
```

### ParentProgress
`ParentProgress` allows you to aggregate progress from multiple progresses. This is useful for complex applications where different modules or components report progress independently.

```dart
// Create individual progresses
FictionalProgress child1 = FictionalProgress([50, 50]);
FictionalProgress child2 = FictionalProgress([30, 70]);

// List of notifiers and their corresponding weights
List<ValueNotifier<int>> notifiers = [child1.percentageNotifier, child2.percentageNotifier];
List<int> weights = [1, 2];

// Create the parent progress
ParentProgress parentProgress = ParentProgress(notifiers, weights);

// Example to update and retrieve total progress
child1.finishProgressUpToIndexLevel(processIndexLevel: 0, processingRatePerS: 10, updateIntervalMs: 100);
child2.finishProgressUpToIndexLevel(processIndexLevel: 1, processingRatePerS: 20, updateIntervalMs: 200);
print("Total aggregated progress: ${parentProgress.totalPercentageNotifier.value}%");
```

## Contributing

Contributions are welcome! Feel free to fork the repository, make changes, and submit pull requests. If you find any issues or have suggestions, please open an issue in the repository.

## License

This package is released under the MIT License, which allows for personal and commercial use, modification, distribution, and private use.

## Acknowledgments

This package is in its early stages, and we welcome contributions and feedback from the Flutter community. As it grows and evolves, we look forward to acknowledging all who contribute to its development.