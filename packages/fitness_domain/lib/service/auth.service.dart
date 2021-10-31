import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  AuthService({this.emulate = false});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
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
        '[WARNING] Application launched with emulate mode : Firebase Auth emulator will be used.',
        level: 100,
      );

      _firebaseAuth.useAuthEmulator('localhost', 9099);
    }
  }

  ///
  /// Méthode static permettant de savoir si un utilisateur est connecté ou pas.
  ///
  static User getUserConnectedOrThrow() {
    final User? user = getUserConnected();
    if (user == null) {
      throw Exception('No user connected');
    } else {
      return user;
    }
  }

  ///
  /// Méthode static permettant de récupérer l'utilisateur connecté.
  /// Si aucun utilisateur connecté renvoie null.
  ///
  static User? getUserConnected() {
    return FirebaseAuth.instance.currentUser;
  }

  bool isConnected() {
    return getUserConnected() != null;
  }

  Stream<User?> listenUserConnected() {
    return _firebaseAuth.authStateChanges();
  }

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
