import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  static AuthService? _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  late BehaviorSubject<User?> _streamUser;

  Stream<User?> get userStream => _streamUser.stream;

  AuthService._() {
    _streamUser = BehaviorSubject.seeded(null);
  }

  static AuthService getInstance() {
    if (_instance == null) {
      _instance = AuthService._();
    }
    return _instance!;
  }

  void updateUser(User? user) {
    _user = user;
    _streamUser.sink.add(_user);
  }

  Future<dynamic> isConnected() {
    Completer completer = Completer();
    completer.complete(_firebaseAuth.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    Completer<bool> completer = Completer<bool>();
    _firebaseAuth.signOut().then((value) {
      updateUser(null);
      completer.complete(true);
    }).catchError((error) => completer.completeError(false));
    return completer.future;
  }

  dispose() {
    _streamUser.close();
  }
}
