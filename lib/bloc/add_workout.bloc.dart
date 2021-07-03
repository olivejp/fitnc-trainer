import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';

class AddWorkoutBloc {
  TrainersService trainersService = TrainersService.getInstance();
  Workout _workout = Workout();

  static AddWorkoutBloc _instance;

  AddWorkoutBloc._();

  static AddWorkoutBloc getInstance() {
    if (_instance == null) {
      _instance = AddWorkoutBloc._();
    }
    return _instance;
  }

  Future<void> addWorkout() {
    CollectionReference collectionReference =
        trainersService.getWorkoutReference();

    _workout.uid = collectionReference.doc().id;
    _workout.createDate = FieldValue.serverTimestamp();
    return collectionReference
        .doc(_workout.uid)
        .set(_workout.toJson())
        .then((value) {
      _workout = Workout();
    });
  }

  Stream<List<Workout>> getStreamWorkout() {
    return trainersService.listenToWorkout();
  }

  Future<void> deleteWorkout(Workout workout) {
    return trainersService.getWorkoutReference().doc(workout.uid).delete();
  }

  changeName(String value) {
    _workout.name = value;
  }

  Future<void> update(Workout workout) {
    return trainersService.getWorkoutReference().doc(workout.uid).set(workout.toJson());
  }
}
