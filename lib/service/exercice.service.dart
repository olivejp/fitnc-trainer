import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/firebase-storage.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:get/get.dart';

class ExerciceService extends AbstractFitnessCrudService<Exercice> {
  final TrainersService trainersService = Get.find();
  final FirebaseStorageService storageService = Get.find();

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

  String getExerciceStoragePath(Exercice exercice) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return 'trainers/${user.uid}/exercices/${exercice.uid}/mainImage';
    }
    throw Exception('Aucun utilisateur connecté');
  }

  Future<void> saveExercice(Exercice exercice, {required bool sendStorage}) {
    final bool isUpdate = exercice.uid != null;
    final String path = getExerciceStoragePath(exercice);
    if (isUpdate) {
      if (sendStorage) {
        return storageService.eraseAndReplaceStorage(path, exercice.storageFile).then((_) => save(exercice));
      } else {
        return save(exercice);
      }
    } else {
      exercice.uid = getCollectionReference().doc().id;
      return storageService.createStorage(path, exercice.storageFile).then((_) => create(exercice));
    }
  }
}
