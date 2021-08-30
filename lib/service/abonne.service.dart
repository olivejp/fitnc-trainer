import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/core/bloc/generic.bloc.dart';
import 'package:fitnc_trainer/domain/abonne.domain.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AbonneService extends AbstractFitnessCrudService<Abonne>
    with MixinFitnessStorageService<Abonne> {
  AbonneService(BuildContext context) {
    trainersService = Provider.of<TrainersService>(context, listen: false);
  }

  final String pathWorkoutMainImage = 'mainImage';
  late TrainersService trainersService;
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

  Widget openUpdate(BuildContext context, Abonne domain) {
    return AbonneUpdatePage(
      abonne: domain,
    );
  }
}
