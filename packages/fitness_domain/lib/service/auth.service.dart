import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  bool isConnected() {
    return _firebaseAuth.currentUser != null;
  }

  Stream<User?> listenUserConnected() {
    return _firebaseAuth.authStateChanges();
  }

  Future<bool> isFutureConnected() {
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
