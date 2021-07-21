import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/service/firestorage.service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/programme.domain.dart';
import 'package:fitnc_trainer/service/param.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/widgets/storage_image.widget.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class ProgrammeUpdateBloc {
  FirestorageService firestorageService = FirestorageService.getInstance();
  TrainersService trainersService = TrainersService.getInstance();
  ParamService paramService = ParamService.getInstance();

  late Programme programme;
  StorageFile? storagePair;

  BehaviorSubject<StorageFile?> subjectStoragePair = BehaviorSubject<StorageFile?>();
  BehaviorSubject<String?> _streamSelectedVideoUrl = BehaviorSubject();
  BehaviorSubject<String?> _streamSelectedYoutubeUrl = BehaviorSubject();

  Stream<String?>? get selectedVideoUrlObs => _streamSelectedVideoUrl.stream;

  Stream<String?>? get selectedYoutubeUrlObs => _streamSelectedYoutubeUrl.stream;

  Stream<StorageFile?> get obsStoragePair => subjectStoragePair.stream;

  static ProgrammeUpdateBloc? _instance;
  final String pathProgrammeMainImage = 'mainImage';

  ProgrammeUpdateBloc._();

  static ProgrammeUpdateBloc getInstance() {
    if (_instance == null) {
      _instance = ProgrammeUpdateBloc._();
    }
    return _instance!;
  }

  void init(Programme? programmeEntered) {
    storagePair = StorageFile();
    subjectStoragePair.sink.add(null);

    if (programmeEntered != null) {
      programme = programmeEntered;

      if (programme.imageUrl != null && programme.imageUrl!.isNotEmpty) {
        firestorageService.getRemoteImageToUint8List(programme.imageUrl!).then((bytes) {
          storagePair!.fileName = basename(programme.imageUrl!);
          storagePair!.fileBytes = bytes;
          subjectStoragePair.sink.add(storagePair);
        });
      }
    } else {
      programme = Programme();
      subjectStoragePair.sink.add(null);
    }
  }

  Programme? getProgramme() {
    return programme;
  }

  Future<void> saveProgramme() {
    if (programme.uid != null && programme.uid?.isNotEmpty == true) {
      return updateProgramme();
    } else {
      return createProgramme();
    }
  }

  Future<void> createProgramme() async {
    CollectionReference<Object?> collectionReference = trainersService.getProgrammeReference();

    programme.uid = collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> updateProgramme() async {
    CollectionReference<Object?> collectionReference = trainersService.getProgrammeReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      await deleteProgrammeMainImage(programme);
      await sendToStorage();
    }

    if (storagePair == null || storagePair?.fileName == null || storagePair?.fileBytes == null) {
      await deleteProgrammeMainImage(programme);
      programme.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  String getUrl() {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    return 'trainers/$trainerUid/programme/${programme.uid}/$pathProgrammeMainImage';
  }

  Future<void> sendToFireStore(CollectionReference<Object?> collectionReference) {
    programme.createDate = FieldValue.serverTimestamp();
    return collectionReference.doc(programme.uid).set(programme.toJson()).then((value) {
      programme = Programme();
    });
  }

  Future<void> sendToStorage() async {
    String? trainerUid = FirebaseAuth.instance.currentUser?.uid;
    if (trainerUid != null && storagePair != null && storagePair!.fileBytes != null && storagePair!.fileName != null) {
      programme.imageUrl = await firestorageService.sendToStorageAndGetReference('${getUrl()}/${storagePair!.fileName}', storagePair!.fileBytes!);
    }
  }

  Stream<List<Programme?>> getStreamProgramme() {
    return trainersService.listenToProgramme();
  }

  Future<void> deleteProgramme(Programme programme) {
    return trainersService.getProgrammeReference().doc(programme.uid).delete().then((value) => deleteProgrammeMainImage(programme));
  }

  Future<void> deleteProgrammeMainImage(Programme programme) {
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
    programme.name = value;
  }

  setDescription(String value) {
    programme.description = value;
  }

  setStoragePair(StorageFile? storagePair) {
    this.storagePair = storagePair;
    this.subjectStoragePair.sink.add(this.storagePair);
  }
}
