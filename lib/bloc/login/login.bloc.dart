import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/auth.service.dart';
import 'package:rxdart/rxdart.dart';

class AuthParam {
  AuthParam({this.email = '', this.password = ''});

  String email;
  String password;
}

class LoginBloc {
  LoginBloc._() {
    _streamError = BehaviorSubject<String?>.seeded(null);
  }

  static LoginBloc? _instance;

  static LoginBloc getInstance() {
    _instance ??= LoginBloc._();
    return _instance!;
  }

  final AuthService authService = AuthService.getInstance();

  final AuthParam _authParam = AuthParam();
  BehaviorSubject<String?>? _streamError;

  Stream<String?>? get errorsObservable => _streamError?.stream;

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(FirebaseAuth.instance.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    final Completer<bool> completer = Completer<bool>();
    FirebaseAuth.instance.signOut()
        .then((_) => completer.complete(true))
        .catchError((Object error) => completer.completeError(false));
    return completer.future;
  }

  void setError(String error) {
    _streamError?.sink.add(error);
  }

  void cleanError() {
    _streamError?.sink.add('');
  }

  set email(String value) {
    _authParam.email = value;
  }

  String get email {
    return _authParam.email;
  }

  set password(String value) {
    _authParam.password = value;
  }

  String get password {
    return _authParam.password;
  }

  Future<UserCredential> login() {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: _authParam.email, password: _authParam.password);
  }

  Future<UserCredential> signUp() {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: _authParam.email, password: _authParam.password);
  }
}
