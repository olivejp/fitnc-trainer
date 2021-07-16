import 'package:fitnc_trainer/bloc/exercice/exercice_update.bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'exercice.form.builder.dart';

class ExerciceCreatePage {
  static showCreate(BuildContext context) {
    ExerciceUpdateBloc bloc = ExerciceUpdateBloc.getInstance();
    bloc.init(null);
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: ExerciceFormBuilder.getForm(_formKey, bloc),
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
                  bloc.saveExercice().then((value) => Navigator.of(context).pop());
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
