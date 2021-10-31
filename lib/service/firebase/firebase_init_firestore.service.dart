import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseInitFirestoreService extends GetxService {
  FirebaseInitFirestoreService({this.emulate = false});

  final bool emulate;

  ///
  /// A l'initialisation du service
  /// si le dev mode est activé, on va se brancher sur l'émulator.
  ///
  @override
  void onInit() {
    super.onInit();

    if (emulate) {
      developer.log(
        '[WARNING] Application launched with emulate mode : Firebase Firestore emulator will be used.',
        level: 100,
      );

      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    }
  }
}
