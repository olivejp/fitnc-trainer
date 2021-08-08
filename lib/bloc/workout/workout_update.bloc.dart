import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abstract.domain.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:fitnc_trainer/widget/workout/workout.update.page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutUpdateBloc extends AbstractFitnessCrudBloc<Workout> with AbstractFitnessStorageBloc<Workout> {
  WorkoutUpdateBloc._();

  factory WorkoutUpdateBloc.instance() {
    _instance ??= WorkoutUpdateBloc._();
    return _instance!;
  }

  static WorkoutUpdateBloc? _instance;

  TrainersService trainersService = TrainersService.getInstance();
  WorkoutSetService workoutSetService = WorkoutSetService.getInstance();

  final GlobalKey<FormFieldState> consigneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> dropdownKey = GlobalKey<FormFieldState>();
  final String pathWorkoutMainImage = 'mainImage';

  late Workout _workout;
  WorkoutSet set = WorkoutSet();
  Exercice? exerciceSelected;

  BehaviorSubject<StorageFile?> subjectStorageFile = BehaviorSubject<StorageFile?>();
  BehaviorSubject<String?> subjectTypeExercice = BehaviorSubject<String?>();
  BehaviorSubject<List<Line>?> subjectListRepsWeight = BehaviorSubject<List<Line>?>();

  Stream<StorageFile?> get obsStorageFile => subjectStorageFile.stream;

  Stream<String?> get obsTypeExercice => subjectTypeExercice.stream;

  Stream<List<Line>?> get obsLines => subjectListRepsWeight.stream;

  @override
  String getStorageRef(User user, Workout workout) {
    return 'trainers/${user.uid}/workouts/${workout.uid}/$pathWorkoutMainImage';
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getWorkoutReference();
  }

  @override
  Widget openUpdate(BuildContext context, Workout workout) {
    return WorkoutUpdatePage(workout: workout);
  }

  void init(Workout? workout) {
    subjectStorageFile.sink.add(null);

    if (workout != null) {
      _workout = workout;
      _workout.storageFile = StorageFile();
      getFutureStorageFile(_workout).then((StorageFile? value) => subjectStorageFile.sink.add(value));
    } else {
      _workout = Workout();
      subjectStorageFile.sink.add(null);
    }
  }

  Workout? getWorkout() {
    return _workout;
  }

  Future<void> saveWorkout() {
    if (_workout.uid != null) {
      return eraseAndReplaceStorage(_workout).then((_) => save(_workout));
    } else {
      _workout.uid = getCollectionReference().doc().id;
      return createStorage(_workout).then((_) => create(_workout));
    }
  }

  Stream<List<Workout>> getStreamWorkout() {
    return trainersService.listenToWorkout();
  }

  set name(String? value) {
    _workout.name = value;
  }

  String? get name => _workout.name;

  set description(String? value) {
    _workout.description = value;
  }

  String? get description => _workout.description;

  set timerType(String? value) {
    _workout.timerType = value;
  }

  String? get timerType => _workout.timerType;

  set storageFile(StorageFile? storagePair) {
    _workout.storageFile = storagePair;
    subjectStorageFile.sink.add(_workout.storageFile);
  }

  StorageFile? get storageFile => _workout.storageFile;

  void setExercice(Exercice? exerciceSelected) {
    this.exerciceSelected = exerciceSelected;
    set.uidExercice = this.exerciceSelected?.uid;
    subjectTypeExercice.sink.add(this.exerciceSelected?.typeExercice);
  }

  Future<StorageFile?> getStorageFile() {
    return getFutureStorageFile(_workout);
  }
}
