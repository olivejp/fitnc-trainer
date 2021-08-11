import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class AbonneUpdateBloc {
  AbonneUpdateBloc._();

  factory AbonneUpdateBloc.instance() {
    _instance ??= AbonneUpdateBloc._();
    return _instance!;
  }

  static AbonneUpdateBloc? _instance;

  final TrainersService trainersService = TrainersService.instance();
  Abonne abonne = Abonne();
  Uint8List? _fileBytes;

  String? _fileName;

  String? _oldFileName;

  BehaviorSubject<Uint8List?>? _streamSelectedImage;
  Stream<Uint8List?>? get selectedImageObs => _streamSelectedImage?.stream;

  final String pathAbonneMainImage = 'mainImage';
  
  void init(Abonne? enteredAbonne) {
    _fileBytes = null;
    _fileName = null;
    _streamSelectedImage = BehaviorSubject();
    if (enteredAbonne != null) {
      abonne = enteredAbonne;
      if (abonne.imageUrl != null) {
        getRemoteImageToUint8List(abonne.imageUrl!).then((bytes) {
          _oldFileName = basename(abonne.imageUrl!);
          setImage(bytes, _oldFileName);
        });
      }
    } else {
      abonne = Abonne();
    }
  }

  Abonne? getAbonne() {
    return abonne;
  }

  void dispose() {
    _streamSelectedImage?.close();
  }

  Future<void> saveAbonne() {
    if (abonne.uid != null && abonne.uid?.isNotEmpty == true) {
      return updateAbonne();
    } else {
      return createAbonne();
    }
  }

  Future<void> createAbonne() async {
    CollectionReference<Object?> collectionReference = trainersService.getAbonneReference();

    abonne.uid = collectionReference.doc().id; // Récupération d'une nouvelle ID.

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (_fileBytes != null) {
      await sendToStorage();
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> updateAbonne() async {
    CollectionReference<Object?> collectionReference = trainersService.getAbonneReference();

    // Si un fichier est présent, on tente de l'envoyer sur le Storage.
    if (_fileBytes != null && _oldFileName != _fileName) {
      await deleteAbonneMainImage(abonne);
      await sendToStorage();
    }

    if (_fileBytes == null) {
      await deleteAbonneMainImage(abonne);
      abonne.imageUrl = null;
    }
    return sendToFireStore(collectionReference);
  }

  Future<void> sendToFireStore(CollectionReference<Object?> collectionReference) {
    abonne.createDate = FieldValue.serverTimestamp();
    return collectionReference.doc(abonne.uid).set(abonne.toJson()).then((value) {
      abonne = Abonne();
    });
  }

  Future<void> sendToStorage() async {
    abonne.imageUrl = await FirebaseStorage.instance
        .ref('${abonne.uid}/$pathAbonneMainImage/$_fileName')
        .putData(_fileBytes!)
        .then((ref) => ref.ref.getDownloadURL());
  }

  Stream<List<Abonne?>> getStreamAbonne() {
    return trainersService.listenToAbonne();
  }

  Future<void> deleteAbonne(Abonne abonne) {
    return trainersService.getAbonneReference().doc(abonne.uid).delete().then((value) => deleteAbonneMainImage(abonne));
  }

  Future<void> deleteAbonneMainImage(Abonne abonne) {
    return FirebaseStorage.instance
        .ref('${abonne.uid}/$pathAbonneMainImage')
        .listAll()
        .then((value) => value.items.forEach((element) => element.delete()))
        .catchError((error) => print(error));
  }

  changeName(String value) {
    abonne.nom = value;
  }

  Future<void> update(Abonne abonne) {
    return trainersService.getAbonneReference().doc(abonne.uid).set(abonne.toJson());
  }

  void setImage(Uint8List? bytes, String? name) {
    _fileBytes = bytes;
    _fileName = name;
    _streamSelectedImage?.sink.add(_fileBytes);
  }

  Future<Uint8List> getRemoteImageToUint8List(String imageUrl) async {
    return http.readBytes(Uri.parse(imageUrl));
  }

  changeDateNaissance(String? value) {
    abonne.dateNaissance = value;
  }

  changePrenom(String value) {
    abonne.prenom = value;
  }

  changeTelephone1(String value) {
    abonne.telephone1 = int.tryParse(value);
  }

  changeEmail(String value) {
    abonne.email = value;
  }

  changeTelephone2(String value) {
    abonne.telephone2 = int.tryParse(value);
  }

  changeAdresse1(String value) {
    abonne.adresse1 = value;
  }

  changeAdresse2(String value) {
    abonne.adresse2 = value;
  }

  changeAdresse3(String value) {
    abonne.adresse3 = value;
  }
}
