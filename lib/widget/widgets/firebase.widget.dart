import 'package:firebase_core/firebase_core.dart';
import 'package:fitnc_trainer/service/abonne.service.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/fitness-user.service.dart';
import 'package:fitnc_trainer/service/published_programme.service.dart';
import 'package:fitness_domain/service/firebase.service.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/trainers.service.dart';
import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:fitnc_trainer/widget/widgets/auth.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseWidget extends StatelessWidget {
  const FirebaseWidget({Key? key}) : super(key: key);

  void initDomainServices(){
    Get.put(AbonneService());
    Get.put(ExerciceService());
    Get.put(PublishedProgrammeService());
    Get.put(ProgrammeService());
    Get.put(WorkoutService());
    Get.put(WorkoutSetService());
    Get.put(FitnessUserService());
  }

  @override
  Widget build(BuildContext context) {

    final FirebaseService firebaseService = Get.find();

    return FutureBuilder<FirebaseApp>(
      future: firebaseService.initialize(),
      builder: (_, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasData) {
          initDomainServices();
          return AuthWidget();
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                  "L'application Firebase n'a pas été démarrée correctement."),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
