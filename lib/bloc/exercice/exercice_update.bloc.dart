import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/exercice/exercice.update.page.dart';
import 'package:fitnc_trainer/widget/generic.grid.card.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ExerciceUpdateBloc with AbstractFitnessCrudBloc<Exercice>, AbstractFitnessStorageBloc<Exercice> {
  ExerciceUpdateBloc._();

  factory ExerciceUpdateBloc.instance() {
    _instance ??= ExerciceUpdateBloc._();
    return _instance!;
  }

  static ExerciceUpdateBloc? _instance;

  TrainersService trainersService = TrainersService.getInstance();
  ParamService paramService = ParamService.getInstance();
  Exercice? exercice;

  final BehaviorSubject<StorageFile?> subjectStoragePair = BehaviorSubject<StorageFile?>();
  final BehaviorSubject<String?> _streamSelectedVideoUrl = BehaviorSubject<String?>();
  final BehaviorSubject<String?> _streamSelectedYoutubeUrl = BehaviorSubject<String?>();

  Stream<String?>? get selectedVideoUrlObs => _streamSelectedVideoUrl.stream;

  Stream<String?>? get selectedYoutubeUrlObs => _streamSelectedYoutubeUrl.stream;

  Stream<StorageFile?> get obsStoragePair => subjectStoragePair.stream;

  void init(Exercice? exerciceEntered) {
    subjectStoragePair.sink.add(null);

    if (exerciceEntered != null) {
      exercice = exerciceEntered;
      exerciceEntered.storageFile = StorageFile();
      getFutureStorageFile(exercice!).then((StorageFile? value) => subjectStoragePair.sink.add(value));

      if (exercice!.videoUrl != null) {
        videoUrl = exercice!.videoUrl;
      }
      youtubeUrl = exercice!.youtubeUrl;
    } else {
      exercice = Exercice();
      subjectStoragePair.sink.add(null);
    }
  }

  Future<void> saveExercice() async {
    if (exercice != null) {
      if (exercice!.uid != null) {
        return eraseAndReplaceStorage(exercice!).then((_) => save(exercice!));
      } else {
        exercice!.uid = getCollectionReference().doc().id;
        return createStorage(exercice!).then((_) => create(exercice!));
      }
    }
    return;
  }

  @override
  String getUrl(User user, Exercice exercice) {
    return 'trainers/${user.uid}/exercices/${exercice.uid}';
  }

  Stream<List<Exercice>> getStreamExercice() {
    return trainersService.listenToExercice();
  }

  Future<void> deleteExercice(Exercice exercice) {
    return trainersService.getExerciceReference().doc(exercice.uid).delete().then((_) => deleteAllFiles(exercice));
  }

  set typeExercice(String? value) {
    exercice?.typeExercice = value;
  }

  String? get typeExercice => exercice?.typeExercice;

  set name(String? value) {
    exercice?.name = value;
  }

  String? get name => exercice?.name;

  set description(String? value) {
    exercice?.description = value;
  }

  String? get description => exercice?.description;

  set videoUrl(String? value) {
    exercice?.videoUrl = value;
    _streamSelectedVideoUrl.sink.add(value);
  }

  String? get videoUrl => exercice?.videoUrl;

  set youtubeUrl(String? value) {
    exercice?.youtubeUrl = value;
    _streamSelectedYoutubeUrl.sink.add(value);
  }

  String? get youtubeUrl => exercice?.youtubeUrl;

  void setStoragePair(StorageFile? storageFile) {
    exercice?.storageFile = storageFile;
    subjectStoragePair.sink.add(exercice?.storageFile);
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getExerciceReference();
  }

  @override
  Widget openUpdate(BuildContext context, Exercice exercice) {
    return ExerciceUpdatePage(exercice: exercice);
  }
}
