import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class ExerciceUpdateBloc {
  TrainersService trainersService = TrainersService.getInstance();
  ParamService paramService = ParamService.getInstance();
  late Exercice exercice;

  Uint8List? _fileBytes;
  String? _fileName;
  String? _oldFileName;

  BehaviorSubject<Uint8List?>? _streamSelectedImage;
  BehaviorSubject<String?>? _streamSelectedVideoUrl;
  BehaviorSubject<String?>? _streamSelectedYoutubeUrl;

  Stream<Uint8List?>? get selectedImageObs => _streamSelectedImage?.stream;
  Stream<String?>? get selectedVideoUrlObs => _streamSelectedVideoUrl?.stream;
  Stream<String?>? get selectedYoutubeUrlObs => _streamSelectedYoutubeUrl?.stream;

  static ExerciceUpdateBloc? _instance;
  final String pathExerciceMainImage = 'mainImage';

  ExerciceUpdateBloc._();

  static ExerciceUpdateBloc getInstance() {
    if (_instance == null) {
      _instance = ExerciceUpdateBloc._();
    }
    return _instance!;
  }

  void init(Exercice? exerciceEntered) {
    _fileBytes = null;
    _fileName = null;
    _streamSelectedImage = BehaviorSubject();
    _streamSelectedVideoUrl = BehaviorSubject();
    _streamSelectedYoutubeUrl = BehaviorSubject();
    if (exerciceEntered != null) {
      exercice = exerciceEntered;
      if (exercice.imageUrl != null) {
        getRemoteImageToUint8List(exercice.imageUrl!).then((bytes) {
          _oldFileName = basename(exercice.imageUrl!);
          setImage(bytes, _oldFileName);
        });
      }
      if (exercice.videoUrl != null) {
        setVideoUrl(exercice.videoUrl!);
      }
    } else {
      exercice = Exercice();
    }
  }

  Exercice? getExercice() {
    return exercice;
  }

  void dispose() {
    _streamSelectedImage?.close();
  }

  Future<void> saveExercice() {
    if (exercice.uid != null && exercice.uid?.isNotEmpty == true) {
      return updateExercice();
    } else {
      return createExercice();
    }
  }

  Future<void> createExercice() async {
    CollectionReference<Object?> collectionReference =
        trainersService.getExerciceReference();

    exercice.uid =
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
      await deleteExerciceMainImage(exercice);
      await sendToStorage();
    }

    if (_fileBytes == null) {
      await deleteExerciceMainImage(exercice);
      exercice.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> sendToFireStore(
      CollectionReference<Object?> collectionReference) {
    exercice.createDate = FieldValue.serverTimestamp();
    return collectionReference
        .doc(exercice.uid)
        .set(exercice.toJson())
        .then((value) {
      exercice = Exercice();
    });
  }

  Future<void> sendToStorage() async {
    exercice.imageUrl = await FirebaseStorage.instance
        .ref('${exercice.uid}/$pathExerciceMainImage/$_fileName')
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
    exercice.name = value;
  }

  changeDescription(String value) {
    exercice.description = value;
  }

  void setImage(Uint8List? bytes, String? name) {
    _fileBytes = bytes;
    _fileName = name;
    _streamSelectedImage?.sink.add(_fileBytes);
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

  setVideoUrl(String value) {
    exercice.videoUrl = value;
    _streamSelectedVideoUrl?.sink.add(value);
  }

  setYoutubeUrl(String value) {
    exercice.youtubeUrl = value;
    _streamSelectedYoutubeUrl?.sink.add(value);
  }
}

