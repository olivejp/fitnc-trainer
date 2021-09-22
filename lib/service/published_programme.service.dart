import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/published_programme.domain.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get/get.dart';

class PublishedProgrammeService extends AbstractFitnessStorageService<PublishedProgramme> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TrainersService trainersService = Get.find();
  final String publishedProgrammeCollectionName = 'publishedProgrammes';

  @override
  PublishedProgramme fromJson(Map<String, dynamic> map) {
    return PublishedProgramme.fromJson(map);
  }

  @override
  Stream<List<PublishedProgramme>> listenAll() {
    return getCollectionReference().snapshots().map((QuerySnapshot<Object?> event) =>
        event.docs.map((QueryDocumentSnapshot<Object?> e) => PublishedProgramme.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return firestoreInstance.collection(publishedProgrammeCollectionName);
  }

  @override
  String getStorageRef(User user, PublishedProgramme programme) {
    return '$publishedProgrammeCollectionName/${programme.uid}';
  }

  Future<void> publish(Programme programme) async {
    final Trainers? trainers = await trainersService.getCurrentTrainer();
    if (trainers == null) throw Exception("Impossible de retrouver l'utilisateur.");

    // Ouverture d'un batch.
    final WriteBatch batch = firestoreInstance.batch();

    final DocumentReference<Object?> publishedProgrammeRef = getCollectionReference().doc(programme.uid);

    final PublishedProgramme publishedProgramme = PublishedProgramme.fromProgramme(programme, trainers);
    batch.set(publishedProgrammeRef, publishedProgramme.toJson());

    // Lecture de tous les workouts.
    final QuerySnapshot<Map<String, dynamic>> mapWorkouts =
        await trainersService.getProgrammeReference().doc(programme.uid).collection(ProgrammeService.workoutScheduleCollectionName).get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> docs in mapWorkouts.docs) {
      final DocumentReference<Map<String, dynamic>> docRef = publishedProgrammeRef.collection(ProgrammeService.workoutScheduleCollectionName).doc(docs.id);
      batch.set(docRef, docs.data());
    }

    return batch.commit();
  }

  Future<void> unpublish(Programme programme) async {
    final DocumentReference<Object?> programmeRef = getCollectionReference().doc(programme.uid);

    // Ouverture d'un batch.
    final WriteBatch batch = firestoreInstance.batch();

    // Suppression du programme publié.
    batch.delete(programmeRef);

    // Suppression de tous les Workouts.
    final QuerySnapshot<Map<String, dynamic>> values = await programmeRef.collection(ProgrammeService.workoutScheduleCollectionName).get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> element in values.docs) {
      batch.delete(element.reference);
    }

    batch.commit();
  }
}
