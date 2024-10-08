## 0.4.1

* bug fixed fictional_progress

## 0.3.9

* bug fixed getCurrentProcessIndexLevel in fictional_progress
* bug fixed updateToProcessedTotalSize in fictional_progress
* bug fixed currentWorkDone in rational_progress

## 0.3.8

* updateToProcessedTotalSize added to FictionalProgress.

## 0.3.7

* Changed processingRatePerS Name in Fictional Progress as processingLenghtPerS

## 0.3.6

* getTargetPercentage, getCurrentPercentage getters converted to int

## 0.3.5

* added braces for clean code

## 0.3.4

* improved race conditions

## 0.3.3

* bug fixed on rational progress

## 0.3.2

* bug fixed

## 0.3.0

* Added addSlice and deleteSlice functionality to ParentProgress and removed the Slices list. Improved the algorithm.

## 0.2.3

* In the RationalProgress class, the currentWorkDone method has been updated to improve race conditions.

## 0.2.2

* bug fixed

## 0.2.1

* null safety

## 0.2.0

* Added completeProgress method to FictionalProgress class.
This method allows completing the progress up to and including a specified index level.
If no index level is specified, the entire progress is completed.
Includes updating the _targetSize, _processedSize, _percentage, and notifying listeners via percentageNotifier and processedSizeNotifier.

## 0.1.5

* Added setSmoothUpdateInterval setter in the RationalProgress class.
* Descriptions added or updated to improve understanding of your code.
* Example project recompiled under a single main.dart.

## 0.1.0

* The smoothUpdateInterval default value in the RationalProgress class has been updated from 200 to 50.
* The isShowDebugSmoothUpdater option has been added to the RationalProgress class.
* The debug content in each _smoothUpdateTimer loop in the RationalProgress class has been updated from "Current Percentage" to "Smoother Percentage".
* An example project has been added to the example directory.
* The values of processingRatePerS and updateIntervalMs in the FictionalProgress class can now be changed through the class instance.
* The isShowDebugPeriodicUpdate option has been added to the FictionalProgress class.
* The processedSizeNotifier has been added to the FictionalProgress class.
* The sizes getter and setUpdateIntervalMs setter have been added to the FictionalProgress class.
* An abstract ChildProgress class encompassing all classes has been created. The percentageNotifier and uniqueName parameters will be managed from here.
* Instead of a notifier list, the ParentProgress class will now take a list of type ChildProgress called children.

## 0.0.1

* initial release.
