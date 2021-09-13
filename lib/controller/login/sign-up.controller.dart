import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/auth.service.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final TrainersService trainersService = Get.find();
  final AuthService authService = Get.find();

  String name = '';
  String prenom = '';
  String email = '';
  String telephone = '';
  String password = '';
  String passwordCheck = '';

  RxString errors = ''.obs;

  Future<bool> isConnected() {
    final Completer<bool> completer = Completer<bool>();
    completer.complete(authService.isConnected());
    return completer.future;
  }

  Future<bool> disconnect() {
    final Completer<bool> completer = Completer<bool>();

    authService.signOut().then((_) => completer.complete(true)).catchError((Object error) => completer.completeError(false));

    return completer.future;
  }

  void setError(String error) {
    errors.value = error;
  }

  void cleanError() {
    errors.value = '';
  }

  Future<UserCredential> signUp() async {
    // Méthode pour s'enregistrer sur Firebase.
    final UserCredential credential = await authService.signUp(email, password);

    // Création et sauvegarde d'un Trainer
    final Trainers trainer = Trainers(email: email, prenom: prenom, telephone: telephone);
    trainer.uid = credential.user!.uid;
    trainer.name = name;
    await trainersService.getCollectionReference().doc(trainer.uid).set(trainer.toJson());

    // On se log pour la première fois avec le compte et on renvoie le credential.
    await authService.signInWithEmailPassword(email, password);
    return credential;
  }
}
