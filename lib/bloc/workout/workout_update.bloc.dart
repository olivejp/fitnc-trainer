import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/firestorage.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutUpdateBloc {
  FirestorageService firestorageService = FirestorageService.getInstance();
  TrainersService trainersService = TrainersService.getInstance();

  static WorkoutUpdateBloc? _instance;
  final String pathWorkoutMainImage = 'mainImage';

  final GlobalKey<FormFieldState> consigneKey= GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> dropdownKey= GlobalKey<FormFieldState>();

  StoragePair? storagePair;
  late Workout _workout;
  Line line = Line();
  WorkoutSet set = WorkoutSet();
  Exercice? exerciceSelected;

  BehaviorSubject<StoragePair?> subjectStoragePair = BehaviorSubject<StoragePair?>();
  BehaviorSubject<String?> subjectTypeExercice = BehaviorSubject<String?>();
  BehaviorSubject<List<Line>?> subjectListRepsWeight = BehaviorSubject<List<Line>?>();

  Stream<StoragePair?> get obsStoragePair => subjectStoragePair.stream;

  Stream<String?> get obsTypeExercice => subjectTypeExercice.stream;

  Stream<List<Line>?> get obsLines => subjectListRepsWeight.stream;

  WorkoutUpdateBloc._();

  static WorkoutUpdateBloc getInstance() {
    if (_instance == null) {
      _instance = WorkoutUpdateBloc._();
    }
    return _instance!;
  }

  void init(Workout? workout) {
    storagePair = StoragePair();
    subjectStoragePair.sink.add(null);

    if (workout != null) {
      _workout = workout;
      if (_workout.imageUrl != null && _workout.imageUrl!.isNotEmpty) {
        firestorageService.getRemoteImageToUint8List(_workout.imageUrl!).then((bytes) {
          storagePair!.fileName = basename(_workout.imageUrl!);
          storagePair!.fileBytes = bytes;
          subjectStoragePair.sink.add(storagePair);
        });
      }
    } else {
      _workout = Workout();
      subjectStoragePair.sink.add(null);
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
    this.subjectStoragePair.sink.add(this.storagePair);
  }

  clearListRepsWeight() {
    this.set.lines.clear();
  }

  void deleteLine(Line re) {
    this.set.lines.remove(re);
    this.subjectListRepsWeight.sink.add(this.set.lines);
  }

  addLine() {
    // Recherche du nouvel ordre.
    // int max = 0;
    // this.set.lines.forEach((element) {
    //   if (element.order != null) {
    //     if (element.order! > max) {
    //       max = element.order!;
    //     }
    //   }
    // });
    // this.line.order = max + 1;

    this.set.lines.add(Line());
    this.subjectListRepsWeight.sink.add(this.set.lines);

    // RAZ du viewModel.
    // this.line = Line();
  }

  void setRepsWeightType(String type) {
    this.line.type = type;
  }

  void setRepsWeightReps(String value) {
    this.line.reps = value;
  }

  void setRepsWeightWeight(String value) {
    this.line.weight = value;
  }

  saveSet() async {
    if (this.set.uidExercice != null && this.set.lines.isNotEmpty) {
      this.set.uid = this.trainersService.getWorkoutSetsReference(_workout).doc().id;
      await this.trainersService.getWorkoutSetsReference(_workout).doc(this.set.uid).set(this.set.toJson());
      this.set = WorkoutSet();
      this.line = Line();
      this.consigneKey.currentState?.reset();
      this.dropdownKey.currentState?.reset();
      this.subjectListRepsWeight.sink.add(this.set.lines);
    }
  }

  setExercice(Exercice? exerciceSelected) {
    this.exerciceSelected = exerciceSelected;
    this.set.uidExercice = this.exerciceSelected?.uid;
    this.subjectTypeExercice.sink.add(this.exerciceSelected?.typeExercice);
  }

  setConsigne(String? consigne) {
    this.set.consigne = consigne;
  }

  Stream<List<WorkoutSet?>> listenToWorkoutStep() {
    return this.trainersService.listenToWorkoutStep(_workout);
  }
}