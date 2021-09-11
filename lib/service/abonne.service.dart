import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_domain/service/abstract.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/widget/abonne/abonne.update.page.dart';
import 'package:fitness_domain/domain/abonne.domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AbonneService extends AbstractFitnessCrudService<Abonne> with MixinFitnessStorageService<Abonne> {
  final String pathWorkoutMainImage = 'mainImage';
  final TrainersService trainersService = Get.find();

  @override
  Abonne fromJson(Map<String, dynamic> map) {
    return Abonne.fromJson(map);
  }

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
