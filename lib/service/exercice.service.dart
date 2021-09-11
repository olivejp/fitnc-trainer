import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:get/get.dart';

class ExerciceService extends AbstractFitnessStorageService<Exercice> {
  final TrainersService trainersService = Get.find();
  final FirebaseStorageService storageService = Get.find();

  @override
  Exercice fromJson(Map<String, dynamic> map) {
    return Exercice.fromJson(map);
  }

  @override
  Stream<List<Exercice>> listenAll() {
    return trainersService.getCurrentTrainerRef().collection('exercice').orderBy('createDate').snapshots().map(
        (QuerySnapshot<Map<String, dynamic>> event) =>
            event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Exercice.fromJson(doc.data())).toList());
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getExerciceReference();
  }

  @override
  String getStorageRef(User user, Exercice exercice) {
    return 'trainers/${user.uid}/exercices/${exercice.uid}/mainImage';
  }

  String getExerciceStoragePath(Exercice exercice) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return 'trainers/${user.uid}/exercices/${exercice.uid}/mainImage';
    }
    throw Exception('Aucun utilisateur connecté');
  }
}
