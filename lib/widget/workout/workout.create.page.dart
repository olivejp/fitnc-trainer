import 'package:fitnc_trainer/bloc/workout/workout_update.bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'workout.form.builder.dart';

class WorkoutCreatePage {
  static showCreate(BuildContext context) {
    WorkoutUpdateBloc bloc = WorkoutUpdateBloc.getInstance();
    bloc.init(null);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: WorkoutFormBuilder.getForm(_formKey, bloc),
          actionsPadding: EdgeInsets.all(20),
          actions: [
            FloatingActionButton(
              tooltip: 'Annuler',
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(Icons.clear),
            ),
            FloatingActionButton(
              tooltip: 'Créer',
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  bloc.saveWorkout().then((value) => Navigator.of(context).pop());
                }
              },
              child: Icon(Icons.check),
            ),
          ],
        );
      },
    );
  }
}
