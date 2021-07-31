import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutUpdateBloc {
  FirestorageService firestorageService = FirestorageService.getInstance();
  TrainersService trainersService = TrainersService.getInstance();
  WorkoutSetService workoutSetService = WorkoutSetService.getInstance();

  static WorkoutUpdateBloc? _instance;
  final String pathWorkoutMainImage = 'mainImage';

  final GlobalKey<FormFieldState> consigneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> dropdownKey = GlobalKey<FormFieldState>();

  StorageFile? storageFile;
  late Workout _workout;
  WorkoutSet set = WorkoutSet();
  Exercice? exerciceSelected;

  BehaviorSubject<StorageFile?> subjectStorageFile = BehaviorSubject<StorageFile?>();
  BehaviorSubject<String?> subjectTypeExercice = BehaviorSubject<String?>();
  BehaviorSubject<List<Line>?> subjectListRepsWeight = BehaviorSubject<List<Line>?>();

  Stream<StorageFile?> get obsStorageFile => subjectStorageFile.stream;

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
    storageFile = StorageFile();
    subjectStorageFile.sink.add(null);

    if (workout != null) {
      _workout = workout;
      if (_workout.imageUrl != null && _workout.imageUrl!.isNotEmpty) {
        firestorageService.getRemoteImageToUint8List(_workout.imageUrl!).then((bytes) {
          storageFile!.fileName = basename(_workout.imageUrl!);
          storageFile!.fileBytes = bytes;
          subjectStorageFile.sink.add(storageFile);
        });
      }
    } else {
      _workout = Workout();
      subjectStorageFile.sink.add(null);
    }
  }

  Future<StorageFile?> getFutureStorageFile() {
    Completer<StorageFile?> completer = Completer();
    if (_workout.imageUrl != null) {
      firestorageService.getRemoteImageToUint8List(_workout.imageUrl!).then((bytes) {
        storageFile!.fileName = basename(_workout.imageUrl!);
        storageFile!.fileBytes = bytes;
        completer.complete(storageFile);
      });
    } else {
      completer.complete(null);
    }
    return completer.future;
  }

  Stream<List<Exercice?>> getStreamExercice() {
    return trainersService.listenToExercice();
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
    if (storageFile != null && storageFile!.fileBytes != null && storageFile!.fileName != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  String getUrl() {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    return 'trainers/$trainerUid/exercices/${_workout.uid}/$pathWorkoutMainImage';
  }

  Future<void> updateWorkout() async {
    CollectionReference<Object?> collectionReference = trainersService.getWorkoutReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storageFile != null && storageFile!.fileBytes != null && storageFile!.fileName != null) {
      await deleteWorkoutMainImage(_workout);
      await sendToStorage();
    }

    if (storageFile == null || storageFile?.fileName == null || storageFile?.fileBytes == null) {
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
    if (trainerUid != null && storageFile != null && storageFile!.fileBytes != null && storageFile!.fileName != null) {
      _workout.imageUrl = await firestorageService.sendToStorageAndGetReference('${getUrl()}/${storageFile!.fileName}', storageFile!.fileBytes!);
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

  setStorageFile(StorageFile? storagePair) {
    storageFile = storagePair;
    subjectStorageFile.sink.add(storageFile);
  }

  setExercice(Exercice? exerciceSelected) {
    exerciceSelected = exerciceSelected;
    set.uidExercice = this.exerciceSelected?.uid;
    subjectTypeExercice.sink.add(this.exerciceSelected?.typeExercice);
  }

  setConsigne(String? consigne) {
    set.consigne = consigne;
  }

  Stream<List<WorkoutSet?>> listenToWorkoutStep() {
    return workoutSetService.listenToWorkoutStep(_workout);
  }
}
