import 'package:fitnc_trainer/service/abonne.service.dart';
import 'package:fitnc_trainer/service/exercice.service.dart';
import 'package:fitnc_trainer/service/programme.service.dart';
import 'package:fitnc_trainer/service/published_programme.service.dart';
import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:fitnc_trainer/service/workout_set.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitDomainServiceMiddleware extends GetMiddleware {
  @override
  Widget onPageBuilt(Widget page) {
    Get.put(AbonneService());
    Get.put(ExerciceService());
    Get.put(PublishedProgrammeService());
    Get.put(ProgrammeService());
    Get.put(WorkoutService());
    Get.put(WorkoutSetService());
    return page;
  }
}
