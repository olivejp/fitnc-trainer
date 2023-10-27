import 'package:flutter/foundation.dart';

class DebugPrinter {
  static printLn(Object? message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
