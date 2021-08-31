import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class ProgrammeVm with ChangeNotifier {
  final TrainersService trainersService = Get.find();
  final ProgrammeService programmeService = Get.find();

  BehaviorSubject<StorageFile?> subjectStoragePair = BehaviorSubject<StorageFile?>();
  final BehaviorSubject<String?> _streamSelectedVideoUrl = BehaviorSubject<String?>();
  final BehaviorSubject<String?> _streamSelectedYoutubeUrl = BehaviorSubject<String?>();
  final BehaviorSubject<List<WorkoutScheduleDto>> _streamWorkoutScheduleDto = BehaviorSubject<List<WorkoutScheduleDto>>();

  Stream<String?>? get selectedVideoUrlObs => _streamSelectedVideoUrl.stream;

  Stream<String?>? get selectedYoutubeUrlObs => _streamSelectedYoutubeUrl.stream;

  Stream<StorageFile?> get obsStoragePair => subjectStoragePair.stream;

  Stream<List<WorkoutScheduleDto>> get workoutScheduleObs => _streamWorkoutScheduleDto.stream;

  final String pathProgrammeMainImage = 'mainImage';
  final List<WorkoutScheduleDto> listDtos = <WorkoutScheduleDto>[];
  late Programme programme;
  bool sendStorage = false;

  Future<List<DropdownMenuItem<Workout>>> getWorkoutDropdownItems() {
    return programmeService.getWorkoutDropdownItems();
  }

  Future<void> save() {
    return programmeService.save(programme);
  }

  Future<void> publish() {
    return programmeService.publishProgramme(programme, sendStorage: sendStorage);
  }

  Future<void> unpublish() {
    return programmeService.unpublishProgramme(programme, sendStorage: sendStorage);
  }

  int getNumberWeeks(String? numberWeeks) {
    if (numberWeeks != null) {
      return int.parse(numberWeeks.substring(0, 1));
    } else {
      return 0;
    }
  }

  void init(Programme? programmeEntered) {
    sendStorage = false;
    subjectStoragePair.sink.add(null);

    if (programmeEntered != null) {
      programme = programmeEntered;
      programme.storageFile = StorageFile();
      programmeService.getFutureStorageFile(programme).then((StorageFile? storageFile) => subjectStoragePair.sink.add(storageFile));

      // On récupère une fois la liste des WorkoutScheduleDto
      trainersService
          .getProgrammeReference()
          .doc(programmeEntered.uid)
          .collection('workouts')
          .orderBy('dateSchedule')
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> event) => event.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> e) => WorkoutSchedule.fromJson(e.data()))
              .map((WorkoutSchedule e) => programmeService.mapToFutureWorkoutScheduleDto(e))
              .toList())
          .then((List<Future<WorkoutScheduleDto>> event) => Future.wait(event))
          .then((List<WorkoutScheduleDto> remoteList) {
        listDtos.clear();
        listDtos.addAll(remoteList);
        _streamWorkoutScheduleDto.sink.add(listDtos);
      });
    } else {
      programme = Programme();
      subjectStoragePair.sink.add(null);
    }
  }

  set name(String value) {
    programme.name = value;
  }

  String get name => programme.name!;

  set numberWeeks(String? value) {
    programme.numberWeeks = value;
    notifyListeners();
  }

  int get numberWeeksInt {
    if (programme.numberWeeks != null) {
      final int indexUnderscore = programme.numberWeeks != null ? programme.numberWeeks!.indexOf('_') : 0;
      return int.parse(programme.numberWeeks!.substring(0, indexUnderscore));
    }
    return 0;
  }

  String? get numberWeeks => programme.numberWeeks;

  set description(String? value) {
    programme.description = value;
  }

  String? get description => programme.description;

  void setStoragePair(StorageFile? storagePair) {
    sendStorage = true;
    programme.storageFile = storagePair;
    subjectStoragePair.sink.add(programme.storageFile);
  }

  void addWorkoutSchedule(Workout workout, int dayIndex) {
    final WorkoutScheduleDto dto = WorkoutScheduleDto.empty();
    dto.uid = trainersService.getProgrammeReference().doc(programme.uid).collection('workouts').doc().id;
    dto.uidWorkout = workout.uid;
    dto.nameWorkout = workout.name;
    dto.imageUrlWorkout = workout.imageUrl;
    dto.dateSchedule = dayIndex;
    listDtos.add(dto);
    _streamWorkoutScheduleDto.sink.add(listDtos);

    trainersService
        .getProgrammeReference()
        .doc(programme.uid)
        .collection('workouts')
        .doc(dto.uid)
        .set(dto.toJson())
        .then((_) => showToast('Workout ajouté au programme.', duration: const Duration(seconds: 2)))
        .catchError(
            (_) => showToast("Une erreur est survenue lors de l'enregistrement du workout au programme.", duration: const Duration(seconds: 2)));
  }

  void deleteWorkoutSchedule(WorkoutScheduleDto workout) {
    listDtos.remove(workout);
    _streamWorkoutScheduleDto.sink.add(listDtos);

    trainersService
        .getProgrammeReference()
        .doc(programme.uid)
        .collection('workouts')
        .doc(workout.uid)
        .delete()
        .then((_) => showToast('Workout correctement supprimé.'));
  }
}
