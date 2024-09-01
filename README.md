<p align="center" >
  <strong>The missing piece for your Flutter progress indicators.</strong>
  <br />
  <br />
  <a href="https://pub.dev/packages/styled_widget"><img src="https://img.shields.io/pub/v/parent_progress?color=blue" /></a>
  <a href="https://github.com/olerhan/parent_progress/actions/workflows/flutter_ci.yml"><img src="https://github.com/olerhan/parent_progress/actions/workflows/flutter_ci.yml/badge.svg" /></a>
  <a href="https://github.com/olerhan/parent_progress"><img src="https://img.shields.io/github/stars/olerhan/parent_progress" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
  <br />
</p>

# Parent Progress

This package offers a solution for managing and tracking progress across multiple tasks with three main classes: `FictionalProgress`, `RationalProgress`, and `ParentProgress`. It allows each child progress to independently track and contribute to an aggregated parent progress, using `ValueNotifier<int>` for dynamic updates and UI integration. Ideal for complex progress management in modular applications.

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

## Usage

### FictionalProgress
`FictionalProgress` is used to simulate progress based on predefined sizes. It's ideal for use cases where progress needs to be demonstrated but actual metrics are abstract or not directly measurable.

```dart
List<int> sizes = [10, 20, 30]; // Each number represents a segment of the task
FictionalProgress progress = FictionalProgress(sizes);

// Start the simulation of progress
progress.finishProgressUpToIndexLevel(
    processIndexLevel: 1, 
    processingLenghtPerS: 5, 
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
RationalProgress child2 = RationalProgress(totalWork: 100);

// List of child and their corresponding weights
List<ChildProgress> children = [child1, child2];
List<int> weights = [1, 2];

// Create the parent progress
ParentProgress parentProgress = ParentProgress(children, weights);

// Example to update and retrieve total progress
child1.finishProgressUpToIndexLevel(processIndexLevel: 0, processingLenghtPerS: 10, updateIntervalMs: 100);
child2.currentWorkDone(100);
print("Total aggregated progress: ${parentProgress.percentageNotifier.value}%");
```
**For detailed demonstrations and usage scenarios, visit the examples section on our pub.dev page.**

## Support

We hope you find this package useful! If you do, please consider giving it a **like on [pub.dev](https://pub.dev/packages/parent_progress)** and starring it on [GitHub](https://github.com/olerhan/parent_progress) to help others discover it. Your support greatly encourages the maintainers to continue developing and improving this package.

## Contributing

Contributions are welcome! Feel free to fork the repository, make changes, and submit pull requests. If you find any issues or have suggestions, please open an issue in the repository.

## License

This package is released under the MIT License, which allows for personal and commercial use, modification, distribution, and private use.

## Acknowledgments

This package is in its early stages, and we welcome contributions and feedback from the Flutter community. As it grows and evolves, we look forward to acknowledging all who contribute to its development.
