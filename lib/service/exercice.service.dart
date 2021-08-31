import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:get/get.dart';

class ExerciceService extends AbstractFitnessCrudService<Exercice> with MixinFitnessStorageService<Exercice> {
  final TrainersService trainersService = Get.find();

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
    return 'trainers/${user.uid}/exercices/${exercice.uid}';
  }

  Future<void> saveExercice(Exercice exercice, {required bool sendStorage}) async {
    final bool isUpdate = exercice.uid != null;
    if (isUpdate) {
      if (sendStorage) {
        return eraseAndReplaceStorage(exercice).then((_) => save(exercice));
      } else {
        return save(exercice);
      }
    } else {
      exercice.uid = getCollectionReference().doc().id;
      return createStorage(exercice).then((_) => create(exercice));
    }
  }
}
