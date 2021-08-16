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

class WorkoutUpdateBloc extends AbstractFitnessCrudBloc<Workout> with MixinFitnessStorageBloc<Workout> {
  WorkoutUpdateBloc._();

  factory WorkoutUpdateBloc.instance() {
    _instance ??= WorkoutUpdateBloc._();
    return _instance!;
  }

  static WorkoutUpdateBloc? _instance;

  TrainersService trainersService = TrainersService.instance();
  WorkoutSetService workoutSetService = WorkoutSetService.getInstance();

  final GlobalKey<FormFieldState> consigneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> dropdownKey = GlobalKey<FormFieldState>();
  final String pathWorkoutMainImage = 'mainImage';

  late Workout _workout;
  WorkoutSet set = WorkoutSet();
  Exercice? exerciceSelected;

  @override
  Stream<List<Workout>> listenAll() {
    return trainersService.listenToWorkout();
  }

  @override
  String getStorageRef(User user, Workout workout) {
    return 'trainers/${user.uid}/workouts/${workout.uid}/$pathWorkoutMainImage';
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getWorkoutReference();
  }

  void init(Workout? workout) {
    if (workout != null) {
      _workout = workout;
      _workout.storageFile = StorageFile();
      getFutureStorageFile(_workout);
    } else {
      _workout = Workout();
    }
  }

  Future<void> deleteWorkout(Workout workout) {
    return delete(workout).then((_) => deleteAllFiles(workout));
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
  }

  StorageFile? get storageFile => _workout.storageFile;

  void setExercice(Exercice? exerciceSelected) {
    this.exerciceSelected = exerciceSelected;
    set.uidExercice = this.exerciceSelected?.uid;
  }

  Future<StorageFile?> getStorageFile() {
    return getFutureStorageFile(_workout);
  }
}
