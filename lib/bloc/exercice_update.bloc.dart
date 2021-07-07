import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class ExerciceUpdateBloc {
  TrainersService trainersService = TrainersService.getInstance();
  late Exercice _exercice;

  Uint8List? _fileBytes;
  String? _fileName;
  String? _oldFileName;

  BehaviorSubject<Uint8List?>? _streamSelectedImage;

  Stream<Uint8List?>? get selectedImageObs => _streamSelectedImage?.stream;

  static ExerciceUpdateBloc? _instance;
  final String pathExerciceMainImage = 'mainImage';

  ExerciceUpdateBloc._();

  static ExerciceUpdateBloc getInstance() {
    if (_instance == null) {
      _instance = ExerciceUpdateBloc._();
    }
    return _instance!;
  }

  void init(Exercice? exercice) {
    _fileBytes = null;
    _fileName = null;
    _streamSelectedImage = BehaviorSubject();
    if (exercice != null) {
      _exercice = exercice;
      if (_exercice.imageUrl != null) {
        getRemoteImageToUint8List(_exercice.imageUrl!).then((bytes) {
          _oldFileName = basename(_exercice.imageUrl!);
          setImage(bytes, _oldFileName);
        });
      }
    } else {
      _exercice = Exercice();
    }
  }

  Exercice? getExercice() {
    return _exercice;
  }

  void dispose() {
    _streamSelectedImage?.close();
  }

  Future<void> saveExercice() {
    if (_exercice.uid != null && _exercice.uid?.isNotEmpty == true) {
      return updateExercice();
    } else {
      return createExercice();
    }
  }

  Future<void> createExercice() async {
    CollectionReference<Object?> collectionReference =
        trainersService.getExerciceReference();

    _exercice.uid =
        collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (_fileBytes != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> updateExercice() async {
    CollectionReference<Object?> collectionReference =
        trainersService.getExerciceReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (_fileBytes != null && _oldFileName != _fileName) {
      await deleteExerciceMainImage(_exercice);
      await sendToStorage();
    }

    if (_fileBytes == null) {
      await deleteExerciceMainImage(_exercice);
      _exercice.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> sendToFireStore(
      CollectionReference<Object?> collectionReference) {
    _exercice.createDate = FieldValue.serverTimestamp();
    return collectionReference
        .doc(_exercice.uid)
        .set(_exercice.toJson())
        .then((value) {
      _exercice = Exercice();
    });
  }

  Future<void> sendToStorage() async {
    _exercice.imageUrl = await FirebaseStorage.instance
        .ref('${_exercice.uid}/$pathExerciceMainImage/$_fileName')
        .putData(_fileBytes!)
        .then((ref) => ref.ref.getDownloadURL());
  }

  Stream<List<Exercice?>> getStreamExercice() {
    return trainersService.listenToExercice();
  }

  Future<void> deleteExercice(Exercice exercice) {
    return trainersService
        .getExerciceReference()
        .doc(exercice.uid)
        .delete()
        .then((value) => deleteExerciceMainImage(exercice));
  }

  Future<void> deleteExerciceMainImage(Exercice exercice) {
    return FirebaseStorage.instance
        .ref('${exercice.uid}/$pathExerciceMainImage')
        .listAll()
        .then((value) => value.items.forEach((element) => element.delete()))
        .catchError((error) => print(error));
  }

  changeName(String value) {
    _exercice.name = value;
  }

  changeDescription(String value) {
    _exercice.description = value;
  }

  void setImage(Uint8List? bytes, String? name) {
    _fileBytes = bytes;
    _fileName = name;
    _streamSelectedImage?.sink.add(_fileBytes);
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

}
