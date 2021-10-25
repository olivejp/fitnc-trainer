import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  Future<FirebaseApp> initialize() {
    return Firebase.initializeApp().catchError(
      (Object? error) => Future<FirebaseApp>.error('Error while initializing Firebase : $error'),
    );
  }
}
