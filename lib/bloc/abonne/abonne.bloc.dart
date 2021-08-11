import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:flutter/src/widgets/framework.dart';

class AbonneBloc extends AbstractFitnessCrudBloc<Abonne> with MixinFitnessStorageBloc<Abonne> {
  AbonneBloc._();

  factory AbonneBloc.instance() {
    _instance ??= AbonneBloc._();
    return _instance!;
  }

  static AbonneBloc? _instance;

  final String pathWorkoutMainImage = 'mainImage';
  final TrainersService trainersService = TrainersService.instance();
  late Abonne abonne;

  @override
  CollectionReference<Object?> getCollectionReference() {
    return trainersService.getAbonneReference();
  }

  @override
  String getStorageRef(User user, Abonne domain) {
    return 'trainers/${user.uid}/abonnes/${domain.uid}/$pathWorkoutMainImage';
  }

  @override
  Stream<List<Abonne>> listenAll() {
    return trainersService.listenToAbonne();
  }

  @override
  Widget openUpdate(BuildContext context, Abonne domain) {
    return AbonneUpdatePage(
      abonne: domain,
    );
  }
}
