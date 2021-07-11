import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/firestorage.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutUpdateBloc {
  FirestorageService firestorageService = FirestorageService.getInstance();
  TrainersService trainersService = TrainersService.getInstance();
  late Workout _workout;

  static WorkoutUpdateBloc? _instance;
  final String pathWorkoutMainImage = 'mainImage';
  StoragePair? storagePair;

  WorkoutUpdateBloc._();

  static WorkoutUpdateBloc getInstance() {
    if (_instance == null) {
      _instance = WorkoutUpdateBloc._();
    }
    return _instance!;
  }

  void init(Workout? workout) {
    if (workout != null) {
      _workout = workout;
    } else {
      _workout = Workout();
    }
  }

  Workout? getWorkout() {
    return _workout;
  }

  Future<void> saveWorkout() {
    if (_workout.uid != null && _workout.uid?.isNotEmpty == true) {
      return updateWorkout();
    } else {
      return createWorkout();
    }
  }

  Future<void> createWorkout() async {
    CollectionReference<Object?> collectionReference = trainersService.getWorkoutReference();

    _workout.uid = collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  String getUrl() {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    return 'trainers/${trainerUid}/exercices/${_workout.uid}/$pathWorkoutMainImage';
  }

  Future<void> updateWorkout() async {
    CollectionReference<Object?> collectionReference = trainersService.getWorkoutReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await deleteWorkoutMainImage(_workout);
      await sendToStorage();
    }

    if (storagePair == null || storagePair?.fileName == null || storagePair?.fileBytes == null) {
      await deleteWorkoutMainImage(_workout);
      _workout.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> sendToFireStore(CollectionReference<Object?> collectionReference) {
    _workout.createDate = FieldValue.serverTimestamp();
    return collectionReference.doc(_workout.uid).set(_workout.toJson()).then((value) {
      _workout = Workout();
    });
  }

  Future<void> sendToStorage() async {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    if (trainerUid != null && storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      _workout.imageUrl = await firestorageService.sendToStorageAndGetReference('${getUrl()}/${storagePair!.fileName}', storagePair!.fileBytes!);
    }
  }

  Stream<List<Workout?>> getStreamWorkout() {
    return trainersService.listenToWorkout();
  }

  Future<void> deleteWorkout(Workout workout) {
    return trainersService.getWorkoutReference().doc(workout.uid).delete().then((value) => deleteWorkoutMainImage(workout));
  }

  Future<void> deleteWorkoutMainImage(Workout workout) {
    return FirebaseStorage.instance
        .ref('${workout.uid}/$pathWorkoutMainImage')
        .listAll()
        .then((value) => value.items.forEach((element) => element.delete()))
        .catchError((error) => print(error));
  }

  setName(String value) {
    _workout.name = value;
  }

  setDescription(String value) {
    _workout.description = value;
  }

  setTimerType(String? value) {
    _workout.timerType = value;
  }

  setStoragePair(StoragePair? storagePair) {
    this.storagePair = storagePair;
  }
}
