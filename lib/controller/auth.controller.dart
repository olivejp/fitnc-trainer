import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitness_domain/domain/trainers.domain.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController() {
    user.listen((User? _user) {
      if (_user != null) {
        cancelTrainerSubscription();
        trainerSubscription = trainersService.listen(_user.uid).listen((Trainers _trainer) {
          trainer.value = _trainer;
        });
      } else {
        trainer.value = null;
        cancelTrainerSubscription();
      }
    });
  }

  final Rx<User?> user = Rx<User?>(null);
  final Rx<Trainers?> trainer = Rx<Trainers?>(null);
  final TrainersService trainersService = Get.find();
  StreamSubscription<Trainers?>? trainerSubscription;

  void cancelTrainerSubscription() {
    if (trainerSubscription != null) {
      trainerSubscription!.cancel();
    }
  }

  @override
  void dispose() {
    cancelTrainerSubscription();
    super.dispose();
  }
}
