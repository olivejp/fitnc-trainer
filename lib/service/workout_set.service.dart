import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/exercice.domain.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_set.domain.dart';
import 'package:fitness_domain/domain/workout_set.dto.dart';
import 'package:get/get.dart';

class WorkoutSetService extends GetxService {
  WorkoutSetService();

  final TrainersService trainersService = Get.find();
  final ExerciceService exerciceService = Get.find();

  CollectionReference getWorkoutReference() {
    return trainersService.getCurrentTrainerRef().collection('workout');
  }

  CollectionReference getWorkoutSetsReference(Workout workout) {
    return getWorkoutReference().doc(workout.uid).collection('sets');
  }

  Stream<List<WorkoutSet?>> listenToWorkoutStep(Workout workout) {
    return getWorkoutSetsReference(workout)
        .orderBy('order')
        .snapshots()
        .map((QuerySnapshot event) => event.docs.map((doc) => WorkoutSet.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  Stream<List<WorkoutSetDto?>> listenToWorkoutStepDto(Workout workout) {
    return getWorkoutSetsReference(workout)
        .orderBy('order')
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => WorkoutSet.fromJson(doc.data() as Map<String, dynamic>)).map((workoutSet) => mapToDto(workoutSet)).toList())
        .asyncMap((futures) => Future.wait(futures));
  }

  Future<WorkoutSetDto> mapToDto(WorkoutSet workoutSet) async {
    final WorkoutSetDto dto = WorkoutSetDto.fromSet(workoutSet);

    // Recherche des infos de l'exercice
    if (workoutSet.uidExercice != null) {
      final Exercice? exercice = await exerciceService.read(workoutSet.uidExercice!);
      if (exercice != null) {
        dto.imageUrlExercice = exercice.imageUrl;
        dto.nameExercice = exercice.name;
        dto.typeExercice = exercice.typeExercice;
      } else {
        throw Exception("L'exercice avec l'uid ${workoutSet.uidExercice} n'a pas été trouvé.");
      }
    }
    return dto;
  }
}
