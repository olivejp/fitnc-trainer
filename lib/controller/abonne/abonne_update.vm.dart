import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/abonne.domain.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

class AbonneUpdateController {
  final TrainersService trainersService = Get.find();
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

  Future<void> saveAbonne() {
    if (abonne.uid != null && abonne.uid?.isNotEmpty == true) {
      return updateAbonne();
    } else {
      return createAbonne();
    }
  }

  Future<void> createAbonne() async {
    final CollectionReference<Object?> collectionReference = trainersService.getAbonneReference();

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

  set changeName(String value) {
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

  set dateNaissance(String? value) {
    abonne.dateNaissance = value;
  }

  String? get dateNaissance => abonne.dateNaissance;

  set sexe(String? value) {
    abonne.sexe = value;
  }

  String? get sexe => abonne.sexe;

  set nom(String? value) {
    abonne.nom = value;
  }

  String? get nom => abonne.nom;

  set prenom(String? value) {
    abonne.prenom = value;
  }

  String? get prenom => abonne.prenom;

  set telephone1(int? value) {
    abonne.telephone1 = value;
  }

  int? get telephone1 => abonne.telephone1;

  set email(String? value) {
    abonne.email = value;
  }

  String? get email => abonne.email;

  set telephone2(int? value) {
    abonne.telephone2 = value;
  }

  int? get telephone2 => abonne.telephone2;

  set adresse1(String? value) {
    abonne.adresse1 = value;
  }

  String? get adresse1 => abonne.adresse1;

  set adresse2(String? value) {
    abonne.adresse2 = value;
  }

  String? get adresse2 => abonne.adresse2;

  set adresse3(String? value) {
    abonne.adresse3 = value;
  }

  String? get adresse3 => abonne.adresse3;
}
