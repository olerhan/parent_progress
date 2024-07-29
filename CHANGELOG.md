## 0.1.1

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
