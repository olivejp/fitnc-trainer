import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'workout.form.builder.dart';

class WorkoutCreatePage {
  static void showCreate(BuildContext context) {
    final WorkoutService service = Get.find();
    service.init(null);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: WorkoutFormBuilder.getForm(_formKey, service),
          actionsPadding: const EdgeInsets.all(20),
          actions: <Widget>[
            FloatingActionButton(
              tooltip: 'Annuler',
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.clear),
            ),
            FloatingActionButton(
              tooltip: 'Créer',
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  service.saveWorkout().then((_) => Navigator.of(context).pop());
                }
              },
              child: const Icon(Icons.check),
            ),
          ],
        );
      },
    );
  }
}
