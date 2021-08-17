import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:rxdart/rxdart.dart';

class ExerciceUpdateBloc extends AbstractFitnessCrudBloc<Exercice> with MixinFitnessStorageBloc<Exercice> {
  ExerciceUpdateBloc._();

  factory ExerciceUpdateBloc.instance() {
    _instance ??= ExerciceUpdateBloc._();
    return _instance!;
  }

  static ExerciceUpdateBloc? _instance;

  TrainersService trainersService = TrainersService.instance();
  ParamService paramService = ParamService.getInstance();
  Exercice? exercice;
  bool sendStorage = false;

  final BehaviorSubject<StorageFile?> subjectStoragePair = BehaviorSubject<StorageFile?>();
  final BehaviorSubject<String?> _streamSelectedVideoUrl = BehaviorSubject<String?>();
  final BehaviorSubject<String?> _streamSelectedYoutubeUrl = BehaviorSubject<String?>();

  Stream<String?>? get selectedVideoUrlObs => _streamSelectedVideoUrl.stream;

  Stream<String?>? get selectedYoutubeUrlObs => _streamSelectedYoutubeUrl.stream;

  Stream<StorageFile?> get obsStoragePair => subjectStoragePair.stream;

  @override
  Stream<List<Exercice>> listenAll() {
    return trainersService.listenToExercice();
  }

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getExerciceReference();
  }

  @override
  String getStorageRef(User user, Exercice exercice) {
    return 'trainers/${user.uid}/exercices/${exercice.uid}';
  }

  void init(Exercice? exerciceEntered) {
    subjectStoragePair.sink.add(null);
    videoUrl = null;
    youtubeUrl = null;

    if (exerciceEntered != null) {
      exercice = exerciceEntered;
      exercice!.storageFile = StorageFile();
      getFutureStorageFile(exercice!).then((StorageFile? value) {
        exercice!.storageFile = value;
        subjectStoragePair.sink.add(value);
      });

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
    if (exercice == null) {
      return;
    }

    bool isUpdate = exercice!.uid != null;
    if (isUpdate) {
      if (sendStorage) {
        return eraseAndReplaceStorage(exercice!).then((_) => save(exercice!));
      } else {
        return save(exercice!);
      }
    } else {
      exercice!.uid = getCollectionReference().doc().id;
      return createStorage(exercice!).then((_) => create(exercice!));
    }
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
    sendStorage = true;
    exercice?.storageFile = storageFile;
    subjectStoragePair.sink.add(exercice?.storageFile);
  }
}
