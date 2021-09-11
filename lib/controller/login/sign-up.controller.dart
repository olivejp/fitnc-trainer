import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

class SignUpController extends GetxController {
  final TrainersService trainersService = Get.find();
  final FirebaseAuth authInstance = FirebaseAuth.instance;

  String name = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String password = '';
  String passwordCheck = '';

  BehaviorSubject<String?>? _streamError;

  Stream<String?>? get errorsObservable => _streamError?.stream;

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(authInstance.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    final Completer<bool> completer = Completer<bool>();

    authInstance.signOut().then((_) => completer.complete(true)).catchError((Object error) => completer.completeError(false));

    return completer.future;
  }

  void setError(String error) {
    _streamError?.sink.add(error);
  }

  void cleanError() {
    _streamError?.sink.add('');
  }

  Future<UserCredential> signUp() async {
    final UserCredential credential = await authInstance.createUserWithEmailAndPassword(email: email, password: password);

    final Trainers trainer = Trainers( email: email, prenom: prenom, telephone: telephone);
    trainer.uid = credential.user!.uid;
    trainer.name = name;

    await trainersService.collectionReference.doc(trainer.uid).set(trainer.toJson());

    final UserCredential credentialSigned = await authInstance.signInWithEmailAndPassword(email: email, password: password);

    return credentialSigned;
  }
}
