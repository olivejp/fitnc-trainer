import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';

class AbonneBloc {
  TrainersService trainersService = TrainersService.getInstance();
  Abonne _abonne = Abonne();

  static AbonneBloc? _instance;

  AbonneBloc._();

  static AbonneBloc getInstance() {
    if (_instance == null) {
      _instance = AbonneBloc._();
    }
    return _instance!;
  }

  Future<void> abonne() {
    CollectionReference collectionReference =
        trainersService.getAbonneReference();

    _abonne.uid = collectionReference.doc().id;
    _abonne.createDate = FieldValue.serverTimestamp();
    return collectionReference
        .doc(_abonne.uid)
        .set(_abonne.toJson())
        .then((value) {
      _abonne = Abonne();
    });
  }

  Stream<List<Abonne?>> getStreamAbonne() {
    return trainersService.listenToAbonne();
  }

  Future<void> deleteAbonne(Abonne abonne) {
    return trainersService.getAbonneReference().doc(abonne.uid).delete();
  }

  changeName(String value) {
    _abonne.name = value;
  }

  Future<void> update(Abonne abonne) {
    return trainersService
        .getAbonneReference()
        .doc(abonne.uid)
        .set(abonne.toJson());
  }
}
