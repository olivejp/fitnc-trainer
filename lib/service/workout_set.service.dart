import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:fitness_domain/domain/workout.domain.dart';
import 'package:fitness_domain/domain/workout_set.domain.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:get/get.dart';

class WorkoutSetService extends AbstractFirebaseSubcollectionCrudService<WorkoutSet, Workout, WorkoutService> {
  WorkoutSetService();

  final ExerciceService exerciceService = Get.find();
  final WorkoutService workoutService = Get.find();

  @override
  WorkoutSet fromJson(Map<String, dynamic> map) {
    return WorkoutSet.fromJson(map);
  }

  @override
  String getCollectionName() {
    return 'sets';
  }

  Future<List<WorkoutSet>> getAllWorkoutSet(Workout workout) {
    return getQuery(getCollectionReference(workout.uid!).orderBy('order'));
  }

  String getNewUid(Workout workout) {
    return getCollectionReference(workout.uid!).doc().id;
  }

  DocumentReference<Object?> getSetRef(WorkoutSet dto) {
    return getCollectionReference(dto.getParentUid()).doc(dto.uid);
  }

  Future<List<WorkoutSet>> getQuery(Query<Map<String, dynamic>> query) async {
    return (await query.get()).docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => WorkoutSet.fromJson(doc.data())).toList();
  }

  Stream<List<WorkoutSet>> listenQuery(Query<Map<String, dynamic>> query) {
    return query.snapshots().map((QuerySnapshot<Map<String, dynamic>> event) =>
        event.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => WorkoutSet.fromJson(doc.data())).toList());
  }
}
