import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/storage.service.dart';
import 'package:rxdart/rxdart.dart';

class AuthParam {
  String email;
  String password;

  AuthParam(this.email, this.password);
}

class LoginBloc {
  final StorageService storage = StorageService.getInstance();

  User _user;
  AuthParam _authParam = AuthParam(null, null);
  BehaviorSubject<User> _streamUser;
  BehaviorSubject<String> _streamError;

  Observable<User> get userObservable => _streamUser.stream;

  Observable<String> get errorsObservable => _streamError.stream;

  static LoginBloc _instance;

  // Private constructor with the ._()
  LoginBloc._() {
    _streamUser = BehaviorSubject(seedValue: null);
    _streamError = BehaviorSubject(seedValue: null);

    // Listen for user update.
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) => updateUser(user));
  }

  static LoginBloc getInstance() {
    if (_instance == null) {
      _instance = LoginBloc._();
    }
    return _instance;
  }

  Future<UserCredential> recordUserCredentialToStorage(
      UserCredential userCredential) {
    return Future<UserCredential>(() {
      if (userCredential.user.uid != null) {
        storage.setItem('userId', userCredential.user.uid);
      }
      if (userCredential.user.email != null) {
        storage.setItem('userEmail', userCredential.user.email);
      }
      if (userCredential.user.displayName != null) {
        storage.setItem('userName', userCredential.user.displayName);
      }
      if (userCredential.user.photoURL != null) {
        storage.setItem('userPhotoURL', userCredential.user.photoURL);
      }
      if (userCredential.user.phoneNumber != null) {
        storage.setItem('userPhoneNumber', userCredential.user.phoneNumber);
      }
      return userCredential;
    });
  }

  void updateUser(User user) {
    _user = user;
    _streamUser.sink.add(_user);
  }

  Future<bool> isConnected() {
    Completer completer = Completer();
    completer.complete(FirebaseAuth.instance.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    Completer<bool> completer = Completer<bool>();
    FirebaseAuth.instance.signOut().then((value) {
      updateUser(null);
      completer.complete(true);
    }).catchError((error) => completer.completeError(false));
    return completer.future;
  }

  dispose() {
    _streamUser.close();
    _streamError.close();
  }

  setError(String error) {
    _streamError.sink.add(error);
  }

  cleanError() {
    _streamError.sink.add("");
  }

  changeEmail(String value) {
    _authParam.email = value;
  }

  changePassword(String value) {
    _authParam.password = value;
  }

  Future<UserCredential> login() {
    print('test');
    return FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _authParam.email, password: _authParam.password);
  }
}
