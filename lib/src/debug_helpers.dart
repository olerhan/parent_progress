import 'package:flutter/foundation.dart';

/// Prints debug information if in debug mode with a timestamp.
void printDebugInfo(String? message) {
  if (kDebugMode) {
    // Debug mod kontrolü eklendi
    DateTime now = DateTime.now();
    String time =
        '◷[${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}]';

    // Null kontrolü message için eklendi
    if (message != null) {
      debugPrint("$time $message");
    }
  }
}
