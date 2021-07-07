import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/workout.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class WorkoutUpdateBloc {
  TrainersService trainersService = TrainersService.getInstance();
  late Workout _workout;

  Uint8List? _fileBytes;
  String? _fileName;
  String? _oldFileName;

  BehaviorSubject<Uint8List?>? _streamSelectedImage;

  Stream<Uint8List?>? get selectedImageObs => _streamSelectedImage?.stream;

  static WorkoutUpdateBloc? _instance;
  final String pathWorkoutMainImage = 'mainImage';

  WorkoutUpdateBloc._();

  static WorkoutUpdateBloc getInstance() {
    if (_instance == null) {
      _instance = WorkoutUpdateBloc._();
    }
    return _instance!;
  }

  void init(Workout? workout) {
    _fileBytes = null;
    _fileName = null;
    _streamSelectedImage = BehaviorSubject();
    if (workout != null) {
      _workout = workout;
      if (_workout.imageUrl != null) {
        getRemoteImageToUint8List(_workout.imageUrl!).then((bytes) {
          _oldFileName = basename(_workout.imageUrl!);
          setImage(bytes, _oldFileName);
        });
      }
    } else {
      _workout = Workout();
    }
  }

  Workout? getWorkout() {
    return _workout;
  }

  void dispose() {
    _streamSelectedImage?.close();
  }

  Future<void> saveWorkout() {
    if (_workout.uid != null && _workout.uid?.isNotEmpty == true) {
      return updateWorkout();
    } else {
      return createWorkout();
    }
  }

  Future<void> createWorkout() async {
    CollectionReference<Object?> collectionReference =
        trainersService.getWorkoutReference();

    _workout.uid =
        collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (_fileBytes != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> updateWorkout() async {
    CollectionReference<Object?> collectionReference =
        trainersService.getWorkoutReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (_fileBytes != null && _oldFileName != _fileName) {
      await deleteWorkoutMainImage(_workout);
      await sendToStorage();
    }

    if (_fileBytes == null) {
      await deleteWorkoutMainImage(_workout);
      _workout.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> sendToFireStore(
      CollectionReference<Object?> collectionReference) {
    _workout.createDate = FieldValue.serverTimestamp();
    return collectionReference
        .doc(_workout.uid)
        .set(_workout.toJson())
        .then((value) {
      _workout = Workout();
    });
  }

  Future<void> sendToStorage() async {
    _workout.imageUrl = await FirebaseStorage.instance
        .ref('${_workout.uid}/$pathWorkoutMainImage/$_fileName')
        .putData(_fileBytes!)
        .then((ref) => ref.ref.getDownloadURL());
  }

  Stream<List<Workout?>> getStreamWorkout() {
    return trainersService.listenToWorkout();
  }

  Future<void> deleteWorkout(Workout workout) {
    return trainersService
        .getWorkoutReference()
        .doc(workout.uid)
        .delete()
        .then((value) => deleteWorkoutMainImage(workout));
  }

  Future<void> deleteWorkoutMainImage(Workout workout) {
    return FirebaseStorage.instance
        .ref('${workout.uid}/$pathWorkoutMainImage')
        .listAll()
        .then((value) => value.items.forEach((element) => element.delete()))
        .catchError((error) => print(error));
  }

  changeName(String value) {
    _workout.name = value;
  }

  changeDescription(String value) {
    _workout.description = value;
  }

  changeTimerType(String? value) {
    _workout.timerType = value;
  }

  void setImage(Uint8List? bytes, String? name) {
    _fileBytes = bytes;
    _fileName = name;
    _streamSelectedImage?.sink.add(_fileBytes);
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

  changeDateDebut(String value) {
    _workout.dateDebut = value;
  }

  changeDateFin(String value) {
    _workout.dateFin = value;
  }
}
