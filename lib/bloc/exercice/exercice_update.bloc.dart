import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/exercice.domain.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class ExerciceUpdateBloc {
  FirestorageService firestorageService = FirestorageService.getInstance();
  TrainersService trainersService = TrainersService.getInstance();
  ParamService paramService = ParamService.getInstance();
  late Exercice exercice;
  StorageFile? storagePair;

  BehaviorSubject<StorageFile?> subjectStoragePair = BehaviorSubject<StorageFile?>();
  BehaviorSubject<String?> _streamSelectedVideoUrl = BehaviorSubject();
  BehaviorSubject<String?> _streamSelectedYoutubeUrl = BehaviorSubject();

  Stream<String?>? get selectedVideoUrlObs => _streamSelectedVideoUrl.stream;

  Stream<String?>? get selectedYoutubeUrlObs => _streamSelectedYoutubeUrl.stream;

  Stream<StorageFile?> get obsStoragePair => subjectStoragePair.stream;

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
    storagePair = StorageFile();
    subjectStoragePair.sink.add(null);

    if (exerciceEntered != null) {
      exercice = exerciceEntered;

      if (exercice.imageUrl != null && exercice.imageUrl!.isNotEmpty) {
        firestorageService.getRemoteImageToUint8List(exercice.imageUrl!).then((bytes) {
          storagePair!.fileName = basename(exercice.imageUrl!);
          storagePair!.fileBytes = bytes;
          subjectStoragePair.sink.add(storagePair);
        });
      }

      if (exercice.videoUrl != null) {
        setVideoUrl(exercice.videoUrl!);
      }
      setYoutubeUrl(exercice.youtubeUrl);
    } else {
      exercice = Exercice();
      subjectStoragePair.sink.add(null);
    }
  }

  Exercice? getExercice() {
    return exercice;
  }

  Future<void> saveExercice() {
    if (exercice.uid != null && exercice.uid?.isNotEmpty == true) {
      return updateExercice();
    } else {
      return createExercice();
    }
  }

  Future<void> createExercice() async {
    CollectionReference<Object?> collectionReference = trainersService.getExerciceReference();

    exercice.uid = collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> updateExercice() async {
    CollectionReference<Object?> collectionReference = trainersService.getExerciceReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await deleteExerciceMainImage(exercice);
      await sendToStorage();
    }

    if (storagePair == null || storagePair?.fileName == null || storagePair?.fileBytes == null) {
      await deleteExerciceMainImage(exercice);
      exercice.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  String getUrl() {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    return 'trainers/$trainerUid/exercices/${exercice.uid}/$pathExerciceMainImage';
  }

  Future<void> sendToFireStore(CollectionReference<Object?> collectionReference) {
    exercice.createDate = FieldValue.serverTimestamp();
    return collectionReference.doc(exercice.uid).set(exercice.toJson()).then((value) {
      exercice = Exercice();
    });
  }

  Future<void> sendToStorage() async {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    if (trainerUid != null && storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      exercice.imageUrl = await firestorageService.sendToStorageAndGetReference('${getUrl()}/${storagePair!.fileName}', storagePair!.fileBytes!);
    }
  }

  Stream<List<Exercice?>> getStreamExercice() {
    return trainersService.listenToExercice();
  }

  Future<void> deleteExercice(Exercice exercice) {
    return trainersService.getExerciceReference().doc(exercice.uid).delete().then((value) => deleteExerciceMainImage(exercice));
  }

  Future<void> deleteExerciceMainImage(Exercice exercice) {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    if (trainerUid != null) {
      return FirebaseStorage.instance
          .ref(getUrl())
          .listAll()
          .then((value) => value.items.forEach((element) => element.delete()))
          .catchError((error) => print(error));
    } else {
      return Future.error('Aucun compte trainer connecté');
    }
  }

  setName(String value) {
    exercice.name = value;
  }

  setDescription(String value) {
    exercice.description = value;
  }

  setVideoUrl(String value) {
    exercice.videoUrl = value;
    _streamSelectedVideoUrl.sink.add(value);
  }

  setYoutubeUrl(String? value) {
    exercice.youtubeUrl = value;
    _streamSelectedYoutubeUrl.sink.add(value);
  }

  setStoragePair(StorageFile? storagePair) {
    this.storagePair = storagePair;
    this.subjectStoragePair.sink.add(this.storagePair);
  }
}
