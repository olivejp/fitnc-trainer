import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/domain/line.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.domain.dart';
import 'package:fitnc_trainer/domain/workout_set.dto.dart';
import 'package:fitnc_trainer/service/firestorage.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutSetPageBloc {
  WorkoutSetPageBloc._();

  static WorkoutSetPageBloc? _instance;

  static WorkoutSetPageBloc getInstance() {
    if (_instance == null) {
      _instance = WorkoutSetPageBloc._();
    }
    return _instance!;
  }

  Workout? _workout;
  TrainersService trainersService = TrainersService.getInstance();

  BehaviorSubject<List<WorkoutSetDto>> subjectListSet = BehaviorSubject<List<WorkoutSetDto>>();

  Stream<List<WorkoutSetDto>> get obsListWorkoutSet => subjectListSet.stream;

  void init(Workout workout) {
    if (_workout == null || (_workout != null && _workout!.uid != workout.uid)) {
      _workout = workout;
      trainersService
          .getWorkoutSetsReference(_workout!)
          .orderBy('order')
          .get()
          .then((querySnapshot) => querySnapshot.docs
          .map((docSnapshot) => WorkoutSet.fromJson(docSnapshot.data() as Map<String, dynamic>))
          .map((workoutSet) => trainersService.mapToDto(workoutSet))
          .toList())
          .then((remoteListFuture) => Future.wait(remoteListFuture))
          .then((remoteList) => subjectListSet.sink.add(remoteList));
    }
  }

  int getMaxOrder(List<WorkoutSetDto>? listWorkoutSetDto) {
    int maxOrder = 0;
    if (listWorkoutSetDto != null) {
      listWorkoutSetDto.forEach((workoutSet) {
        if (workoutSet.order > maxOrder) {
          maxOrder = workoutSet.order;
        }
      });
    }
    return maxOrder + 1;
  }

  void deleteWorkoutSet(WorkoutSetDto dto) {
    List<WorkoutSetDto> listDtos = [];
    if (this.subjectListSet.hasValue) {
      listDtos = this.subjectListSet.valueOrNull!;
      listDtos.remove(dto);
      deleteFromFireStore(dto);
    }
    this.subjectListSet.sink.add(listDtos);
  }

  void addWorkoutSet(Exercice exerciceDragged) {
    List<WorkoutSetDto> listDtos = [];
    if (this.subjectListSet.hasValue) {
      listDtos = this.subjectListSet.valueOrNull!;
    }

    WorkoutSetDto dto = WorkoutSetDto.empty();
    dto.uid = trainersService.getWorkoutSetsReference(_workout!).doc().id;
    dto.uidExercice = exerciceDragged.uid;
    dto.typeExercice = exerciceDragged.typeExercice;
    dto.nameExercice = exerciceDragged.name;
    dto.imageUrlExercice = exerciceDragged.imageUrl;
    dto.order = getMaxOrder(listDtos);
    listDtos.add(dto);
    this.subjectListSet.sink.add(listDtos);
  }

  void saveToFireStore(WorkoutSet set) {
    set.uid = trainersService.getWorkoutSetsReference(_workout!).doc().id;
    set.order = getMaxOrder(subjectListSet.valueOrNull);
    trainersService.getWorkoutSetsReference(_workout!).doc(set.uid).set(set.toJson()).then((value) => print('OK'));
  }

  void deleteFromFireStore(WorkoutSetDto dto) {
    trainersService
        .getWorkoutSetsReference(_workout!)
        .doc(dto.uid)
        .delete()
        .then((value) => showToast('WorkoutSet supprimé.', duration: Duration(seconds: 2)))
        .catchError((onError) => showToast('Erreur lors de la suppression du Set.', duration: Duration(seconds: 2)));
  }

  void switchOrder(WorkoutSetDto dto, int newOrder) {
    List<WorkoutSetDto>? dtos = this.subjectListSet.valueOrNull;
    List<WorkoutSetDto>? dtosFiltered = [];
    bool isDescente = dto.order < newOrder;
    if (isDescente) {
      newOrder = newOrder - 1;
    }

    if (dtos != null && dtos.isNotEmpty) {
      dtosFiltered = dtos.where((element) => element.uid != dto.uid).map((element) {
        if (isDescente && element.order > dto.order && element.order <= newOrder) {
          element.order = element.order - 1;
        }
        if (!isDescente && element.order < dto.order && element.order >= newOrder) {
          element.order = element.order + 1;
        }
        return element;
      }).toList();

      dto.order = newOrder;
      dtosFiltered.add(dto);
    }
    dtosFiltered.sort((a, b) => a.order.compareTo(b.order));
    subjectListSet.sink.add(dtosFiltered);
  }

  void setReps(WorkoutSetDto dto, String value) {
    dto.reps = value;
  }

  void setWeight(WorkoutSetDto dto, String value) {
    dto.weight = value;
  }

  setRestTime(WorkoutSetDto dto, String? value) {
    dto.restTime = value;
  }

  setTime(WorkoutSetDto dto, String? value) {
    dto.time = value;
  }

  setSets(WorkoutSetDto dto, String value) {
    dto.sets = value;
  }
}
