import 'dart:async';

import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/firebase-storage.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart' as rx;

import 'exercice.service.dart';

abstract class AbstractExerciceController {
  final TrainersService trainersService = Get.find();
  final FirebaseStorageService storageService = Get.find();
  final ExerciceService exerciceService = Get.find();

  Rx<Exercice> exercice = Exercice().obs;

  bool sendStorage = false;

  Future<void> init(Exercice? exerciceEntered) async {
    sendStorage = false;

    if (exerciceEntered != null) {
      exercice.value = exerciceEntered;

      if (exerciceEntered.imageUrl != null) {
        final StorageFile? value = await storageService.getFutureStorageFile(exerciceEntered.imageUrl);
        exercice.value.storageFile = value;
      }
    }
  }

  Future<void> saveExercice() async {
    return exerciceService.saveExercice(exercice.value, sendStorage: sendStorage);
  }

  void setStoragePair(StorageFile? stFile) {
    sendStorage = true;
    exercice.update((Exercice? exo) {
      if (exo != null) {
        exo.storageFile = stFile ?? StorageFile();
        exo.imageUrl = null;
      }
    });
  }
}

class ExerciceCreateController extends GetxController with AbstractExerciceController {
}

class ExerciceUpdateController extends GetxController with AbstractExerciceController {
  RxBool isSet = false.obs;

  @override
  Future<void> init(Exercice? exerciceEntered) async {
    sendStorage = false;

    isSet.value = exerciceEntered != null && exerciceEntered.uid != null;

    if (exerciceEntered != null) {
      exercice.value = exerciceEntered;

      if (exerciceEntered.imageUrl != null) {
        final StorageFile? value = await storageService.getFutureStorageFile(exerciceEntered.imageUrl);
        exercice.value.storageFile = value;
      }
    }
    update();
  }

  void deleteExercice(Exercice exerciceDeleted) {
    if (exerciceDeleted.uid == exercice.value.uid) {
      init(null);
    }
  }
}