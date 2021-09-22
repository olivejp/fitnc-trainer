import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/controller/abstract.controller.dart';
import 'package:fitness_domain/domain/programme.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.domain.dart';
import 'package:fitness_domain/domain/workout_schedule.dto.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart' as getx;
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class ProgrammeController extends LocalSearchControllerMixin<Programme, ProgrammeService> {
  final TrainersService trainersService = Get.find();

  final BehaviorSubject<List<WorkoutScheduleDto>> _streamWorkoutScheduleDto = BehaviorSubject<List<WorkoutScheduleDto>>();

  Stream<List<WorkoutScheduleDto>> get workoutScheduleObs => _streamWorkoutScheduleDto.stream;

  final String pathProgrammeMainImage = 'mainImage';
  final List<WorkoutScheduleDto> listDtos = <WorkoutScheduleDto>[];
  getx.Rx<Programme> programme = Programme().obs;

  RxInt numberWeekInt = 0.obs;

  void changeNumberWeek(String? numberWeek) {
    programme.update((Programme? programme) {
      if (programme == null) return;
      programme.numberWeeks = numberWeek;
    });

    if (numberWeek != null) {
      final int indexUnderscore = numberWeek.isNotEmpty ? numberWeek.indexOf('_') : 0;
      if (indexUnderscore != 0) {
        numberWeekInt.value = int.parse(numberWeek.substring(0, indexUnderscore));
      }
    } else {
      numberWeekInt.value = 1;
    }
  }

  Future<List<DropdownMenuItem<Workout>>> getWorkoutDropdownItems() {
    return service.getWorkoutDropdownItems();
  }

  Future<void> save() {
    return service.save(programme.value);
  }

  Future<void> publish() {
    return service.publishProgramme(programme.value);
  }

  Future<void> unpublish() {
    return service.unpublishProgramme(programme.value);
  }

  void init(Programme? programmeEntered) {
    if (programmeEntered != null) {
      programme.value = programmeEntered;
      programme.value.storageFile = StorageFile();

      if (programme.value.numberWeeks != null) {
        final int indexUnderscore = programme.value.numberWeeks != null ? programme.value.numberWeeks!.indexOf('_') : 0;
        numberWeekInt.value = int.parse(programme.value.numberWeeks!.substring(0, indexUnderscore));
      } else {
        numberWeekInt.value = 1;
      }

      // On récupère une fois la liste des WorkoutScheduleDto
      service.getWorkoutScheduleCollectionRef(programmeEntered.uid!)
          .orderBy('dateSchedule')
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> event) => event.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> queryDoc) => WorkoutSchedule.fromJson(queryDoc.data()))
              .map((WorkoutSchedule workoutSchedule) => service.mapToFutureWorkoutScheduleDto(workoutSchedule))
              .toList())
          .then((List<Future<WorkoutScheduleDto?>> event) => Future.wait(event))
          .catchError((Object? error) => throw Exception('Erreur lors de la récupération du programme ${programmeEntered.uid} : ${error.toString()}'))
          .then((List<WorkoutScheduleDto?> remoteList) {
        final List<WorkoutScheduleDto> list = [];
        remoteList.removeWhere((WorkoutScheduleDto? workoutScheduleDto) => workoutScheduleDto == null);
        for (final WorkoutScheduleDto? element in remoteList) {
          list.add(element!);
        }
        listDtos.clear();
        listDtos.addAll(list);
        _streamWorkoutScheduleDto.sink.add(listDtos);
      });
    } else {
      programme.value = Programme();
      numberWeekInt.value = 0;
    }
  }

  set name(String value) {
    programme.value.name = value;
  }

  String get name => programme.value.name;

  set description(String? value) {
    programme.value.description = value;
  }

  String? get description => programme.value.description;

  void setStoragePair(StorageFile? stFile) {
    programme.update((Programme? val) {
      if (val == null) return;
      if (stFile != null) {
        val.storageFile = stFile;
      } else {
        val.storageFile = StorageFile();
      }
      val.imageUrl = null;
    });
  }

  void addWorkoutSchedule(Workout workout, int dayIndex) {
    final WorkoutScheduleDto dto = WorkoutScheduleDto.empty();
    dto.uid = trainersService.getProgrammeReference().doc(programme.value.uid).collection(ProgrammeService.workoutScheduleCollectionName).doc().id;
    dto.uidWorkout = workout.uid;
    dto.nameWorkout = workout.name;
    dto.imageUrlWorkout = workout.imageUrl;
    dto.dateSchedule = dayIndex;
    listDtos.add(dto);
    _streamWorkoutScheduleDto.sink.add(listDtos);

    service.getWorkoutScheduleCollectionRef(programme.value.uid!)
        .doc(dto.uid)
        .set(dto.toJson())
        .then((_) => showToast('Workout ajouté au programme.', duration: const Duration(seconds: 2)))
        .catchError(
            (_) => showToast("Une erreur est survenue lors de l'enregistrement du workout au programme.", duration: const Duration(seconds: 2)));
  }

  void deleteWorkoutSchedule(WorkoutScheduleDto workoutSchedule) {
    listDtos.remove(workoutSchedule);
    _streamWorkoutScheduleDto.sink.add(listDtos);

    service.getWorkoutScheduleCollectionRef(programme.value.uid!)
        .doc(workoutSchedule.uid)
        .delete()
        .then((_) => showToast('Workout correctement supprimé.'));
  }
}
