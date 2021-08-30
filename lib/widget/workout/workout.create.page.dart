import 'package:fitnc_trainer/service/workout.service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'workout.form.builder.dart';

class WorkoutCreatePage {
  static void showCreate(BuildContext context) {
    final WorkoutService bloc = Provider.of<WorkoutService>(context);
    bloc.init(null);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: WorkoutFormBuilder.getForm(_formKey, bloc),
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
                  bloc.saveWorkout().then((_) => Navigator.of(context).pop());
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
