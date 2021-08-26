import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> getUserConnected() {
    return _firebaseAuth.authStateChanges();
  }

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(_firebaseAuth.currentUser != null);
    return completer.future;
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
