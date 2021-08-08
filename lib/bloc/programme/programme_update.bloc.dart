import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/programme/programme.update.page.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class ProgrammeUpdateBloc extends AbstractFitnessCrudBloc<Programme> with AbstractFitnessStorageBloc<Programme> {
  ProgrammeUpdateBloc._();

  factory ProgrammeUpdateBloc.instance() {
    _instance ??= ProgrammeUpdateBloc._();
    return _instance!;
  }

  static ProgrammeUpdateBloc? _instance;

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getProgrammeReference();
  }

  @override
  String getStorageRef(User user, Programme programme) {
    return 'trainers/${user.uid}/programmes/${programme.uid}';
  }

  @override
  Widget openUpdate(BuildContext context, Programme programme) {
    return ProgrammeUpdatePage(programme: programme);
  }

  FirestorageService firestorageService = FirestorageService.instance();
  TrainersService trainersService = TrainersService.getInstance();
  ParamService paramService = ParamService.getInstance();

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

  void init(Programme? programmeEntered) {
    subjectStoragePair.sink.add(null);

    if (programmeEntered != null) {
      programme = programmeEntered;
      programme.storageFile = StorageFile();
      getFutureStorageFile(programme).then((StorageFile? storageFile) => subjectStoragePair.sink.add(storageFile));

      // On récupère une fois la liste des WorkoutScheduleDto
      trainersService
          .getProgrammeReference()
          .doc(programmeEntered.uid)
          .collection('workouts')
          .orderBy('dateSchedule')
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> event) => event.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> e) => WorkoutSchedule.fromJson(e.data()))
              .map((WorkoutSchedule e) => mapToFutureWorkoutScheduleDto(e))
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

  Future<void> saveProgramme() {
    if (programme.uid != null) {
      return eraseAndReplaceStorage(programme).then((_) => save(programme));
    } else {
      programme.uid = getCollectionReference().doc().id;
      return createStorage(programme).then((_) => create(programme));
    }
  }

  Stream<List<Programme>> getStreamProgramme() {
    return trainersService.listenToProgramme();
  }

  Future<void> deleteProgramme(Programme programme) {
    return trainersService.getProgrammeReference().doc(programme.uid).delete().then((_) => deleteAllFiles(programme));
  }

  set name(String value) {
    programme.name = value;
  }

  set numberWeeks(String? value) {
    programme.numberWeeks = value;
  }

  String get name => programme.name!;

  set description(String? value) {
    programme.description = value;
  }

  String? get description => programme.description;

  void setStoragePair(StorageFile? storagePair) {
    programme.storageFile = storagePair;
    subjectStoragePair.sink.add(programme.storageFile);
  }

  void addWorkoutSchedule(Workout workout, int dayIndex) {
    final WorkoutScheduleDto dto = WorkoutScheduleDto.empty();
    dto.uid = trainersService.getProgrammeReference().doc(programme.uid).collection('workouts').doc().id;
    dto.uidWorkout = workout.uid;
    dto.nameWorkout = workout.name;
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

  Future<WorkoutScheduleDto> mapToFutureWorkoutScheduleDto(WorkoutSchedule e) {
    return trainersService
        .getWorkoutReference()
        .doc(e.uidWorkout)
        .get()
        .then((DocumentSnapshot<Object?> value) => Workout.fromJson(value.data() as Map<String, dynamic>))
        .then((Workout value) {
      final WorkoutScheduleDto dto = WorkoutScheduleDto.fromSchedule(e);
      dto.nameWorkout = value.name;
      dto.imageUrlWorkout = value.imageUrl;
      return dto;
    });
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
        .then((value) => showToast('Workout correctement supprimé.'));
  }

  Future<List<DropdownMenuItem<Workout>>> getWorkoutDropdownItems() async {
    QuerySnapshot<Object?> query = await trainersService.getWorkoutReference().get();
    return query.docs
        .map((e) => Workout.fromJson(e.data() as Map<String, dynamic>))
        .map((Workout workout) => DropdownMenuItem<Workout>(value: workout, child: Text(workout.name!)))
        .toList();
  }
}
