import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.domain.dart';
import 'package:fitnc_trainer/domain/workout_schedule.dto.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class ProgrammeUpdateBloc {
  ProgrammeUpdateBloc._();

  static ProgrammeUpdateBloc? _instance;

  static ProgrammeUpdateBloc getInstance() {
    _instance ??= ProgrammeUpdateBloc._();
    return _instance!;
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

  StorageFile? storagePair;

  void init(Programme? programmeEntered) {
    storagePair = StorageFile();
    subjectStoragePair.sink.add(null);

    if (programmeEntered != null) {
      programme = programmeEntered;

      // Recherche de l'image
      if (programme.imageUrl != null && programme.imageUrl!.isNotEmpty) {
        firestorageService.getRemoteImageToUint8List(programme.imageUrl!).then((Uint8List bytes) {
          storagePair!.fileName = basename(programme.imageUrl!);
          storagePair!.fileBytes = bytes;
          subjectStoragePair.sink.add(storagePair);
        });
      }

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

  Programme? getProgramme() {
    return programme;
  }

  Future<void> saveProgramme() {
    if (programme.uid != null && programme.uid?.isNotEmpty == true) {
      return updateProgramme();
    } else {
      return createProgramme();
    }
  }

  Future<void> createProgramme() async {
    final CollectionReference<Object?> collectionReference = trainersService.getProgrammeReference();

    programme.uid = collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> updateProgramme() async {
    CollectionReference<Object?> collectionReference = trainersService.getProgrammeReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await deleteProgrammeMainImage(programme);
      await sendToStorage();
    }

    if (storagePair == null || storagePair?.fileName == null || storagePair?.fileBytes == null) {
      await deleteProgrammeMainImage(programme);
      programme.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  String getUrl() {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    return 'trainers/$trainerUid/programme/${programme.uid}/$pathProgrammeMainImage';
  }

  Future<void> sendToFireStore(CollectionReference<Object?> collectionReference) {
    programme.createDate = FieldValue.serverTimestamp();
    return collectionReference.doc(programme.uid).set(programme.toJson()).then((value) {
      programme = Programme();
    });
  }

  Future<void> sendToStorage() async {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    if (trainerUid != null && storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      programme.imageUrl = await firestorageService.sendToStorageAndGetReference('${getUrl()}/${storagePair!.fileName}', storagePair!.fileBytes!);
    }
  }

  Stream<List<Programme>> getStreamProgramme() {
    return trainersService.listenToProgramme();
  }

  Future<void> deleteProgramme(Programme programme) {
    return trainersService.getProgrammeReference().doc(programme.uid).delete().then((value) => deleteProgrammeMainImage(programme));
  }

  Future<void> deleteProgrammeMainImage(Programme programme) {
    final String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    if (trainerUid != null) {
      return FirebaseStorage.instance
          .ref(getUrl())
          .listAll()
          .then((ListResult value) => value.items.forEach((Reference element) => element.delete()))
          .catchError((error) => print(error));
    } else {
      return Future.error('Aucun compte trainer connecté');
    }
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
    this.storagePair = storagePair;
    subjectStoragePair.sink.add(this.storagePair);
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
