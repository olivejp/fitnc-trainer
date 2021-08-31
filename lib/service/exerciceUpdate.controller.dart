import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/firebase-storage.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import 'exercice.service.dart';

class ExerciceUpdateController extends GetxController {
  final TrainersService trainersService = Get.find();
  final FirebaseStorageService storageService = Get.find();
  final ExerciceService exerciceService = Get.find();

  Exercice? exercice;
  bool sendStorage = false;

  final BehaviorSubject<StorageFile?> subjectStoragePair = BehaviorSubject<StorageFile?>();
  final BehaviorSubject<String?> _streamSelectedVideoUrl = BehaviorSubject<String?>();
  final BehaviorSubject<String?> _streamSelectedYoutubeUrl = BehaviorSubject<String?>();

  String getStoragePath(Exercice exercice) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    if (_firebaseAuth.currentUser != null) {
      final String userUid = _firebaseAuth.currentUser!.uid;
      return 'trainers/$userUid/exercices/${exercice.uid}';
    } else {
      return '';
    }
  }

  void init(Exercice? exerciceEntered) {
    sendStorage = false;
    subjectStoragePair.sink.add(null);

    if (exerciceEntered != null) {
      exercice = exerciceEntered;
      exercice!.storageFile = StorageFile();
      storageService.getFutureStorageFile(exercice!.imageUrl).then((StorageFile? value) {
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

    final bool isUpdate = exercice!.uid != null;
    if (isUpdate) {
      if (sendStorage) {
        String storagePath = getStoragePath(exercice!);
        return storageService.eraseAndReplaceStorage(storagePath, exercice!.storageFile).then((_) => exerciceService.save(exercice!));
      } else {
        return exerciceService.save(exercice!);
      }
    } else {
      exercice!.uid =exerciceService.getCollectionReference().doc().id;
      return exerciceService.createStorage(exercice!).then((_) => exerciceService.create(exercice!));
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
