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
    Completer<bool> completer = Completer();
    completer.complete(FirebaseAuth.instance.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    Completer<bool> completer = Completer<bool>();
    FirebaseAuth.instance.signOut().then((value) => completer.complete(true)).catchError((error) => completer.completeError(false));
    return completer.future;
  }

  setError(String error) {
    _streamError?.sink.add(error);
  }

  cleanError() {
    _streamError?.sink.add("");
  }

  changeEmail(String value) {
    _authParam.email = value;
  }

  changePassword(String value) {
    _authParam.password = value;
  }

  Future<UserCredential> login() {
    print('test');
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: _authParam.email, password: _authParam.password);
  }
}
