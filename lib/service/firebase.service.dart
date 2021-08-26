import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  Future<FirebaseApp> initialize() {
    return Firebase.initializeApp().catchError((Object? error) => Future.error('Erreur lors de linitialisation de Firebase : $error'));
  }
}
