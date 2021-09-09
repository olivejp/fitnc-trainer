import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SignUpVm {
  final TrainersService trainersService = Get.find();

  String nom = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String password = '';
  String passwordCheck = '';

  BehaviorSubject<String?>? _streamError;

  Stream<String?>? get errorsObservable => _streamError?.stream;

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(FirebaseAuth.instance.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    final Completer<bool> completer = Completer<bool>();

    FirebaseAuth.instance.signOut().then((_) => completer.complete(true)).catchError((Object error) => completer.completeError(false));

    return completer.future;
  }

  void setError(String error) {
    _streamError?.sink.add(error);
  }

  void cleanError() {
    _streamError?.sink.add('');
  }

  Future<UserCredential> signUp() async {
    final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

    final Trainers newTrainer = Trainers(uid: credential.user!.uid, email: email, nom: nom, prenom: prenom, telephone: telephone);

    await trainersService.collectionReference.doc(newTrainer.uid).set(newTrainer.toJson());

    final UserCredential credentialSigned = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    return credentialSigned;
  }
}
