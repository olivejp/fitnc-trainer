import 'dart:async';

import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/storage-file.dart';
import 'package:fitness_domain/domain/workout_set.domain.dart';
import 'package:fitness_domain/service/firebase-storage.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart' as rx;

import 'exercice.service.dart';

abstract class AbstractExerciceController {
  final TrainersService trainersService = Get.find();
  final FirebaseStorageService storageService = Get.find();
  final ExerciceService exerciceService = Get.find();
  final WorkoutSetService workoutSetService = Get.find();

  Rx<Exercice> exercice = Exercice().obs;

  Future<void> init(Exercice? exerciceEntered) async {
    if (exerciceEntered != null) {
      exercice.value = exerciceEntered;

      if (exerciceEntered.imageUrl != null) {
        final StorageFile? value = await storageService.getFutureStorageFile(exerciceEntered.imageUrl);
        exercice.value.storageFile = value;
      }
    }
  }

  Future<void> saveExercice() async {
    return exerciceService.save(exercice.value);
  }

  void setStoragePair(StorageFile? stFile) {
    exercice.update((Exercice? exo) {
      if (exo != null) {
        exo.storageFile = stFile ?? StorageFile();
        exo.imageUrl = null;
      }
    });
  }

  Future<void> changeExerciceType(BuildContext context, String? typeExercice) async {
    if (exercice.value.typeExercice != typeExercice) {
      final List<WorkoutSet> list = await workoutSetService.getAllWhereUidExerciceIs(exercice.value.uid!);
      final List<WorkoutSet> listFiltered = list.where((WorkoutSet set) => set.typeExercice != typeExercice).toList();
      if (listFiltered.isNotEmpty) {
        final WorkoutSet set = listFiltered.first;
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  title: Text('Attention'),
                  content: Text('Cet exercice est déjà utilisé dans des workouts avec le type ${set.typeExercice}.\n'
                      'Le nouveau type choisi ne sera pas répercutée sur les workouts qui utilisent cet exercice.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        exercice.value.typeExercice = typeExercice;
                        Navigator.of(context).pop();
                      },
                      child: Text('Continuer'),
                    ),
                  ],
                ));
      } else {
        exercice.value.typeExercice = typeExercice;
      }
    } else {
      exercice.value.typeExercice = typeExercice;
    }
  }
}

class ExerciceCreateController extends GetxController with AbstractExerciceController {}

class ExerciceUpdateController extends GetxController with AbstractExerciceController {
  RxBool isSet = false.obs;

  @override
  Future<void> init(Exercice? exerciceEntered) async {
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
