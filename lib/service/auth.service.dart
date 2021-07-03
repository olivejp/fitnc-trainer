import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  static AuthService _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User _user;
  BehaviorSubject<User> _streamUser;

  Observable<User> get userObservable => _streamUser.stream;

  // Private constructor with the ._()
  AuthService._() {
    _streamUser = BehaviorSubject(seedValue: null);

    // Listen for user update.
    _firebaseAuth.idTokenChanges().listen((User user) {
      _updateUser(user);
    });
  }

  static AuthService getInstance() {
    if (_instance == null) {
      _instance = AuthService._();
    }
    return _instance;
  }

  void _updateUser(User user) {
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
      _updateUser(null);
      completer.complete(true);
    }).catchError((error) => completer.completeError(false));
    return completer.future;
  }

  dispose() {
    _streamUser.close();
  }
}
