import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:rxdart/rxdart.dart';

class AddWorkoutBloc {
  TrainersService trainersService = TrainersService.getInstance();
  Workout _workout = Workout();

  Uint8List? fileBytes;
  String? fileName;

  BehaviorSubject<Uint8List?>? _streamSelectedImage;

  Stream<Uint8List?>? get selectedImageObs => _streamSelectedImage?.stream;

  static AddWorkoutBloc? _instance;

  AddWorkoutBloc._();

  static AddWorkoutBloc getInstance() {
    if (_instance == null) {
      _instance = AddWorkoutBloc._();
    }
    return _instance!;
  }

  void init() {
    fileBytes = null;
    fileName = null;
    _streamSelectedImage = BehaviorSubject();
  }

  void dispose() {
    _streamSelectedImage?.close();
  }

  Future<void> addWorkout() async {
    CollectionReference collectionReference =
        trainersService.getWorkoutReference();

    _workout.uid =
        collectionReference.doc().id; // Récupération d'une nouvelle ID.
    _workout.createDate = FieldValue.serverTimestamp();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (fileBytes != null) {
      _workout.imageUrl = await FirebaseStorage.instance
          .ref('uploads/${_workout.uid}/$fileName')
          .putData(fileBytes!)
          .then((ref) => ref.ref.getDownloadURL());
    }

    return collectionReference
        .doc(_workout.uid)
        .set(_workout.toJson())
        .then((value) {
      _workout = Workout();
    });
  }

  Stream<List<Workout?>> getStreamWorkout() {
    return trainersService.listenToWorkout();
  }

  Future<void> deleteWorkout(Workout workout) {
    return trainersService.getWorkoutReference().doc(workout.uid).delete().then(
        (value) => FirebaseStorage.instance
            .ref('uploads/${workout.uid}')
            .listAll()
            .then((value) => value.items.forEach((element) => element.delete()))
            .catchError((error) => print(error)));
  }

  changeName(String value) {
    _workout.name = value;
  }

  changeDescription(String value) {
    _workout.description = value;
  }

  Future<void> update(Workout workout) {
    return trainersService
        .getWorkoutReference()
        .doc(workout.uid)
        .set(workout.toJson());
  }

  void setImage(Uint8List? bytes, String? name) {
    fileBytes = bytes;
    fileName = name;
    _streamSelectedImage?.sink.add(fileBytes);
  }
}
